using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Options;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class TiendanubeClient(HttpClient http, IOptions<TiendanubeOptions> options,
    ITiendanubeCredenciales credentials) : ITiendanubeClient
{
    public const string DisconnectedMessage = "Tiendanube desconectado: volvé a conectar";

    public async Task<string> GetStoreNameAsync(CancellationToken ct)
    {
        using var response = await SendAsync(HttpMethod.Get, "store", null, ct);
        using var json = await ReadAsync(response, ct);
        var name = json.RootElement.GetProperty("name");
        if (name.ValueKind == JsonValueKind.String)
        {
            return name.GetString()!;
        }

        var language = Text(json.RootElement, "main_language") ?? "es";
        return name.TryGetProperty(language, out var localized)
            ? localized.GetString() ?? ""
            : name.EnumerateObject().First().Value.GetString() ?? "";
    }

    public async Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desdeOrderNumber, CancellationToken ct)
    {
        var orders = new List<PedidoTiendanube>();
        await foreach (var item in GetPagesAsync("orders?payment_status=paid", ct))
        {
            var number = Integer(item, "number");
            if (number <= desdeOrderNumber || Text(item, "payment_status") != "paid")
            {
                continue;
            }

            var products = item.GetProperty("products").EnumerateArray()
                .Select(p => new LineaPedido(Integer(p, "product_id"), Integer(p, "variant_id"),
                    checked((int)Integer(p, "quantity")))).ToArray();
            // La API también devuelve offsets ISO sin ':' (por ejemplo +0000).
            var date = Regex.Replace(Text(item, "created_at")!, @"([+-]\d{2})(\d{2})$", "$1:$2");
            orders.Add(new PedidoTiendanube(Integer(item, "id"), number,
                DateTimeOffset.Parse(date, CultureInfo.InvariantCulture),
                decimal.Parse(item.GetProperty("total").ToString(), CultureInfo.InvariantCulture),
                Text(item, "payment_status")!, Text(item, "gateway"), Text(item, "shipping_option"),
                Text(item, "shipping_tracking_number"), products));
        }

        return orders.OrderBy(x => x.Number).ToArray();
    }

    public async Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long productId, CancellationToken ct)
    {
        var variants = new List<VarianteTiendanube>();
        await foreach (var item in GetPagesAsync($"products/{productId}/variants", ct))
        {
            var stock = item.GetProperty("stock");
            variants.Add(new VarianteTiendanube(productId, Integer(item, "id"),
                stock.ValueKind == JsonValueKind.Null || stock.ToString() == ""
                    ? null : int.Parse(stock.ToString(), CultureInfo.InvariantCulture)));
        }

        return variants;
    }

    public async Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct)
    {
        foreach (var batch in variantes.Chunk(50))
        {
            var body = batch.GroupBy(v => v.ProductId).Select(group => new
            {
                id = group.Key,
                variants = group.Select(v => new
                {
                    id = v.VariantId,
                    inventory_levels = new[] { new { stock = v.Stock is null ? (object)"" : v.Stock.Value } }
                }).ToArray()
            }).ToArray();

            using var response = await SendAsync(HttpMethod.Patch, "products/stock-price", body, ct);
            using var json = await ReadAsync(response, ct);
            foreach (var product in json.RootElement.EnumerateArray())
            {
                foreach (var variant in product.GetProperty("variants").EnumerateArray())
                {
                    if (!variant.GetProperty("success").GetBoolean())
                    {
                        throw new InvalidOperationException("Tiendanube no pudo actualizar el stock de una variante.");
                    }
                }
            }
        }
    }

    private async IAsyncEnumerable<JsonElement> GetPagesAsync(string resource,
        [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken ct)
    {
        var separator = resource.Contains('?') ? "&" : "?";
        var page = 1;
        string? next = $"{resource}{separator}per_page=200&page={page}";

        while (next is not null)
        {
            using var response = await SendAsync(HttpMethod.Get, next, null, ct);
            using var json = await ReadAsync(response, ct);
            if (json.RootElement.GetArrayLength() == 0)
            {
                yield break;
            }

            foreach (var item in json.RootElement.EnumerateArray())
            {
                yield return item;
            }

            if (response.Headers.TryGetValues("Link", out var links))
            {
                var match = Regex.Match(string.Join(",", links), @"<([^>]+)>\s*;\s*rel=""?next""?");
                next = match.Success ? match.Groups[1].Value : null;
            }
            else
            {
                next = $"{resource}{separator}per_page=200&page={++page}";
            }
        }
    }

    private async Task<HttpResponseMessage> SendAsync(HttpMethod method, string resource, object? body, CancellationToken ct)
    {
        var connection = await credentials.GetAsync(ct)
            ?? throw new InvalidOperationException(DisconnectedMessage);
        var baseUri = new Uri($"https://api.tiendanube.com/v1/{connection.StoreId}/");
        var uri = new Uri(baseUri, resource);
        // No enviar credenciales a otro host ni a otra tienda mediante un Link remoto.
        if (uri.Scheme != baseUri.Scheme || uri.Authority != baseUri.Authority
            || !uri.AbsolutePath.StartsWith(baseUri.AbsolutePath, StringComparison.Ordinal))
        {
            throw new InvalidOperationException("Link de paginación Tiendanube inválido.");
        }

        using var request = new HttpRequestMessage(method, uri);
        request.Headers.TryAddWithoutValidation("Authentication", $"bearer {connection.Token}");
        request.Headers.TryAddWithoutValidation("User-Agent", options.Value.UserAgent);
        if (body is not null)
        {
            request.Content = JsonContent.Create(body);
        }

        var response = await http.SendAsync(request, ct);
        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            response.Dispose();
            throw new InvalidOperationException(DisconnectedMessage);
        }

        if (!response.IsSuccessStatusCode)
        {
            var status = response.StatusCode;
            response.Dispose();
            throw new HttpRequestException($"Tiendanube respondió HTTP {(int)status}.", null, status);
        }

        return response;
    }

    private static async Task<JsonDocument> ReadAsync(HttpResponseMessage response, CancellationToken ct)
    {
        await using var stream = await response.Content.ReadAsStreamAsync(ct);
        return await JsonDocument.ParseAsync(stream, cancellationToken: ct);
    }

    internal static long Integer(JsonElement item, string key) =>
        long.Parse(item.GetProperty(key).ToString(), CultureInfo.InvariantCulture);

    internal static string? Text(JsonElement item, string key) =>
        item.TryGetProperty(key, out var value) && value.ValueKind != JsonValueKind.Null ? value.GetString() : null;
}
