using Mismade.Domain;

namespace Mismade.Application;

public sealed class SyncJob(IJobLock jobLock, IJobRunStore store, IDashboardNotifier notifier)
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

        try
        {
            await PedidosDesdeWatermarkAsync(ct);
            await CalcularComisionesAsync(ct);
            await CalcularEnvioAsync(ct);
            await SincronizarRemerasAsync(ct);
            await SincronizarPoolsManualesAsync(ct);
            await ProcesarVentasPerdidasCambiosAsync(ct);
            await SincronizarMetaAsync(ct);
            await CerrarMesAsync(ct);
            await NotificarUiAsync(ct);
            await RegistrarLogAsync(ct);
            ct.ThrowIfCancellationRequested();
            run.Status = EstadoJob.Succeeded;
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
            // Persistir también si el host canceló el trabajo.
            await store.SaveAsync(run, CancellationToken.None);
            notifier.Notify();
        }
    }

    private static Task PedidosDesdeWatermarkAsync(CancellationToken ct)
    {
        // TODO 1: obtener pedidos a partir de SyncWatermark y actualizar OrdersProcessed.
        return Task.CompletedTask;
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

    private static Task SincronizarRemerasAsync(CancellationToken ct)
    {
        // TODO 4: sincronizar StockRemera, mapas, exclusiones y LastPushedStock en tandas de 50.
        return Task.CompletedTask;
    }

    private static Task SincronizarPoolsManualesAsync(CancellationToken ct)
    {
        // TODO 5: sincronizar pools con su propio watermark.
        return Task.CompletedTask;
    }

    private static Task ProcesarVentasPerdidasCambiosAsync(CancellationToken ct)
    {
        // TODO 6: incorporar ventas en negro, pérdidas y cambios sin duplicar movimientos.
        return Task.CompletedTask;
    }

    private static async Task SincronizarMetaAsync(CancellationToken ct)
    {
        // Paso 7: mantener las cuentas separadas.
        await SincronizarMetaStreetAsync(ct);
        await SincronizarMetaKumoAsync(ct);
    }

    private static Task SincronizarMetaStreetAsync(CancellationToken ct)
    {
        // TODO: consultar y persistir insights únicamente de CuentaMeta.Street.
        return Task.CompletedTask;
    }

    private static Task SincronizarMetaKumoAsync(CancellationToken ct)
    {
        // TODO: consultar y persistir insights únicamente de CuentaMeta.Kumo.
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
