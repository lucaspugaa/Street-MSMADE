namespace Mismade.Application;

public sealed record MetaSyncDetalle(
    CuentaMeta Cuenta, string Estado, string Mensaje, int Filas, DateOnly Desde, DateOnly Hasta);

public interface IMetaConfiguration
{
    bool EstaConfigurada(CuentaMeta cuenta);
}

public interface IMetaInsightStore
{
    Task<bool> TieneFilasAsync(CuentaMeta cuenta, CancellationToken ct);
    Task ReemplazarAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta,
        IReadOnlyList<MetaInsight> filas, CancellationToken ct);
    Task<decimal> GastoAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct);
}

public interface IMetaSyncStep
{
    Task RunAsync(SyncDetalle detalle, CancellationToken ct);
}

public static class MetaSyncVentana
{
    private static readonly TimeZoneInfo Argentina =
        TimeZoneInfo.FindSystemTimeZoneById("America/Argentina/Buenos_Aires");

    public static (DateOnly Desde, DateOnly Hasta) Calcular(bool tieneFilas, DateTimeOffset ahora)
    {
        var hoy = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(ahora, Argentina).DateTime);
        var desde = tieneFilas ? hoy.AddDays(-6) : new DateOnly(hoy.Year, hoy.Month, 1).AddMonths(-1);
        return (desde, hoy);
    }
}

public sealed class MetaSyncStep(
    IMetaAdsClient client, IMetaInsightStore store, IMetaConfiguration configuration,
    TimeProvider clock) : IMetaSyncStep
{
    public async Task RunAsync(SyncDetalle detalle, CancellationToken ct)
    {
        foreach (var cuenta in new[] { CuentaMeta.Street, CuentaMeta.Kumo })
        {
            ct.ThrowIfCancellationRequested();
            var (desde, hasta) = MetaSyncVentana.Calcular(false, clock.GetUtcNow());

            if (!configuration.EstaConfigurada(cuenta))
            {
                detalle.Meta.Add(new(cuenta, "omitido", $"Falta configurar Meta para {cuenta}.", 0, desde, hasta));
                continue;
            }

            try
            {
                (desde, hasta) = MetaSyncVentana.Calcular(await store.TieneFilasAsync(cuenta, ct), clock.GetUtcNow());
                var filas = await client.GetInsightsAsync(cuenta, desde, hasta, ct);
                await store.ReemplazarAsync(cuenta, desde, hasta, filas, ct);
                detalle.Meta.Add(new(cuenta, "ok", $"Meta {cuenta} sincronizada.", filas.Count, desde, hasta));
            }
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                throw;
            }
            catch (Exception error)
            {
                // Solo los errores controlados del cliente son aptos para mostrar; los demás
                // pueden contener credenciales o información de conexión del proveedor.
                var mensaje = error is MetaAdsException
                    ? error.Message : $"No se pudieron sincronizar los datos de Meta de {cuenta}.";
                detalle.Meta.Add(new(cuenta, "error", mensaje, 0, desde, hasta));
            }
        }
    }
}

public sealed class MetaAdsException(string message) : Exception(message);
