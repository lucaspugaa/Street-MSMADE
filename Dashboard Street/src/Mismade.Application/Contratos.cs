using Mismade.Domain;

namespace Mismade.Application;

// TODO: ampliar los DTO cuando se implementen las integraciones.
public record PedidoTiendanube(long OrderNumber, decimal Total);
public record VarianteTiendanube(long ProductId, long VariantId, int Stock);
public record MetaInsight(DateOnly Fecha, decimal Gasto);
public enum CuentaMeta { Street, Kumo }

public interface ITiendanubeClient
{
    Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desdeOrderNumber, CancellationToken ct);
    Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long productId, CancellationToken ct);
    /// <summary>Envía el stock en tandas de hasta 50 variantes.</summary>
    Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct);
}

public interface IMetaAdsClient
{
    Task<IReadOnlyList<MetaInsight>> GetInsightsAsync(
        CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct);
}

public interface IJobLock
{
    Task<IAsyncDisposable?> TryAcquireAsync(CancellationToken ct);
}

public interface IJobRunStore
{
    Task SaveAsync(JobRun jobRun, CancellationToken ct);
    Task<JobRun?> GetLatestAsync(CancellationToken ct);
}

public interface IDashboardNotifier
{
    event Action? Refrescar;
    void Notify();
}

public interface ISyncQueue
{
    ValueTask EnqueueAsync(string trigger, CancellationToken ct = default);
}
