using Mismade.Domain;

namespace Mismade.Application;

public interface IVentasConfiguration
{
    int HistorialVentasDias { get; }
}

public sealed record VentasUpsertResultado(int Nuevas, int Actualizadas);
public sealed record FacturacionPeriodo(decimal Facturado, int Pedidos);

public interface IVentasStore
{
    Task<VentasUpsertResultado> UpsertAsync(IReadOnlyList<VentaTiendanube> ventas, CancellationToken ct);
    Task<VentasSyncEstado?> GetEstadoAsync(CancellationToken ct);
    Task SetEstadoAsync(VentasSyncEstado estado, CancellationToken ct);
    Task<bool> TieneVentasAsync(CancellationToken ct);
    Task<FacturacionPeriodo> FacturacionAsync(DateTimeOffset desde, DateTimeOffset hasta, CancellationToken ct);
}

public interface IVentasSyncStep
{
    Task RunAsync(SyncDetalle detalle, CancellationToken ct);
}

public sealed class VentasSyncStep(
    IVentasStore store, ITiendanubeClient tiendanube, ITiendanubeCredenciales credenciales,
    IVentasConfiguration configuration, TimeProvider clock) : IVentasSyncStep
{
    public async Task RunAsync(SyncDetalle detalle, CancellationToken ct)
    {
        try
        {
            if (await credenciales.GetAsync(ct) is null)
            {
                detalle.Notas.Add("Tiendanube sin conectar: no se sincronizaron ventas.");
                return;
            }

            var estado = await store.GetEstadoAsync(ct);
            var desde = estado is null
                ? clock.GetUtcNow().AddDays(-configuration.HistorialVentasDias)
                : estado.UltimoUpdatedAt.AddMinutes(-10);
            if (estado is null)
            {
                detalle.Notas.Add("Carga inicial del historial de ventas.");
            }

            var ventas = await tiendanube.GetOrdersUpdatedSinceAsync(desde, ct);
            var resultado = await store.UpsertAsync(ventas, ct);
            detalle.VentasNuevas = resultado.Nuevas;
            detalle.VentasActualizadas = resultado.Actualizadas;

            // Sin pedidos, el cursor inicial queda en el comienzo del historial.
            var ultimo = ventas.Count == 0 ? estado?.UltimoUpdatedAt ?? desde
                : ventas.Max(x => x.UpdatedAtTiendanube);
            if (estado is not null && ultimo < estado.UltimoUpdatedAt)
            {
                ultimo = estado.UltimoUpdatedAt;
            }

            await store.SetEstadoAsync(new VentasSyncEstado
            {
                UltimoUpdatedAt = ultimo,
                HistorialDesde = estado?.HistorialDesde ?? desde
            }, ct);
        }
        catch (Exception error) when (error is not OperationCanceledException)
        {
            // Incluir la causa: un 403 suele indicar que la app no tiene el permiso read_orders.
            detalle.ErrorVentas = $"No se pudieron sincronizar las ventas de Tiendanube: {error.Message}";
            detalle.Notas.Add(detalle.ErrorVentas);
        }
    }
}
