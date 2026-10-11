using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class StockSyncStore(IDbContextFactory<MismadeDbContext> factory) : IStockSyncStore
{
    public const string RemerasClave = "remeras";
    public const string PrendasClave = "prendas";

    public async Task<IReadOnlyList<FamiliaStock>> CargarAsync(CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var familias = new List<FamiliaStock>();

        var remeras = await CargarRemerasAsync(db, ct);
        if (remeras is not null)
        {
            familias.Add(remeras);
        }

        foreach (var pool in await db.StockManualPools.AsNoTracking().OrderBy(p => p.Nombre).ToListAsync(ct))
        {
            familias.Add(await CargarManualAsync(db, pool, ct));
        }

        return familias;
    }

    public async Task<PlanSync> AplicarAsync(string clave, Func<EstadoSync, PlanSync> planificar, CancellationToken ct)
    {
        for (var intento = 1; ; intento++)
        {
            await using var db = await factory.CreateDbContextAsync(ct);
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            try
            {
                var plan = clave == RemerasClave
                    ? await AplicarRemerasAsync(db, planificar, ct)
                    : await AplicarManualAsync(db, clave, planificar, ct);
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);
                return plan;
            }
            catch (DbUpdateConcurrencyException) when (intento == 1)
            {
                // Alguien cargó stock a mano mientras corría el job: replanificar con el valor nuevo.
                await tx.RollbackAsync(ct);
            }
        }
    }

    public async Task MarcarEnviadoAsync(string poolKey, int stock, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var fila = await db.LastPushedStocks.SingleOrDefaultAsync(x => x.PoolKey == poolKey, ct);
        if (fila is null)
        {
            db.LastPushedStocks.Add(new LastPushedStock { PoolKey = poolKey, Stock = stock });
        }
        else
        {
            fila.Stock = stock;
            fila.UpdatedAt = DateTimeOffset.UtcNow;
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task InicializarWatermarkAsync(string clave, long orderNumber, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        if (clave == RemerasClave)
        {
            if (!await db.SyncWatermarks.AnyAsync(w => w.Clave == RemerasClave, ct))
            {
                db.SyncWatermarks.Add(new SyncWatermark { Clave = RemerasClave, LastOrderNumberSynced = orderNumber });
            }
        }
        else
        {
            var pool = await BuscarPoolAsync(db, clave, ct);
            if (!await db.StockManualPoolWatermarks.AnyAsync(w => w.StockManualPoolId == pool.Id, ct))
            {
                db.StockManualPoolWatermarks.Add(new StockManualPoolWatermark
                {
                    StockManualPoolId = pool.Id,
                    LastOrderNumberSynced = orderNumber
                });
            }
        }

        await db.SaveChangesAsync(ct);
    }

    // ---------- remeras ----------

    private static async Task<FamiliaStock?> CargarRemerasAsync(MismadeDbContext db, CancellationToken ct)
    {
        var remeras = await db.StockRemeras.AsNoTracking().ToListAsync(ct);
        if (remeras.Count == 0)
        {
            return null;
        }

        var watermark = await db.SyncWatermarks.AsNoTracking().SingleOrDefaultAsync(w => w.Clave == RemerasClave, ct);
        var estado = await EstadoRemerasAsync(db, remeras, watermark?.LastOrderNumberSynced ?? 0, ct);
        return new FamiliaStock(RemerasClave, estado, watermark is not null);
    }

    private static async Task<PlanSync> AplicarRemerasAsync(MismadeDbContext db, Func<EstadoSync, PlanSync> planificar,
        CancellationToken ct)
    {
        var remeras = await db.StockRemeras.ToListAsync(ct);
        var watermark = await db.SyncWatermarks.SingleAsync(w => w.Clave == RemerasClave, ct);
        var plan = planificar(await EstadoRemerasAsync(db, remeras, watermark.LastOrderNumberSynced, ct));

        var ahora = DateTimeOffset.UtcNow;
        foreach (var remera in remeras)
        {
            if (plan.StockNuevo.TryGetValue(PoolKeys.Remera(remera.Color, remera.Corte, remera.Talle), out var nuevo)
                && nuevo != remera.Stock)
            {
                remera.Stock = nuevo;
                remera.UpdatedAt = ahora;
            }
        }

        // Nunca retroceder el watermark.
        if (plan.WatermarkNuevo > watermark.LastOrderNumberSynced)
        {
            watermark.LastOrderNumberSynced = plan.WatermarkNuevo;
            watermark.UpdatedAt = ahora;
        }

        await AplicarDesacoplesAsync(db, plan.CambiosDesacople, ahora, ct);
        return plan;
    }

    private static async Task AplicarDesacoplesAsync(MismadeDbContext db, IReadOnlyList<CambioDesacople> cambios,
        DateTimeOffset ahora, CancellationToken ct)
    {
        if (cambios.Count == 0)
        {
            return;
        }

        var claves = cambios.Select(c => c.PoolKey).ToList();
        var existentes = await db.StockDesacoples.Where(d => claves.Contains(d.PoolKey)).ToDictionaryAsync(d => d.PoolKey, ct);
        foreach (var cambio in cambios)
        {
            existentes.TryGetValue(cambio.PoolKey, out var fila);
            if (cambio.Tipo == TipoCambioDesacople.Reactivado)
            {
                if (fila is not null)
                {
                    db.StockDesacoples.Remove(fila);
                }
            }
            else if (fila is null)
            {
                db.StockDesacoples.Add(new StockDesacople
                {
                    PoolKey = cambio.PoolKey, StockAtDecouple = cambio.StockReal, AutoCreated = true,
                    Reason = $"auto: stock bajo (≤{StockSync.UmbralDesacople} unidades), baja preventiva en Tiendanube",
                    CreatedAt = ahora, UpdatedAt = ahora
                });
            }
            else
            {
                fila.StockAtDecouple = cambio.StockReal;
                fila.UpdatedAt = ahora;
            }
        }
    }

    private static async Task<EstadoSync> EstadoRemerasAsync(MismadeDbContext db, List<StockRemera> remeras,
        long watermark, CancellationToken ct)
    {
        var claves = remeras.ToDictionary(r => r.Id, r => PoolKeys.Remera(r.Color, r.Corte, r.Talle));
        var variantes = await db.StockVariantMaps.AsNoTracking().ToListAsync(ct);
        return new EstadoSync(
            remeras.GroupBy(r => claves[r.Id]).ToDictionary(g => g.Key, g => g.First().Stock),
            variantes.Where(v => claves.ContainsKey(v.StockRemeraId))
                .Select(v => new VariantePool(claves[v.StockRemeraId], v.TiendanubeProductId, v.TiendanubeVariantId))
                .ToList(),
            await ExcluidasAsync(db, ct),
            await UltimoEnviadoAsync(db, ct),
            watermark,
            await db.StockDesacoples.AsNoTracking().ToDictionaryAsync(d => d.PoolKey, d => d.StockAtDecouple, ct));
    }

    // ---------- pools manuales ----------

    private static async Task<FamiliaStock> CargarManualAsync(MismadeDbContext db, StockManualPool pool, CancellationToken ct)
    {
        var watermark = await db.StockManualPoolWatermarks.AsNoTracking()
            .SingleOrDefaultAsync(w => w.StockManualPoolId == pool.Id, ct);
        var estado = await EstadoManualAsync(db, pool, watermark?.LastOrderNumberSynced ?? 0, ct);
        return new FamiliaStock(PoolKeys.Manual(pool.Nombre), estado, watermark is not null);
    }

    private static async Task<PlanSync> AplicarManualAsync(MismadeDbContext db, string clave,
        Func<EstadoSync, PlanSync> planificar, CancellationToken ct)
    {
        var pool = await BuscarPoolAsync(db, clave, ct);
        var watermark = await db.StockManualPoolWatermarks.SingleAsync(w => w.StockManualPoolId == pool.Id, ct);
        var plan = planificar(await EstadoManualAsync(db, pool, watermark.LastOrderNumberSynced, ct));

        var ahora = DateTimeOffset.UtcNow;
        if (plan.StockNuevo.TryGetValue(clave, out var nuevo) && nuevo != pool.Stock)
        {
            pool.Stock = nuevo;
            pool.UpdatedAt = ahora;
        }

        if (plan.WatermarkNuevo > watermark.LastOrderNumberSynced)
        {
            watermark.LastOrderNumberSynced = plan.WatermarkNuevo;
            watermark.UpdatedAt = ahora;
        }

        return plan;
    }

    private static async Task<EstadoSync> EstadoManualAsync(MismadeDbContext db, StockManualPool pool, long watermark,
        CancellationToken ct)
    {
        var clave = PoolKeys.Manual(pool.Nombre);
        var variantes = await db.StockManualPoolVariants.AsNoTracking()
            .Where(v => v.StockManualPoolId == pool.Id).ToListAsync(ct);
        return new EstadoSync(
            new Dictionary<string, int> { [clave] = pool.Stock },
            variantes.Select(v => new VariantePool(clave, v.TiendanubeProductId, v.TiendanubeVariantId)).ToList(),
            await ExcluidasAsync(db, ct),
            await UltimoEnviadoAsync(db, ct),
            watermark);
    }

    private static async Task<StockManualPool> BuscarPoolAsync(MismadeDbContext db, string clave, CancellationToken ct)
    {
        var pools = await db.StockManualPools.ToListAsync(ct);
        return pools.SingleOrDefault(p => PoolKeys.Manual(p.Nombre) == clave)
            ?? throw new InvalidOperationException($"No existe el pool manual {clave}.");
    }

    // ---------- comunes ----------

    private static async Task<IReadOnlySet<long>> ExcluidasAsync(MismadeDbContext db, CancellationToken ct) =>
        (await db.StockVariantMapExclusions.AsNoTracking().Where(e => e.Active).Select(e => e.VariantId).ToListAsync(ct))
        .ToHashSet();

    private static async Task<IReadOnlyDictionary<string, int>> UltimoEnviadoAsync(MismadeDbContext db, CancellationToken ct) =>
        (await db.LastPushedStocks.AsNoTracking().ToListAsync(ct))
        .GroupBy(x => x.PoolKey).ToDictionary(g => g.Key, g => g.First().Stock);
}
