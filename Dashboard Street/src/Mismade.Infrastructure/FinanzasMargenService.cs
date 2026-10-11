using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class FinanzasMargenService(
    IDbContextFactory<MismadeDbContext> factory, TimeProvider clock, IMetaConfiguration meta) : IFinanzasMargenService
{
    public async Task<MargenPeriodo> ConsultarAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        ValidarRango(desde, hasta);
        await using var db = await factory.CreateDbContextAsync(ct);
        return await ConsultarAsync(db, desde, hasta, ct);
    }

    private static IQueryable<Venta> Pagadas(MismadeDbContext db) => db.Ventas
        .Where(v => v.PaymentStatus == "paid" && v.CancelledAt == null && v.Status != "cancelled" && v.Status != "refunded");

    private static async Task<MargenPeriodo> ConsultarAsync(MismadeDbContext db,
        DateOnly desde, DateOnly hasta, CancellationToken ct)
    {
        var inicio = FechaArgentina.InicioUtc(desde);
        var fin = FechaArgentina.InicioUtc(hasta);
        var ventas = await Pagadas(db).AsNoTracking().Include(v => v.Items)
            .Where(v => (v.CompletedAt ?? v.PaidAt ?? v.CreatedAt) >= inicio && (v.CompletedAt ?? v.PaidAt ?? v.CreatedAt) < fin)
            .ToListAsync(ct);
        var numeros = ventas.Select(v => v.Number).ToList();
        var estados = await db.PagoNubeCuotas.AsNoTracking().Where(p => numeros.Contains(p.OrderNumber))
            .ToDictionaryAsync(p => p.OrderNumber, p => p.Status, ct);
        var pedidos = ventas.Select(v => MargenCalculo.Pedido(new PedidoMargen(
                v.Number, FechaArgentina.Dia(v.CompletedAt ?? v.PaidAt ?? v.CreatedAt), v.Total, v.Gateway, v.ShippingOption,
                v.Items.Select(i => new ItemPedido(i.Name, i.Quantity)).ToList()),
            estados.TryGetValue(v.Number, out var estado) ? estado : null)).ToList();
        var negro = await db.VentasNegro.AsNoTracking().Include(v => v.Items)
            .Where(v => v.Fecha >= desde && v.Fecha < hasta).ToListAsync(ct);
        var perdidas = await db.PerdidasMercaderia.AsNoTracking()
            .Where(v => v.Fecha >= desde && v.Fecha < hasta).ToListAsync(ct);
        var cambios = await db.CambioVentas.AsNoTracking()
            .Where(v => v.Fecha >= desde && v.Fecha < hasta).ToListAsync(ct);
        var ads = await GastoAsync(db, CuentaMeta.Street, desde, hasta, ct);

        return MargenCalculo.Periodo(pedidos, ads, negro, perdidas, cambios);
    }

    private static async Task<decimal> GastoAsync(MismadeDbContext db, CuentaMeta cuenta,
        DateOnly desde, DateOnly hasta, CancellationToken ct)
    {
        var nombre = cuenta.ToString();
        // Sumar decimal después de filtrar: SQLite no tiene SUM nativo para decimal.
        var gastos = await db.MetaInsights.AsNoTracking()
            .Where(m => m.Cuenta == nombre && m.Fecha >= desde && m.Fecha < hasta)
            .Select(m => m.Gasto).ToListAsync(ct);
        return gastos.Sum();
    }

    public async Task<bool> TieneDatosMetaStreetAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default)
    {
        ValidarRango(desde, hasta);
        await using var db = await factory.CreateDbContextAsync(ct);
        return meta.EstaConfigurada(CuentaMeta.Street)
            && await db.MetaInsights.AnyAsync(m => m.Cuenta == "Street" && m.Fecha >= desde && m.Fecha < hasta, ct);
    }

    public async Task<IReadOnlyList<PagoNubeCuota>> PendientesAsync(CancellationToken ct = default)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        return await db.PagoNubeCuotas.AsNoTracking().Where(p => p.Status == EstadoPagoNube.Pending)
            .OrderBy(p => p.Fecha).ThenBy(p => p.OrderNumber).ToListAsync(ct);
    }

    public async Task CrearPendientesAsync(CancellationToken ct = default)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        var existentes = (await db.PagoNubeCuotas.Select(p => p.OrderNumber).ToListAsync(ct)).ToHashSet();
        // Como el artifact: solo últimos 7 días y mes en curso, para no pedir confirmación de pedidos viejos.
        var hoy = FechaArgentina.Dia(clock.GetUtcNow());
        var desde = new[] { new DateOnly(hoy.Year, hoy.Month, 1), hoy.AddDays(-7) }.Min();
        var inicio = FechaArgentina.InicioUtc(desde);
        var ventas = await Pagadas(db).AsNoTracking().Where(v => (v.CompletedAt ?? v.PaidAt ?? v.CreatedAt) >= inicio).ToListAsync(ct);
        foreach (var venta in ventas)
        {
            var fecha = FechaArgentina.Dia(venta.CompletedAt ?? venta.PaidAt ?? venta.CreatedAt);
            if (ComisionMedioPago.EsPagoNube(venta.Gateway) && venta.Total > ComisionMedioPago.UmbralCuotas(fecha)
                && existentes.Add(venta.Number))
            {
                db.PagoNubeCuotas.Add(new PagoNubeCuota
                {
                    OrderNumber = venta.Number, Fecha = fecha, Total = venta.Total, Status = EstadoPagoNube.Pending
                });
            }
        }

        await db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);
    }

    public async Task ConfirmarPagoNubeAsync(long number, EstadoPagoNube estado, CancellationToken ct = default)
    {
        if (estado is not (EstadoPagoNube.Cuotas or EstadoPagoNube.Simple))
        {
            throw new ArgumentException("Seleccioná cuotas o sin cuotas.", nameof(estado));
        }

        await using var db = await factory.CreateDbContextAsync(ct);
        var fila = await db.PagoNubeCuotas.SingleOrDefaultAsync(p => p.OrderNumber == number, ct)
            ?? throw new InvalidOperationException("El pedido no tiene una confirmación pendiente de Pago Nube.");
        if (fila.Status != EstadoPagoNube.Pending)
        {
            throw new InvalidOperationException("El pedido ya fue confirmado. Actualizá la lista.");
        }

        fila.Status = estado;
        fila.MarkedAt = clock.GetUtcNow();
        await db.SaveChangesAsync(ct);
    }

    public async Task CerrarMesesAsync(CancellationToken ct = default)
    {
        var hoy = FechaArgentina.Dia(clock.GetUtcNow());
        var actual = new DateOnly(hoy.Year, hoy.Month, 1);
        await using var db = await factory.CreateDbContextAsync(ct);
        await using var tx = await db.Database.BeginTransactionAsync(System.Data.IsolationLevel.Serializable, ct);
        var existentes = (await db.MonthlyHistories.Select(m => m.Mes).ToListAsync(ct)).ToHashSet();
        for (var mes = new DateOnly(2026, 10, 1); mes < actual; mes = mes.AddMonths(1))
        {
            var clave = mes.ToString("yyyy-MM", System.Globalization.CultureInfo.InvariantCulture);
            if (existentes.Contains(clave))
            {
                continue;
            }

            var margen = await ConsultarAsync(db, mes, mes.AddMonths(1), ct);
            db.MonthlyHistories.Add(new MonthlyHistory
            {
                Mes = clave, PedidosCount = margen.Pedidos, Facturado = margen.Ingresos,
                MargenReal = margen.Margen, Comision = margen.Comision, Envio = margen.Envio,
                CostoMercaderia = margen.Costo, AdsStreet = margen.AdsStreet,
                AdsKumo = await GastoAsync(db, CuentaMeta.Kumo, mes, mes.AddMonths(1), ct), Closed = true
            });
        }

        await db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);
    }

    private static void ValidarRango(DateOnly desde, DateOnly hasta)
    {
        if (hasta < desde)
        {
            throw new ArgumentException("La fecha hasta debe ser posterior o igual a desde.");
        }
    }
}
