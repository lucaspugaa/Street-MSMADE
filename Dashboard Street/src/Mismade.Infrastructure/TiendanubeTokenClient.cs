using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace Mismade.Infrastructure;

public sealed record TiendanubeToken(long StoreId, string AccessToken, string Scope);

public sealed class TiendanubeTokenClient(HttpClient http, IOptions<TiendanubeOptions> options)
{
    public async Task<TiendanubeToken> ExchangeAsync(string code, CancellationToken ct)
    {
        using var response = await http.PostAsJsonAsync("https://www.tiendanube.com/apps/authorize/token", new
        {
            client_id = options.Value.AppId,
            client_secret = options.Value.ClientSecret,
            grant_type = "authorization_code",
            code
        }, ct);
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync(ct);
        using var json = await JsonDocument.ParseAsync(stream, cancellationToken: ct);
        var root = json.RootElement;
        var idKey = root.TryGetProperty("user_id", out _) ? "user_id" : "store_id";
        var storeId = TiendanubeClient.Integer(root, idKey);
        var token = TiendanubeClient.Text(root, "access_token");
        if (storeId <= 0 || string.IsNullOrWhiteSpace(token))
        {
            throw new InvalidOperationException("Respuesta OAuth Tiendanube inválida.");
        }

        return new TiendanubeToken(storeId, token, TiendanubeClient.Text(root, "scope") ?? "");
    }
}
