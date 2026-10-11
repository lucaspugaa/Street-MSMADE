using System.Linq.Expressions;
using Mismade.Domain;

namespace Mismade.Application;

public sealed record FinanzasResumen(
    bool TieneVentas, FacturacionPeriodo Hoy, FacturacionPeriodo Mes, FacturacionPeriodo Anio);

public sealed class FinanzasConsulta(IVentasStore store, TimeProvider clock)
{
    private static readonly TimeZoneInfo Argentina =
        TimeZoneInfo.FindSystemTimeZoneById("America/Argentina/Buenos_Aires");

    // Criterio único de agrupación, igual a los reportes de Tiendanube.
    public static readonly Expression<Func<Venta, DateTimeOffset>> FechaFacturacion = venta => venta.CompletedAt ?? venta.PaidAt ?? venta.CreatedAt;

    public static Expression<Func<Venta, bool>> EnPeriodo(DateTimeOffset desde, DateTimeOffset hasta)
    {
        var fecha = FechaFacturacion.Body;
        var rango = Expression.AndAlso(
            Expression.GreaterThanOrEqual(fecha, Expression.Constant(desde)),
            Expression.LessThan(fecha, Expression.Constant(hasta)));
        return Expression.Lambda<Func<Venta, bool>>(rango, FechaFacturacion.Parameters);
    }

    public async Task<FinanzasResumen> ConsultarAsync(CancellationToken ct)
    {
        var hoy = TimeZoneInfo.ConvertTime(clock.GetUtcNow(), Argentina).Date;
        var mes = new DateTime(hoy.Year, hoy.Month, 1);
        var anio = new DateTime(hoy.Year, 1, 1);
        var tieneVentas = await store.TieneVentasAsync(ct);
        return new FinanzasResumen(tieneVentas,
            await store.FacturacionAsync(Utc(hoy), Utc(hoy.AddDays(1)), ct),
            await store.FacturacionAsync(Utc(mes), Utc(mes.AddMonths(1)), ct),
            await store.FacturacionAsync(Utc(anio), Utc(anio.AddYears(1)), ct));
    }

    private static DateTimeOffset Utc(DateTime local) =>
        new(TimeZoneInfo.ConvertTimeToUtc(local, Argentina));

}
