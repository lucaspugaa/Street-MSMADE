using Mismade.Domain;

namespace Mismade.Application;

public record PedidoTiendanube(long Id, long Number, DateTimeOffset CreatedAt, decimal Total,
    string PaymentStatus, string? Gateway, string? ShippingOption, string? TrackingNumber,
    IReadOnlyList<LineaPedido> Productos);
public record LineaPedido(long ProductId, long VariantId, int Quantity);
public record VarianteTiendanube(long ProductId, long VariantId, int? Stock);
public record MetaInsight(CuentaMeta Cuenta, DateOnly Fecha, string CampaignId, string CampaignName,
    decimal Gasto, long Impresiones, long Clicks, decimal Compras, decimal ValorCompras);
public enum CuentaMeta { Street, Kumo }

public interface ITiendanubeClient
{
    Task<IReadOnlyList<VentaTiendanube>> GetOrdersUpdatedSinceAsync(DateTimeOffset desde, CancellationToken ct);
    Task<string> GetStoreNameAsync(CancellationToken ct);
    /// <summary>Pedidos pagos con número mayor a <paramref name="desdeOrderNumber"/>, ordenados.</summary>
    Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desdeOrderNumber, CancellationToken ct);
    /// <summary>Número del pedido más reciente de la tienda (0 si no hay ninguno).</summary>
    Task<long> GetLatestOrderNumberAsync(CancellationToken ct);
    Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long productId, CancellationToken ct);
    /// <summary>Envía el stock en tandas de hasta 50 variantes.</summary>
    Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct);
}

public interface ITiendanubeCredenciales
{
    Task<(long StoreId, string Token)?> GetAsync(CancellationToken ct);
    Task SaveAsync(long storeId, string token, string scope, string connectedBy, CancellationToken ct);
    /// <summary>Borra la conexión guardada si es de esa tienda (desinstalación).</summary>
    Task DeleteAsync(long storeId, CancellationToken ct);
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

public sealed record VentaTiendanube(
    long TiendanubeOrderId, long Number, DateTimeOffset CreatedAt, DateTimeOffset UpdatedAtTiendanube,
    DateTimeOffset? PaidAt, DateTimeOffset? CancelledAt, string Status, string PaymentStatus,
    decimal Total, decimal Subtotal, decimal Discount, decimal ShippingCostCustomer,
    decimal ShippingCostOwner, string? Gateway, string? ShippingOption, string? Currency,
    long? CustomerId, string? CustomerName, string? CustomerEmail, IReadOnlyList<VentaItemTiendanube> Items, DateTimeOffset? CompletedAt = null);

public sealed record VentaItemTiendanube(
    long ProductId, long VariantId, int Quantity, decimal Price, string Name, string? Sku);
