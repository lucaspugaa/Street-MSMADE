using System.Text.Json;
using Mismade.Domain;

namespace Mismade.Application;

public sealed class SyncJob(IJobLock jobLock, IJobRunStore store, IDashboardNotifier notifier,
    IStockSyncStep stock, IMetaSyncStep meta, IVentasSyncStep ventas)
{
    public async Task RunAsync(string trigger, CancellationToken ct)
    {
        await using var lease = await jobLock.TryAcquireAsync(ct);
        var run = new JobRun
        {
            StartedAt = DateTimeOffset.UtcNow,
            Trigger = trigger,
            Status = lease is null ? EstadoJob.Skipped : EstadoJob.Running
        };

        if (lease is null)
        {
            run.FinishedAt = DateTimeOffset.UtcNow;
            await store.SaveAsync(run, ct);
            notifier.Notify();
            return;
        }

        await store.SaveAsync(run, ct);
        var detalle = new SyncDetalle();

        try
        {
            await ventas.RunAsync(detalle, ct);

            // Pasos 1, 4 y 5: pedidos desde el watermark y sync de remeras y pools manuales.
            var errorStock = await stock.RunAsync(detalle, ct);
            await CalcularComisionesAsync(ct);
            await CalcularEnvioAsync(ct);
            await ProcesarVentasPerdidasCambiosAsync(ct);
            await meta.RunAsync(detalle, ct);
            await CerrarMesAsync(ct);
            await NotificarUiAsync(ct);
            await RegistrarLogAsync(ct);
            ct.ThrowIfCancellationRequested();
            if (errorStock is not null)
            {
                throw new InvalidOperationException(
                    $"No se pudo enviar el stock de {detalle.PoolsFallidos.Count} combinación(es) a Tiendanube.", errorStock);
            }

            var erroresMeta = detalle.Meta.Where(x => x.Estado == "error").ToList();
            var errores = erroresMeta.Select(x => $"{x.Cuenta}: {x.Mensaje}").ToList();
            if (detalle.ErrorVentas is not null)
            {
                errores.Add(detalle.ErrorVentas);
            }

            run.Status = errores.Count > 0 ? EstadoJob.Failed : EstadoJob.Succeeded;
            run.Error = errores.Count > 0 ? string.Join("; ", errores) : null;
        }
        catch (Exception error)
        {
            run.Status = EstadoJob.Failed;
            run.Error = error.ToString();
            throw;
        }
        finally
        {
            run.FinishedAt = DateTimeOffset.UtcNow;
            run.UpdatedAt = run.FinishedAt.Value;
            run.OrdersProcessed = Math.Max(detalle.PedidosProcesados, detalle.VentasNuevas);
            run.CombinationsPushed = detalle.PoolsEnviados.Count;
            run.Detalle = JsonSerializer.Serialize(detalle);
            // Persistir también si el host canceló el trabajo.
            await store.SaveAsync(run, CancellationToken.None);
            notifier.Notify();
        }
    }


    private static Task CalcularComisionesAsync(CancellationToken ct)
    {
        // TODO 2: aplicar ComisionMedioPago usando el umbral de ConfigHistorica.
        return Task.CompletedTask;
    }

    private static Task CalcularEnvioAsync(CancellationToken ct)
    {
        // TODO 3: aplicar EnvioAbsorbido y su costo estimado.
        return Task.CompletedTask;
    }



    private static Task ProcesarVentasPerdidasCambiosAsync(CancellationToken ct)
    {
        // TODO 6: incorporar ventas en negro, pérdidas y cambios sin duplicar movimientos.
        return Task.CompletedTask;
    }

    private static Task CerrarMesAsync(CancellationToken ct)
    {
        // TODO 8: cerrar MonthlyHistory con los datos del período.
        return Task.CompletedTask;
    }

    private static Task NotificarUiAsync(CancellationToken ct)
    {
        // TODO 9: publicar progreso si se incorpora; el estado final se notifica tras guardar.
        return Task.CompletedTask;
    }

    private static Task RegistrarLogAsync(CancellationToken ct)
    {
        // TODO 10: registrar detalle y actualizar CombinationsPushed; JobRun se cierra en finally.
        return Task.CompletedTask;
    }
}
