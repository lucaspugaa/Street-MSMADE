using Microsoft.Extensions.Options;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class TiendanubeOptions
{
    public string StoreId { get; set; } = "";
    public string AccessToken { get; set; } = "";
}

public sealed class MetaOptions
{
    public string SystemUserToken { get; set; } = "";
    public string StreetAccountId { get; set; } = "";
    public string KumoAccountId { get; set; } = "";
}

public sealed class TiendanubeClient : ITiendanubeClient
{
    private readonly HttpClient http;
    private readonly TiendanubeOptions options;

    public TiendanubeClient(HttpClient http, IOptions<TiendanubeOptions> options)
    {
        this.http = http;
        this.options = options.Value;
    }

    public Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desdeOrderNumber, CancellationToken ct)
        => throw new NotImplementedException("TODO: pedidos paginados y autenticación Tiendanube.");

    public Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long productId, CancellationToken ct)
        => throw new NotImplementedException("TODO: variantes del producto.");

    public async Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct)
    {
        foreach (var tanda in variantes.Chunk(50))
        {
            ct.ThrowIfCancellationRequested();
            await UpdateBatchAsync(tanda, ct);
        }
    }

    private Task UpdateBatchAsync(VarianteTiendanube[] tanda, CancellationToken ct)
        => throw new NotImplementedException("TODO: enviar hasta 50 variantes usando http y options.");
}

public sealed class MetaAdsClient : IMetaAdsClient
{
    private readonly HttpClient http;
    private readonly MetaOptions options;

    public MetaAdsClient(HttpClient http, IOptions<MetaOptions> options)
    {
        this.http = http;
        this.options = options.Value;
    }

    public Task<IReadOnlyList<MetaInsight>> GetInsightsAsync(
        CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct)
        => throw new NotImplementedException("TODO: consultar la cuenta indicada usando http y options.");
}
