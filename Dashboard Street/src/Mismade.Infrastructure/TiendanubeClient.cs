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
        // La API corta en 10.000 resultados y no documenta el orden: en vez de recorrer todo el
        // historial, se busca el id del último pedido procesado y se piden solo los posteriores.
        var sinceId = desdeOrderNumber > 0 ? await FindOrderIdAsync(desdeOrderNumber, ct) : null;
        var resource = sinceId is not null
            ? $"orders?payment_status=paid&since_id={sinceId}"
            : $"orders?payment_status=paid&created_at_min={Desde(TimeSpan.FromDays(60))}";

        var orders = new List<PedidoTiendanube>();
        await foreach (var item in GetPagesAsync(resource, ct))
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

    public async Task<IReadOnlyList<VentaTiendanube>> GetOrdersUpdatedSinceAsync(
        DateTimeOffset desde, CancellationToken ct)
    {
        var fecha = desde.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", CultureInfo.InvariantCulture);
        var ventas = new List<VentaTiendanube>();
        await foreach (var item in GetPagesAsync($"orders?updated_at_min={fecha}&status=any&payment_status=any", ct))
        {
            var customer = item.TryGetProperty("customer", out var value)
                && value.ValueKind == JsonValueKind.Object ? (JsonElement?)value : null;
            var items = item.GetProperty("products").EnumerateArray()
                .Select(p => new VentaItemTiendanube(Integer(p, "product_id"), Integer(p, "variant_id"),
                    checked((int)Integer(p, "quantity")), Decimal(p, "price"),
                    LocalizedText(p, "name") ?? "", Text(p, "sku"))).ToArray();

            ventas.Add(new VentaTiendanube(Integer(item, "id"), Integer(item, "number"),
                Date(item, "created_at")!.Value, Date(item, "updated_at")!.Value,
                Date(item, "paid_at"), Date(item, "cancelled_at"), Text(item, "status")!,
                Text(item, "payment_status")!, Decimal(item, "total"), Decimal(item, "subtotal"),
                Decimal(item, "discount"), Decimal(item, "shipping_cost_customer"),
                Decimal(item, "shipping_cost_owner"), Text(item, "gateway"),
                LocalizedText(item, "shipping_option"), Text(item, "currency"),
                customer is { } c && c.TryGetProperty("id", out var id) && id.ValueKind != JsonValueKind.Null
                    ? Integer(c, "id") : null,
                customer is { } nombre ? LocalizedText(nombre, "name") : null,
                customer is { } email ? Text(email, "email") : null, items));
        }

        return ventas;
    }

    private static decimal Decimal(JsonElement item, string key) =>
        decimal.Parse(item.GetProperty(key).ToString(), CultureInfo.InvariantCulture);

    private static DateTimeOffset? Date(JsonElement item, string key)
    {
        var value = Text(item, key);
        if (string.IsNullOrEmpty(value))
        {
            return null;
        }

        return DateTimeOffset.Parse(Regex.Replace(value, @"([+-]\d{2})(\d{2})$", "$1:$2"),
            CultureInfo.InvariantCulture);
    }

    private static string? LocalizedText(JsonElement item, string key)
    {
        if (!item.TryGetProperty(key, out var value) || value.ValueKind == JsonValueKind.Null)
        {
            return null;
        }

        if (value.ValueKind == JsonValueKind.String)
        {
            return value.GetString();
        }

        if (value.TryGetProperty("es", out var spanish))
        {
            return spanish.GetString();
        }

        foreach (var localized in value.EnumerateObject())
        {
            if (localized.Value.ValueKind == JsonValueKind.String)
            {
                return localized.Value.GetString();
            }
        }

        return null;
    }

    public async Task<long> GetLatestOrderNumberAsync(CancellationToken ct)
    {
        var ultimo = await MaxNumberAsync($"orders?fields=number&created_at_min={Desde(TimeSpan.FromDays(30))}", ct);
        return ultimo > 0 ? ultimo : await MaxNumberAsync("orders?fields=number", ct);
    }

    private async Task<long?> FindOrderIdAsync(long number, CancellationToken ct)
    {
        // q busca por número de pedido (también por texto): nos quedamos con la coincidencia exacta.
        await foreach (var item in GetPagesAsync($"orders?q={number}&fields=id,number", ct))
        {
            if (Integer(item, "number") == number)
            {
                return Integer(item, "id");
            }
        }

        return null;
    }

    private async Task<long> MaxNumberAsync(string resource, CancellationToken ct)
    {
        long max = 0;
        await foreach (var item in GetPagesAsync(resource, ct))
        {
            max = Math.Max(max, Integer(item, "number"));
        }

        return max;
    }

    private static string Desde(TimeSpan hace) =>
        (DateTimeOffset.UtcNow - hace).ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", CultureInfo.InvariantCulture);

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
            using var response = await SendPageAsync(next, ct);
            if (response is null)
            {
                yield break;
            }

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

    private async Task<HttpResponseMessage?> SendPageAsync(string resource, CancellationToken ct)
    {
        try
        {
            return await SendAsync(HttpMethod.Get, resource, null, ct);
        }
        // Un listado sin resultados, o una página después de la última, responde 404 "Last page is N".
        catch (HttpRequestException error) when (error.StatusCode == HttpStatusCode.NotFound
            && error.Message.Contains("Last page", StringComparison.OrdinalIgnoreCase))
        {
            return null;
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
            var detalle = await response.Content.ReadAsStringAsync(ct);
            response.Dispose();
            detalle = detalle.Length > 300 ? detalle[..300] : detalle;
            throw new HttpRequestException(
                $"Tiendanube respondió HTTP {(int)status}{(detalle.Length > 0 ? $": {detalle}" : "")}.", null, status);
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
