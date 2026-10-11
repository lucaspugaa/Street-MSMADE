using Mismade.Domain;

namespace Mismade.Application;

public interface IFinanzasMargenService
{
    /// <summary>Rango de fechas argentinas [desde, hasta), por fecha de pago.</summary>
    Task<MargenPeriodo> ConsultarAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default);
    Task<bool> TieneDatosMetaStreetAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default);
    Task<IReadOnlyList<PagoNubeCuota>> PendientesAsync(CancellationToken ct = default);
    Task CrearPendientesAsync(CancellationToken ct = default);
    Task ConfirmarPagoNubeAsync(long number, EstadoPagoNube estado, CancellationToken ct = default);
    Task CerrarMesesAsync(CancellationToken ct = default);
}

public sealed record PeriodoFinanzas(
    string Titulo, DateOnly Desde, DateOnly Hasta, MargenPeriodo Margen, bool TieneDatosMetaStreet);

public sealed class MargenConsulta(IFinanzasMargenService service, TimeProvider clock)
{
    public async Task<IReadOnlyList<PeriodoFinanzas>> ConsultarAsync(CancellationToken ct = default)
    {
        var hoy = FechaArgentina.Dia(clock.GetUtcNow());
        var rangos = new[]
        {
            ("Ayer", hoy.AddDays(-1), hoy),
            ("Hoy (parcial)", hoy, hoy.AddDays(1)),
            ("Últimos 7 días", hoy.AddDays(-7), hoy),
            ("Este mes (1 al ayer)", new DateOnly(hoy.Year, hoy.Month, 1), hoy)
        };
        var resultado = new List<PeriodoFinanzas>();
        foreach (var (titulo, desde, hasta) in rangos)
        {
            resultado.Add(new PeriodoFinanzas(titulo, desde, hasta,
                await service.ConsultarAsync(desde, hasta, ct),
                await service.TieneDatosMetaStreetAsync(desde, hasta, ct)));
        }

        return resultado;
    }
}

public static class FechaArgentina
{
    private static readonly TimeZoneInfo Zona = TimeZoneInfo.FindSystemTimeZoneById("America/Argentina/Buenos_Aires");
    public static DateOnly Dia(DateTimeOffset instante) => DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(instante, Zona).DateTime);
    public static DateTimeOffset InicioUtc(DateOnly fecha) =>
        new(TimeZoneInfo.ConvertTimeToUtc(fecha.ToDateTime(TimeOnly.MinValue), Zona));
}
