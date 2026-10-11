using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class StockSyncStoreTests
{
    [Fact]
    public async Task DesacoplesSeCarganYSeGuardanSegunElPlan()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using (var db = factory.CreateDbContext())
        {
            // xmin es columna de sistema de PostgreSQL; en SQLite hay que darle un valor por defecto.
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            var beigeS = new StockRemera { Color = "Beige", Corte = "Oversize", Talle = "S", Stock = 1 };
            var beigeXl = new StockRemera { Color = "Beige", Corte = "Regular", Talle = "XL", Stock = 5 };
            var negroS = new StockRemera { Color = "Negro", Corte = "Regular", Talle = "S", Stock = 2 };
            db.StockRemeras.AddRange(beigeS, beigeXl, negroS);
            db.StockVariantMaps.AddRange(
                new StockVariantMap { StockRemera = beigeS, TiendanubeProductId = 1, TiendanubeVariantId = 11 },
                new StockVariantMap { StockRemera = beigeXl, TiendanubeProductId = 1, TiendanubeVariantId = 12 },
                new StockVariantMap { StockRemera = negroS, TiendanubeProductId = 1, TiendanubeVariantId = 13 });
            db.StockDesacoples.AddRange(
                new StockDesacople { PoolKey = "beige_oversize_s", StockAtDecouple = 1, AutoCreated = true },
                new StockDesacople { PoolKey = "beige_regular_xl", StockAtDecouple = 3, AutoCreated = true });
            db.SyncWatermarks.Add(new SyncWatermark { Clave = StockSyncStore.RemerasClave, LastOrderNumberSynced = 1789 });
            await db.SaveChangesAsync();
        }

        var store = new StockSyncStore(factory);
        var remeras = Assert.Single(await store.CargarAsync(default));
        Assert.Equal(new Dictionary<string, int> { ["beige_oversize_s"] = 1, ["beige_regular_xl"] = 3 },
            remeras.Estado.Desacoples);

        // beige_regular_xl en 5 > 3: se reactiva; negro_regular_s en 2: se desacopla; beige_oversize_s sigue igual.
        var plan = await store.AplicarAsync(StockSyncStore.RemerasClave, e => StockSync.Planificar(e, []), default);
        Assert.Equal(2, plan.CambiosDesacople.Count);

        await using var verificacion = factory.CreateDbContext();
        var desacoples = await verificacion.StockDesacoples.OrderBy(d => d.PoolKey).ToListAsync();
        Assert.Equal(["beige_oversize_s", "negro_regular_s"], desacoples.Select(d => d.PoolKey));
        var negro = desacoples[1];
        Assert.Equal((2, true), (negro.StockAtDecouple, negro.AutoCreated));
        Assert.StartsWith("auto:", negro.Reason);
    }

    private static async Task CrearEsquemaAsync(Factory factory)
    {
        await using var db = factory.CreateDbContext();
        await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
            .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
    }

    private static async Task SembrarPrendasAsync(Factory factory)
    {
        await using var db = factory.CreateDbContext();
        var buzo = new StockPrenda { Tipo = StockPrenda.Buzo, Color = "Crema", Talle = "L", Stock = 2 };
        var pantalon = new StockPrenda { Tipo = StockPrenda.Pantalon, Color = "Crema", Talle = "L", Stock = 4 };
        db.StockPrendas.AddRange(buzo, pantalon);
        db.StockPrendaVariants.AddRange(
            new StockPrendaVariant { StockPrenda = buzo, TiendanubeProductId = 1, TiendanubeVariantId = 11 },
            new StockPrendaVariant { StockPrenda = pantalon, TiendanubeProductId = 2, TiendanubeVariantId = 22 });
        db.StockConjuntoVariants.AddRange(
            new StockConjuntoVariant { Color = "Crema", Talle = "L", TiendanubeProductId = 3, TiendanubeVariantId = 33 },
            new StockConjuntoVariant { Color = "Crema", Talle = "L", TiendanubeProductId = 4, TiendanubeVariantId = 44 });
        db.LastPushedStocks.AddRange(
            new LastPushedStock { PoolKey = "buzo:crema_l", Stock = 2 },
            new LastPushedStock { PoolKey = "pantalon:crema_l", Stock = 4 },
            new LastPushedStock { PoolKey = "conjunto:crema_l", Stock = 2 });
        await db.SaveChangesAsync();
    }

    [Fact]
    public async Task CargaYAplicaPrendasSinPersistirConjuntoNiRetrocederWatermark()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await CrearEsquemaAsync(factory);
        await SembrarPrendasAsync(factory);
        var store = new StockSyncStore(factory);
        var inicial = Assert.Single(await store.CargarAsync(default));
        Assert.False(inicial.TieneWatermark);
        Assert.Null(inicial.Estado.Desacoples);
        Assert.Equal(2, inicial.Estado.Stock["conjunto:crema_l"]);
        Assert.Single(inicial.Estado.Conjuntos!);
        Assert.Equal(4, inicial.Estado.Variantes.Count);
        Assert.Equal(2, inicial.Estado.UltimoEnviado["buzo:crema_l"]);

        await store.InicializarWatermarkAsync(StockSyncStore.PrendasClave, 1000, default);
        await store.InicializarWatermarkAsync(StockSyncStore.PrendasClave, 999, default);
        Assert.True(Assert.Single(await store.CargarAsync(default)).TieneWatermark);
        var pedido = new PedidoPagado(1001, [new LineaVendida(3, 33, 1)]);
        var plan = await store.AplicarAsync(StockSyncStore.PrendasClave,
            e => StockSync.Planificar(e, [pedido]), default);
        Assert.Equal(1, plan.StockNuevo["conjunto:crema_l"]);
        Assert.Equal([33L, 44L], plan.Envios.Where(e => e.PoolKey == "conjunto:crema_l").Select(e => e.VariantId).Order());
        await store.AplicarAsync(StockSyncStore.PrendasClave,
            e => StockSync.Planificar(e, []) with { WatermarkNuevo = 999 }, default);

        await using var db = factory.CreateDbContext();
        Assert.Equal(2, await db.StockPrendas.CountAsync());
        Assert.Equal(1, (await db.StockPrendas.SingleAsync(p => p.Tipo == StockPrenda.Buzo)).Stock);
        Assert.Equal(3, (await db.StockPrendas.SingleAsync(p => p.Tipo == StockPrenda.Pantalon)).Stock);
        Assert.Equal(2, await db.StockConjuntoVariants.CountAsync());
        Assert.Equal(1001, (await db.SyncWatermarks.SingleAsync()).LastOrderNumberSynced);
        Assert.Equal(2, (await db.LastPushedStocks.SingleAsync(p => p.PoolKey == "conjunto:crema_l")).Stock);
        Assert.Empty(await db.StockDesacoples.ToListAsync());
        Assert.Equal(1, Assert.Single(await store.CargarAsync(default)).Estado.Stock["conjunto:crema_l"]);
    }

    [Fact]
    public async Task SinStockPrendasNoCargaFamilia()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await CrearEsquemaAsync(factory);
        await using (var db = factory.CreateDbContext())
        {
            db.StockConjuntoVariants.Add(new StockConjuntoVariant
            {
                Color = "Crema", Talle = "L", TiendanubeProductId = 3, TiendanubeVariantId = 33
            });
            await db.SaveChangesAsync();
        }

        Assert.Empty(await new StockSyncStore(factory).CargarAsync(default));
    }

    [Fact]
    public async Task PrendasRespetaVariantesExcluidas()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await CrearEsquemaAsync(factory);
        await SembrarPrendasAsync(factory);
        await using (var db = factory.CreateDbContext())
        {
            db.StockVariantMapExclusions.Add(new StockVariantMapExclusion { VariantId = 33, Active = true });
            await db.SaveChangesAsync();
        }

        var estado = Assert.Single(await new StockSyncStore(factory).CargarAsync(default)).Estado;
        var plan = StockSync.Planificar(estado, [new PedidoPagado(1, [new LineaVendida(3, 33, 1)])]);
        Assert.Equal(2, plan.StockNuevo["buzo:crema_l"]);
        Assert.Equal(4, plan.StockNuevo["pantalon:crema_l"]);
        Assert.Empty(plan.Envios);
    }

    [Theory]
    [InlineData("remeras-prendas")]
    [InlineData("remeras-manual")]
    [InlineData("prendas-manual")]
    [InlineData("manual-manual")]
    public async Task RechazaVariantIdsCompartidosEntreFamilias(string caso)
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await CrearEsquemaAsync(factory);
        await using (var db = factory.CreateDbContext())
        {
            if (caso.Contains("remeras"))
            {
                var remera = new StockRemera { Color = "Crema", Corte = "Oversize", Talle = "L", Stock = 10 };
                db.StockVariantMaps.Add(new StockVariantMap
                {
                    StockRemera = remera, TiendanubeProductId = 1, TiendanubeVariantId = 11
                });
            }

            if (caso.Contains("prendas"))
            {
                var buzo = new StockPrenda { Tipo = StockPrenda.Buzo, Color = "Crema", Talle = "L", Stock = 2 };
                db.StockPrendaVariants.Add(new StockPrendaVariant
                {
                    StockPrenda = buzo, TiendanubeProductId = 2, TiendanubeVariantId = 11
                });
            }

            if (caso.Contains("manual"))
            {
                db.StockManualPoolVariants.Add(new StockManualPoolVariant
                {
                    StockManualPool = new StockManualPool { Nombre = "Buzo Negro XXL Regular", Stock = 2 },
                    TiendanubeProductId = 3, TiendanubeVariantId = 11
                });
            }

            if (caso == "manual-manual")
            {
                db.StockManualPoolVariants.Add(new StockManualPoolVariant
                {
                    StockManualPool = new StockManualPool { Nombre = "Otro pool", Stock = 2 },
                    TiendanubeProductId = 3, TiendanubeVariantId = 11
                });
            }

            await db.SaveChangesAsync();
        }

        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => new StockSyncStore(factory).CargarAsync(default));
        Assert.Contains("11", error.Message);
        Assert.Contains("entre familias", error.Message);
    }

    [Fact]
    public async Task ExportRealCargaPrendasSinSolapamientosSiEstaDisponible()
    {
        var carpeta = Environment.GetEnvironmentVariable("MISMADE_EXPORT");
        if (string.IsNullOrEmpty(carpeta))
        {
            return;
        }

        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await CrearEsquemaAsync(factory);
        await using (var db = factory.CreateDbContext())
        {
            await ArtifactImporter.ImportarAsync(db, carpeta, default);
        }

        var familias = await new StockSyncStore(factory).CargarAsync(default);
        var prendas = Assert.Single(familias, f => f.Clave == StockSyncStore.PrendasClave);
        Assert.Equal(24, prendas.Estado.Stock.Keys.Count(k => k.StartsWith("buzo:") || k.StartsWith("pantalon:")));
        Assert.Equal(12, prendas.Estado.Stock.Keys.Count(k => k.StartsWith("conjunto:")));
        Assert.Equal(12, prendas.Estado.Conjuntos!.Count);
        Assert.Null(prendas.Estado.Desacoples);
    }

    private sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() =>
            new(new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection).Options);
    }
}
