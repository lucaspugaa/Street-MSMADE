using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class MovimientosManualesService(IDbContextFactory<MismadeDbContext> factory) : IMovimientosManualesService
{
    public const string MensajeImportado = "Movimiento importado del panel anterior: no se puede borrar desde acá porque no se sabe cuánto stock descontó";
    private const string Remeras = "remeras";
    private const string Manual = "manual";
    private const string Cambios = "cambios";
    private sealed record Efecto(string Destino, Guid StockId, int Delta);

    public Task<ResultadoMovimiento> RegistrarVentaNegroAsync(VentaNegro entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new VentaNegro
        {
            Fecha = entrada.Fecha, TotalAmount = entrada.TotalAmount, Nota = entrada.Nota,
            Items = entrada.Items.Select(i => new VentaNegroItem
            {
                Tipo = i.Tipo, Color = i.Color, Corte = i.Corte, Talle = i.Talle, Cantidad = i.Cantidad
            }).ToList()
        }, async (db, movimiento, efectos, avisos) =>
        {
            ValidarMonto(movimiento.TotalAmount);
            if (movimiento.Items.Count == 0)
            {
                throw new ArgumentException("Agregá al menos un ítem a la venta.");
            }

            foreach (var item in movimiento.Items)
            {
                ValidarPrenda(item.Color, item.Corte, item.Talle, item.Cantidad);
                var tipo = item.Tipo.Trim().ToLowerInvariant();
                if (tipo == "remera")
                {
                    await DescontarRemeraAsync(db, item.Color, item.Corte, item.Talle, item.Cantidad, efectos, avisos, ct);
                }
                else if (tipo == "buzo")
                {
                    if (PoolKeys.Remera(item.Color, item.Corte, item.Talle) == "negro_regular_xxl")
                    {
                        var pools = await db.StockManualPools.ToListAsync(ct);
                        var pool = pools.SingleOrDefault(p => PoolKeys.Manual(p.Nombre) == "manual:buzo_negro_xxl_regular")
                            ?? throw new InvalidOperationException("No existe el pool manual Buzo Negro XXL Regular.");
                        var delta = AplicarDelta(pool.Stock, -item.Cantidad, pool.Nombre, avisos);
                        pool.Stock += delta;
                        efectos.Add(new Efecto(Manual, pool.Id, delta));
                    }
                }
                else if (tipo != "pantalon")
                {
                    throw new ArgumentException("Tipo de prenda inválido: usá remera, buzo o pantalon.");
                }
            }
        }, ct);

    public Task<ResultadoMovimiento> RegistrarPerdidaAsync(PerdidaMercaderia entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new PerdidaMercaderia
        {
            Fecha = entrada.Fecha, Color = entrada.Color, Corte = entrada.Corte, Talle = entrada.Talle,
            Cantidad = entrada.Cantidad, Motivo = entrada.Motivo, Nota = entrada.Nota
        }, async (db, movimiento, efectos, avisos) =>
        {
            if (string.IsNullOrWhiteSpace(movimiento.Motivo))
            {
                throw new ArgumentException("Indicá el motivo de la pérdida.");
            }

            await DescontarRemeraAsync(db, movimiento.Color, movimiento.Corte, movimiento.Talle,
                movimiento.Cantidad, efectos, avisos, ct);
        }, ct);

    public Task<ResultadoMovimiento> RegistrarCrisAsync(CrisLedger entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new CrisLedger
        {
            Fecha = entrada.Fecha, Tipo = entrada.Tipo, Monto = entrada.Monto, Nota = entrada.Nota,
            Color = entrada.Color, Corte = entrada.Corte, Talle = entrada.Talle, Cantidad = entrada.Cantidad
        }, async (db, movimiento, efectos, avisos) =>
        {
            ValidarMonto(movimiento.Monto);
            if (!Enum.IsDefined(movimiento.Tipo))
            {
                throw new ArgumentException("Tipo de movimiento con Cris inválido.");
            }

            if (movimiento.Tipo == TipoMovimientoCris.Devolucion)
            {
                await DescontarRemeraAsync(db, movimiento.Color ?? "", movimiento.Corte ?? "", movimiento.Talle ?? "",
                    movimiento.Cantidad ?? 0, efectos, avisos, ct);
            }
        }, ct);

    public Task<ResultadoMovimiento> RegistrarCambioAsync(CambioPrenda entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new CambioPrenda
        {
            Fecha = entrada.Fecha, Nota = entrada.Nota,
            ItemsSalida = entrada.ItemsSalida.Select(i => new CambioItemSalida
            {
                Color = i.Color, Corte = i.Corte, Talle = i.Talle, Cantidad = i.Cantidad
            }).ToList(),
            ItemsRecibidos = entrada.ItemsRecibidos.Select(i => new CambioItemRecibido
            {
                Color = i.Color, Corte = i.Corte, Talle = i.Talle, Cantidad = i.Cantidad
            }).ToList()
        }, async (db, movimiento, efectos, avisos) =>
        {
            if (movimiento.ItemsSalida.Count == 0 || movimiento.ItemsRecibidos.Count == 0)
            {
                throw new ArgumentException("Agregá las prendas que salen y las que vuelven.");
            }

            foreach (var item in movimiento.ItemsSalida)
            {
                await DescontarRemeraAsync(db, item.Color, item.Corte, item.Talle, item.Cantidad, efectos, avisos, ct);
            }

            foreach (var item in movimiento.ItemsRecibidos)
            {
                await CambiarStockCambioAsync(db, item.Color, item.Corte, item.Talle, item.Cantidad, efectos, avisos, ct);
            }
        }, ct);

    public Task<ResultadoMovimiento> RegistrarCargaAsync(CambioStockCarga entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new CambioStockCarga
        {
            Fecha = entrada.Fecha, Color = entrada.Color, Corte = entrada.Corte, Talle = entrada.Talle,
            Cantidad = entrada.Cantidad, Nota = entrada.Nota
        }, (db, movimiento, efectos, avisos) =>
        {
            ValidarPrenda(movimiento.Color, movimiento.Corte, movimiento.Talle, movimiento.Cantidad);
            return CambiarStockCambioAsync(db, movimiento.Color, movimiento.Corte, movimiento.Talle,
                movimiento.Cantidad, efectos, avisos, ct);
        }, ct);

    public Task<ResultadoMovimiento> RegistrarVentaCambioAsync(CambioVenta entrada, CancellationToken ct = default) =>
        RegistrarAsync(() => new CambioVenta
        {
            Fecha = entrada.Fecha, Color = entrada.Color, Corte = entrada.Corte, Talle = entrada.Talle,
            Cantidad = entrada.Cantidad, Monto = entrada.Monto, Nota = entrada.Nota
        }, (db, movimiento, efectos, avisos) =>
        {
            ValidarMonto(movimiento.Monto);
            ValidarPrenda(movimiento.Color, movimiento.Corte, movimiento.Talle, movimiento.Cantidad);
            return CambiarStockCambioAsync(db, movimiento.Color, movimiento.Corte, movimiento.Talle,
                -movimiento.Cantidad, efectos, avisos, ct);
        }, ct);

    public Task<ResultadoMovimiento> BorrarVentaNegroAsync(Guid id, CancellationToken ct = default) => BorrarAsync<VentaNegro>(id, ct);
    public Task<ResultadoMovimiento> BorrarPerdidaAsync(Guid id, CancellationToken ct = default) => BorrarAsync<PerdidaMercaderia>(id, ct);
    public Task<ResultadoMovimiento> BorrarCrisAsync(Guid id, CancellationToken ct = default) => BorrarAsync<CrisLedger>(id, ct);
    public Task<ResultadoMovimiento> BorrarCambioAsync(Guid id, CancellationToken ct = default) => BorrarAsync<CambioPrenda>(id, ct);
    public Task<ResultadoMovimiento> BorrarCargaAsync(Guid id, CancellationToken ct = default) => BorrarAsync<CambioStockCarga>(id, ct);
    public Task<ResultadoMovimiento> BorrarVentaCambioAsync(Guid id, CancellationToken ct = default) => BorrarAsync<CambioVenta>(id, ct);

    private Task<ResultadoMovimiento> RegistrarAsync<T>(Func<T> crear,
        Func<MismadeDbContext, T, List<Efecto>, List<string>, Task> aplicar, CancellationToken ct)
        where T : Entidad, IMovimientoConStock => EjecutarAsync(async (db, avisos) =>
        {
            var movimiento = crear();
            if (movimiento.Fecha == default)
            {
                throw new ArgumentException("Indicá la fecha del movimiento.");
            }

            var efectos = new List<Efecto>();
            await aplicar(db, movimiento, efectos, avisos);
            movimiento.EfectoStock = JsonSerializer.Serialize(efectos);
            db.Set<T>().Add(movimiento);
            return movimiento.Id;
        }, ct);

    private Task<ResultadoMovimiento> BorrarAsync<T>(Guid id, CancellationToken ct)
        where T : Entidad, IMovimientoConStock => EjecutarAsync(async (db, avisos) =>
        {
            var movimiento = await db.Set<T>().SingleOrDefaultAsync(m => m.Id == id, ct)
                ?? throw new InvalidOperationException("El movimiento ya no existe.");
            var crisSinStock = movimiento is CrisLedger cris && cris.Tipo != TipoMovimientoCris.Devolucion;
            if (movimiento.EfectoStock is null && !crisSinStock)
            {
                throw new InvalidOperationException(MensajeImportado);
            }

            var efectos = movimiento.EfectoStock is null ? []
                : JsonSerializer.Deserialize<List<Efecto>>(movimiento.EfectoStock)
                    ?? throw new InvalidOperationException("El efecto registrado del movimiento no es válido.");
            foreach (var efecto in efectos.AsEnumerable().Reverse())
            {
                await RevertirAsync(db, efecto, avisos, ct);
            }

            db.Set<T>().Remove(movimiento);
            return movimiento.Id;
        }, ct);

    private async Task<ResultadoMovimiento> EjecutarAsync(
        Func<MismadeDbContext, List<string>, Task<Guid>> ejecutar, CancellationToken ct)
    {
        for (var intento = 1; ; intento++)
        {
            await using var db = await factory.CreateDbContextAsync(ct);
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            try
            {
                var avisos = new List<string>();
                var id = await ejecutar(db, avisos);
                await db.SaveChangesAsync(ct);
                await tx.CommitAsync(ct);
                return new ResultadoMovimiento(id, avisos);
            }
            catch (DbUpdateConcurrencyException) when (intento == 1)
            {
                await tx.RollbackAsync(ct);
            }
        }
    }

    private static async Task DescontarRemeraAsync(MismadeDbContext db, string color, string corte, string talle,
        int cantidad, List<Efecto> efectos, List<string> avisos, CancellationToken ct)
    {
        ValidarPrenda(color, corte, talle, cantidad);
        var clave = PoolKeys.Remera(color, corte, talle);
        var remeras = await db.StockRemeras.ToListAsync(ct);
        var remera = remeras.SingleOrDefault(r => PoolKeys.Remera(r.Color, r.Corte, r.Talle) == clave)
            ?? throw new InvalidOperationException($"No existe stock de remera para {PoolKeys.Legible(clave)}.");
        var delta = AplicarDelta(remera.Stock, -cantidad, PoolKeys.Legible(clave), avisos);
        remera.Stock += delta;
        efectos.Add(new Efecto(Remeras, remera.Id, delta));
    }

    private static async Task CambiarStockCambioAsync(MismadeDbContext db, string color, string corte, string talle,
        int delta, List<Efecto> efectos, List<string> avisos, CancellationToken ct)
    {
        ValidarPrenda(color, corte, talle, Math.Abs(delta));
        var clave = PoolKeys.Remera(color, corte, talle);
        // Incluye filas recién creadas dentro del mismo cambio, antes de SaveChanges.
        var filas = await db.StockCambios.ToListAsync(ct);
        var stock = filas.Concat(db.StockCambios.Local).DistinctBy(s => s.Id)
            .SingleOrDefault(s => PoolKeys.Remera(s.Color, s.Corte, s.Talle) == clave);
        if (stock is null)
        {
            if (delta < 0)
            {
                throw new InvalidOperationException($"No existe stock de cambios para {PoolKeys.Legible(clave)}.");
            }

            stock = new StockCambio { Color = color.Trim(), Corte = corte.Trim(), Talle = talle.Trim() };
            db.StockCambios.Add(stock);
        }

        var real = AplicarDelta(stock.Disponible, delta, PoolKeys.Legible(clave), avisos);
        stock.Disponible += real;
        efectos.Add(new Efecto(Cambios, stock.Id, real));
    }

    private static async Task RevertirAsync(MismadeDbContext db, Efecto efecto, List<string> avisos, CancellationToken ct)
    {
        switch (efecto.Destino)
        {
            case Remeras:
                var remera = await db.StockRemeras.SingleAsync(s => s.Id == efecto.StockId, ct);
                remera.Stock += AplicarDelta(remera.Stock, -efecto.Delta, "Remeras", avisos);
                break;
            case Manual:
                var pool = await db.StockManualPools.SingleAsync(s => s.Id == efecto.StockId, ct);
                pool.Stock += AplicarDelta(pool.Stock, -efecto.Delta, pool.Nombre, avisos);
                break;
            case Cambios:
                var cambio = await db.StockCambios.SingleAsync(s => s.Id == efecto.StockId, ct);
                cambio.Disponible += AplicarDelta(cambio.Disponible, -efecto.Delta, "Stock de cambios", avisos);
                break;
            default:
                throw new InvalidOperationException("Destino de stock desconocido en el movimiento.");
        }
    }

    private static int AplicarDelta(int stock, int delta, string nombre, List<string> avisos)
    {
        var nuevo = checked(stock + delta);
        if (nuevo < 0)
        {
            avisos.Add($"{nombre}: se aplicó el piso en 0; faltaban {-nuevo} unidad(es).");
            nuevo = 0;
        }

        return nuevo - stock;
    }

    private static void ValidarPrenda(string color, string corte, string talle, int cantidad)
    {
        if (cantidad <= 0 || string.IsNullOrWhiteSpace(color) || string.IsNullOrWhiteSpace(corte)
            || string.IsNullOrWhiteSpace(talle))
        {
            throw new ArgumentException("Indicá color, corte, talle y una cantidad mayor que 0.");
        }
    }

    private static void ValidarMonto(decimal monto)
    {
        if (monto < 0)
        {
            throw new ArgumentException("El monto no puede ser negativo.");
        }
    }
}
