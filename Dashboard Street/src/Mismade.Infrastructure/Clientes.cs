using Microsoft.Extensions.Options;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class TiendanubeOptions
{
    public string AppId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    public string UserAgent { get; set; } = "MISMADE Dashboard";
    public string StoreId { get; set; } = "";
    public string AccessToken { get; set; } = "";
}

public sealed class MetaOptions
{
    public string SystemUserToken { get; set; } = "";
    public string StreetAccountId { get; set; } = "";
    public string KumoAccountId { get; set; } = "";
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
