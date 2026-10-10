using System.Globalization;
using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Mismade.Application;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class TiendanubeClientTests
{
    [Theory]
    [InlineData("MISMADE Dashboard")]
    [InlineData("Street (contact@example.com)")]
    public async Task StoreUsesStoreIdAuthenticationAndUserAgent(string userAgent)
    {
        using var http = new HttpClient(new FakeHttpHandler((request, _) =>
        {
            Assert.Equal("https://api.tiendanube.com/v1/123/store", request.RequestUri!.AbsoluteUri);
            Assert.Equal("bearer fake-token", Assert.Single(request.Headers.GetValues("Authentication")));
            Assert.Equal(userAgent, string.Join(" ", request.Headers.GetValues("User-Agent")));
            Assert.Null(request.Headers.Authorization);
            return Task.FromResult(Json("""{"main_language":"es","name":{"pt":"Loja","es":"Street"}}"""));
        }));

        var client = new TiendanubeClient(http, Options.Create(new TiendanubeOptions { UserAgent = userAgent }),
            new FakeCredentials());
        Assert.Equal("Street", await client.GetStoreNameAsync(default));
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task OrdersPaginateFilterSortAndParseInvariantDecimal(bool useLink)
    {
        var count = 0;
        using var http = new HttpClient(new FakeHttpHandler((request, _) =>
        {
            // Primero busca el id del último pedido procesado (#10) para pedir solo los posteriores.
            if (request.RequestUri!.Query.Contains("q=10"))
            {
                return Task.FromResult(Json(request.RequestUri.Query.Contains("page=1")
                    ? """[{"id": 900, "number": 100}, {"id": 555, "number": 10}]"""
                    : "[]"));
            }

            count++;
            Assert.Contains("since_id=555", request.RequestUri.Query);
            Assert.Contains("payment_status=paid", request.RequestUri!.Query);
            Assert.Contains("per_page=200", request.RequestUri.Query);
            Assert.Contains($"page={count}", request.RequestUri.Query);
            var response = Json(count switch
            {
                1 => $"[{Order(13)}, {Order(10)}]",
                2 => $"[{Order(12)}, {Order(14, "pending")}]",
                _ => "[]"
            });
            if (useLink)
            {
                response.Headers.TryAddWithoutValidation("Link", count == 1
                    ? "<https://api.tiendanube.com/v1/123/orders?payment_status=paid&since_id=555&per_page=200&page=2>; rel=\"next\""
                    : "<https://api.tiendanube.com/v1/123/orders?page=1>; rel=\"prev\"");
            }

            return Task.FromResult(response);
        }));

        var previous = CultureInfo.CurrentCulture;
        try
        {
            CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo("es-AR");
            var orders = await Client(http).GetOrdersAsync(10, default);
            Assert.Equal(new long[] { 12, 13 }, orders.Select(o => o.Number));
            Assert.All(orders, o =>
            {
                Assert.Equal(1500.25m, o.Total);
                Assert.Equal(TimeSpan.Zero, o.CreatedAt.Offset);
                Assert.Equal("paid", o.PaymentStatus);
                Assert.Equal("offline", o.Gateway);
                Assert.Equal("Correo", o.ShippingOption);
                Assert.Equal("TRACK", o.TrackingNumber);
                Assert.Equal(new LineaPedido(20, 21, 2), Assert.Single(o.Productos));
            });
            Assert.Equal(useLink ? 2 : 3, count);
        }
        finally
        {
            CultureInfo.CurrentCulture = previous;
        }
    }

    [Fact]
    public async Task VariantsPaginateAndAllowNullStock()
    {
        var calls = 0;
        using var http = new HttpClient(new FakeHttpHandler((request, _) =>
        {
            calls++;
            Assert.Equal("/v1/123/products/7/variants", request.RequestUri!.AbsolutePath);
            return Task.FromResult(Json(calls == 1
                ? """[{"id":8,"stock":null},{"id":"9","stock":"12"}]""" : "[]"));
        }));

        Assert.Equal(new[] { new VarianteTiendanube(7, 8, null), new VarianteTiendanube(7, 9, 12) },
            await Client(http).GetProductVariantsAsync(7, default));
        Assert.Equal(2, calls);
    }

    [Fact]
    public async Task StockBatchesAtMost50AcrossProductsWithDocumentedPayload()
    {
        var sizes = new List<int>();
        var seen = new List<long>();
        using var http = new HttpClient(new FakeHttpHandler(async (request, ct) =>
        {
            Assert.Equal(HttpMethod.Patch, request.Method);
            Assert.Equal("/v1/123/products/stock-price", request.RequestUri!.AbsolutePath);
            using var json = JsonDocument.Parse(await request.Content!.ReadAsStringAsync(ct));
            var products = json.RootElement.EnumerateArray().ToArray();
            sizes.Add(products.Sum(p => p.GetProperty("variants").GetArrayLength()));
            foreach (var product in products)
            {
                foreach (var variant in product.GetProperty("variants").EnumerateArray())
                {
                    var id = variant.GetProperty("id").GetInt64();
                    seen.Add(id);
                    Assert.Equal(id % 3, product.GetProperty("id").GetInt64());
                    var stock = Assert.Single(variant.GetProperty("inventory_levels").EnumerateArray()).GetProperty("stock");
                    if (id == 0)
                    {
                        Assert.Equal("", stock.GetString());
                    }
                    else
                    {
                        Assert.Equal(5, stock.GetInt32());
                    }
                }
            }

            return Json(JsonSerializer.Serialize(products.Select(p => new
            {
                id = p.GetProperty("id").GetInt64(),
                variants = p.GetProperty("variants").EnumerateArray()
                    .Select(v => new { id = v.GetProperty("id").GetInt64(), success = true }).ToArray()
            })));
        }));

        await Client(http).UpdateStockAsync(Enumerable.Range(0, 101)
            .Select(i => new VarianteTiendanube(i % 3, i, i == 0 ? null : 5)).ToArray(), default);
        Assert.Equal(new[] { 50, 50, 1 }, sizes);
        Assert.Equal(Enumerable.Range(0, 101).Select(i => (long)i), seen.Order());
    }

    [Fact]
    public async Task StockPartialFailureIsNotSilentlyAccepted()
    {
        using var http = new HttpClient(new FakeHttpHandler((_, _) =>
            Task.FromResult(Json("""[{"id":1,"variants":[{"id":2,"success":false}]}]"""))));
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            Client(http).UpdateStockAsync([new(1, 2, 3)], default));
    }

    [Fact]
    public async Task UnauthorizedHasClearReconnectMessage()
    {
        using var http = new HttpClient(new FakeHttpHandler((_, _) =>
            Task.FromResult(new HttpResponseMessage(HttpStatusCode.Unauthorized))));
        var exception = await Assert.ThrowsAsync<InvalidOperationException>(() => Client(http).GetStoreNameAsync(default));
        Assert.Equal("Tiendanube desconectado: volvé a conectar", exception.Message);
    }

    [Fact]
    public async Task UntrustedPaginationLinkNeverReceivesToken()
    {
        var count = 0;
        using var http = new HttpClient(new FakeHttpHandler((_, _) =>
        {
            count++;
            var response = Json($"[{Order(20)}]");
            response.Headers.TryAddWithoutValidation("Link", "<https://evil.example/orders>; rel=\"next\"");
            return Task.FromResult(response);
        }));
        await Assert.ThrowsAsync<InvalidOperationException>(() => Client(http).GetOrdersAsync(0, default));
        Assert.Equal(1, count);
    }

    [Fact]
    public void RateLimitUsesMillisecondsAndLongestAdvertisedDelay()
    {
        using var response = new HttpResponseMessage(HttpStatusCode.TooManyRequests);
        response.Headers.RetryAfter = new RetryConditionHeaderValue(TimeSpan.FromSeconds(2));
        response.Headers.Add("x-rate-limit-reset", "3000");
        Assert.Equal(TimeSpan.FromSeconds(3), TiendanubeRateLimit.GetDelay(response));
        response.Headers.Remove("x-rate-limit-reset");
        Assert.Equal(TimeSpan.FromSeconds(2), TiendanubeRateLimit.GetDelay(response));
        response.Headers.RetryAfter = null;
        response.Headers.Add("x-rate-limit-reset", "1500");
        Assert.Equal(TimeSpan.FromMilliseconds(1500), TiendanubeRateLimit.GetDelay(response));
        response.Headers.Remove("x-rate-limit-reset");
        response.Headers.RetryAfter = new RetryConditionHeaderValue(DateTimeOffset.UtcNow.AddMinutes(1));
        Assert.InRange(TiendanubeRateLimit.GetDelay(response)!.Value.TotalSeconds, 55, 61);
    }

    [Fact]
    public async Task RegisteredResilienceRetries429WithResetHeader()
    {
        var calls = 0;
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddInfrastructure(new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["ConnectionStrings:Default"] = "Host=localhost;Database=fake;Username=fake;Password=fake"
        }).Build());
        services.AddScoped<ITiendanubeCredenciales, FakeCredentials>();
        services.AddHttpClient<ITiendanubeClient, TiendanubeClient>().ConfigurePrimaryHttpMessageHandler(() =>
            new FakeHttpHandler((_, _) =>
            {
                if (++calls == 1)
                {
                    var response = new HttpResponseMessage(HttpStatusCode.TooManyRequests);
                    response.Headers.Add("x-rate-limit-reset", "1");
                    return Task.FromResult(response);
                }

                return Task.FromResult(Json("""{"name":{"es":"Street"}}"""));
            }));
        await using var provider = services.BuildServiceProvider();
        using var scope = provider.CreateScope();

        Assert.Equal("Street", await scope.ServiceProvider.GetRequiredService<ITiendanubeClient>().GetStoreNameAsync(default));
        Assert.Equal(2, calls);
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task UpdatedOrdersParseAllStatusesAndPaginate(bool useLink)
    {
        var calls = 0;
        using var http = new HttpClient(new FakeHttpHandler((request, _) =>
        {
            calls++;
            Assert.Contains("updated_at_min=2026-10-01T00%3A00%3A00", request.RequestUri!.Query);
            Assert.Contains("status=any", request.RequestUri.Query);
            Assert.DoesNotContain("payment_status=paid", request.RequestUri.Query);
            Assert.Contains("payment_status=any", request.RequestUri.Query);
            var response = Json(calls switch
            {
                1 => """
                    [{"id":"20","number":"30","created_at":"2026-10-01T02:00:00+0000",
                    "updated_at":"2026-10-02T00:00:00-0300","paid_at":null,
                    "cancelled_at":"2026-10-02T01:00:00-0300","status":"cancelled",
                    "payment_status":"pending","total":"1500.25","subtotal":"1600.00",
                    "discount":"200.00","shipping_cost_customer":"100.25","shipping_cost_owner":"50.00",
                    "gateway":"offline","shipping_option":"Correo","currency":"ARS","customer":null,
                    "products":[{"product_id":"7","variant_id":"8","quantity":"2","price":"800.00",
                    "name":{"pt":"Camisa","es":"Remera"},"sku":null}]}]
                    """,
                2 => """
                    [{"id":21,"number":31,"created_at":"2026-10-01T00:00:00+0000",
                    "updated_at":"2026-10-02T00:00:00+0000","paid_at":"2026-10-02T00:00:00+0000",
                    "cancelled_at":null,"status":"closed","payment_status":"paid","total":20,
                    "subtotal":20,"discount":0,"shipping_cost_customer":0,"shipping_cost_owner":0,
                    "gateway":null,"shipping_option":null,"currency":null,
                    "customer":{"id":"40","name":"Ana","email":"ana@example.com"},
                    "products":[{"product_id":7,"variant_id":8,"quantity":1,"price":20,"name":"Remera","sku":"R"}]}]
                    """,
                _ => "[]"
            });
            if (useLink)
            {
                response.Headers.TryAddWithoutValidation("Link", calls == 1
                    ? "<https://api.tiendanube.com/v1/123/orders?updated_at_min=2026-10-01T00%3A00%3A00Z&status=any&payment_status=any&page=2>; rel=next"
                    : "<https://api.tiendanube.com/v1/123/orders?page=1>; rel=prev");
            }

            return Task.FromResult(response);
        }));

        var orders = await Client(http).GetOrdersUpdatedSinceAsync(DateTimeOffset.Parse("2026-10-01T00:00:00Z"), default);
        Assert.Equal(2, orders.Count);
        var first = orders[0];
        Assert.Equal(20, first.TiendanubeOrderId);
        Assert.Equal(30, first.Number);
        Assert.Equal(1500.25m, first.Total);
        Assert.Equal(1600m, first.Subtotal);
        Assert.Equal(200m, first.Discount);
        Assert.Equal(100.25m, first.ShippingCostCustomer);
        Assert.Equal(50m, first.ShippingCostOwner);
        Assert.Equal("offline", first.Gateway);
        Assert.Equal("Correo", first.ShippingOption);
        Assert.Equal("ARS", first.Currency);
        Assert.Equal("pending", first.PaymentStatus);
        Assert.Equal("cancelled", first.Status);
        Assert.Null(first.CustomerId);
        Assert.Null(first.CustomerName);
        Assert.Null(first.CustomerEmail);
        Assert.Null(first.PaidAt);
        Assert.NotNull(first.CancelledAt);
        Assert.Equal(TimeSpan.Zero, first.CreatedAt.Offset);
        Assert.Equal(TimeSpan.FromHours(-3), first.UpdatedAtTiendanube.Offset);
        Assert.Equal(new VentaItemTiendanube(7, 8, 2, 800, "Remera", null), Assert.Single(first.Items));
        Assert.Equal(40, orders[1].CustomerId);
        Assert.Equal("Ana", orders[1].CustomerName);
        Assert.Equal("ana@example.com", orders[1].CustomerEmail);
        Assert.NotNull(orders[1].PaidAt);
        Assert.Equal("Remera", Assert.Single(orders[1].Items).Name);
        Assert.Equal(useLink ? 2 : 3, calls);
    }

    private static TiendanubeClient Client(HttpClient http) =>
        new(http, Options.Create(new TiendanubeOptions()), new FakeCredentials());

    private static string Order(long number, string payment = "paid") => $$"""
        {"id":{{number + 1000}},"number":{{number}},"created_at":"2026-10-07T00:00:00+0000",
        "total":"1500.25","payment_status":"{{payment}}","gateway":"offline",
        "shipping_option":"Correo","shipping_tracking_number":"TRACK",
        "products":[{"product_id":"20","variant_id":"21","quantity":"2"}]}
        """;

    internal static HttpResponseMessage Json(string content) => new(HttpStatusCode.OK)
    {
        Content = new StringContent(content, System.Text.Encoding.UTF8, "application/json")
    };
}

internal sealed class FakeHttpHandler(Func<HttpRequestMessage, CancellationToken, Task<HttpResponseMessage>> send)
    : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        => send(request, cancellationToken);
}

internal sealed class FakeCredentials : ITiendanubeCredenciales
{
    public (long StoreId, string Token, string Scope, string ConnectedBy)? Saved { get; private set; }

    public Task<(long StoreId, string Token)?> GetAsync(CancellationToken ct) =>
        Task.FromResult<(long, string)?>((123, "fake-token"));

    public Task DeleteAsync(long storeId, CancellationToken ct) => Task.CompletedTask;

    public Task SaveAsync(long storeId, string token, string scope, string connectedBy, CancellationToken ct)
    {
        Saved = (storeId, token, scope, connectedBy);
        return Task.CompletedTask;
    }
}
