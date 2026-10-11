using System.Globalization;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class TiendanubeOptions : IVentasConfiguration
{
    public int HistorialVentasDias { get; set; } = 400;
    public string AppId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    public string UserAgent { get; set; } = "MISMADE Dashboard";
    public string StoreId { get; set; } = "";
    public string AccessToken { get; set; } = "";
}

public sealed class StockOptions : IStockConfiguration
{
    // Apagado por defecto: escribir en la tienda tiene que ser una decisión explícita.
    public bool EnviarATiendanube { get; set; }
}

public sealed class MetaOptions : IMetaConfiguration
{
    public string SystemUserToken { get; set; } = "";
    public string StreetAccountId { get; set; } = "";
    public string KumoAccountId { get; set; } = "";
    public string GraphVersion { get; set; } = "v23.0";

    public string AccountId(CuentaMeta cuenta) => cuenta switch
    {
        CuentaMeta.Street => StreetAccountId,
        CuentaMeta.Kumo => KumoAccountId,
        _ => throw new MetaAdsException("La cuenta de Meta no es válida.")
    };

    public bool EstaConfigurada(CuentaMeta cuenta) =>
        !string.IsNullOrWhiteSpace(SystemUserToken) && !string.IsNullOrWhiteSpace(AccountId(cuenta));
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

    public async Task<IReadOnlyList<MetaInsight>> GetInsightsAsync(
        CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(options.SystemUserToken))
        {
            throw new MetaAdsException("Falta configurar el token de Meta.");
        }

        var accountId = NormalizarCuenta(options.AccountId(cuenta), cuenta);
        var version = options.GraphVersion.Trim();
        if (!System.Text.RegularExpressions.Regex.IsMatch(version, @"^v[0-9]+\.[0-9]+$"))
        {
            throw new MetaAdsException("Meta:GraphVersion debe tener el formato v23.0.");
        }

        var uri = QueryHelpers.AddQueryString($"https://graph.facebook.com/{version}/{accountId}/insights",
            new Dictionary<string, string?>
            {
                ["level"] = "campaign",
                ["time_increment"] = "1",
                ["time_range"] = JsonSerializer.Serialize(new
                {
                    since = desde.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    until = hasta.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
                }),
                ["fields"] = "campaign_id,campaign_name,spend,impressions,clicks,actions,action_values",
                ["limit"] = "500"
            });

        var filas = new List<MetaInsight>();
        try
        {
            while (uri is not null)
            {
                using var page = await LeerPaginaAsync(uri, cuenta, ct);
                foreach (var row in page.RootElement.GetProperty("data").EnumerateArray())
                {
                    filas.Add(new MetaInsight(cuenta,
                        DateOnly.ParseExact(row.GetProperty("date_start").GetString()!, "yyyy-MM-dd", CultureInfo.InvariantCulture),
                        row.GetProperty("campaign_id").GetString()!,
                        row.TryGetProperty("campaign_name", out var name) ? name.GetString() ?? "" : "",
                        Numero(row, "spend"), checked((long)Numero(row, "impressions")),
                        checked((long)Numero(row, "clicks")), Compra(row, "actions"), Compra(row, "action_values")));
                }

                uri = page.RootElement.TryGetProperty("paging", out var paging)
                    && paging.TryGetProperty("next", out var next) && !string.IsNullOrWhiteSpace(next.GetString())
                    ? SiguientePagina(next.GetString()!) : null;
            }
        }
        catch (Exception error) when (error is JsonException or FormatException or OverflowException
            or InvalidOperationException or KeyNotFoundException)
        {
            throw new MetaAdsException($"Meta devolvió datos inválidos para la cuenta {cuenta}.");
        }

        return filas;
    }

    public static string NormalizarCuenta(string id, CuentaMeta cuenta)
    {
        var limpio = string.Concat(id.Where(c => !char.IsWhiteSpace(c)));
        if (limpio.StartsWith("act_", StringComparison.Ordinal))
        {
            limpio = limpio[4..];
        }

        if (limpio.Length == 0 || limpio.Any(c => c is < '0' or > '9'))
        {
            throw new MetaAdsException($"El ID de la cuenta Meta {cuenta} debe contener solo dígitos (con prefijo act_ opcional).");
        }

        return "act_" + limpio;
    }

    private static string SiguientePagina(string next)
    {
        if (!Uri.TryCreate(next, UriKind.Absolute, out var uri) || uri.Scheme != "https"
            || uri.Host != "graph.facebook.com" || !uri.IsDefaultPort || uri.UserInfo.Length > 0)
        {
            throw new MetaAdsException("Meta devolvió una URL de paginación inválida.");
        }

        // Meta puede incluir access_token en paging.next: siempre usar solo el header.
        var query = QueryHelpers.ParseQuery(uri.Query)
            .Where(x => !x.Key.Equals("access_token", StringComparison.OrdinalIgnoreCase))
            .ToDictionary(x => x.Key, x => (string?)x.Value.ToString());
        return QueryHelpers.AddQueryString(uri.GetLeftPart(UriPartial.Path), query);
    }

    private async Task<JsonDocument> LeerPaginaAsync(string uri, CuentaMeta cuenta, CancellationToken ct)
    {
        var delays = new[] { 1, 4, 10 };
        for (var intento = 0; ; intento++)
        {
            var transitorio = false;
            var mensaje = $"No se pudo consultar Meta para la cuenta {cuenta}.";
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Get, uri);
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", options.SystemUserToken.Trim());
                using var response = await http.SendAsync(request, ct);
                var body = await response.Content.ReadAsStringAsync(ct);
                JsonDocument? page = null;
                try
                {
                    page = JsonDocument.Parse(body);
                }
                catch (JsonException)
                {
                    // Una respuesta 5xx puede no ser JSON.
                }

                var code = page is not null && page.RootElement.TryGetProperty("error", out var error)
                    && error.TryGetProperty("code", out var codeValue) && codeValue.TryGetInt32(out var parsedCode)
                    ? parsedCode : 0;

                if (response.IsSuccessStatusCode && code == 0 && page is not null)
                {
                    return page;
                }

                page?.Dispose();
                if (code == 190)
                {
                    throw new MetaAdsException("El token de Meta venció o no es válido");
                }

                if (code is 10 or 200 or 294)
                {
                    throw new MetaAdsException($"Al token le falta acceso a la cuenta {cuenta}");
                }

                transitorio = (int)response.StatusCode >= 500 || code is 1 or 2 or 4 or 17 or 32 or 613 or 80004;
                mensaje = $"No se pudo consultar Meta para la cuenta {cuenta} (HTTP {(int)response.StatusCode}, código {code}).";
            }
            catch (OperationCanceledException) when (!ct.IsCancellationRequested)
            {
                transitorio = true;
                mensaje = $"Meta tardó demasiado en responder para la cuenta {cuenta}.";
            }
            catch (HttpRequestException)
            {
                // No propagar mensajes del transporte: pueden incluir URLs o credenciales.
                throw new MetaAdsException($"No se pudo conectar con Meta para la cuenta {cuenta}.");
            }

            if (!transitorio || intento == delays.Length)
            {
                throw new MetaAdsException(mensaje);
            }

            await Task.Delay(TimeSpan.FromSeconds(delays[intento]), ct);
        }
    }

    private static decimal Numero(JsonElement row, string field)
    {
        if (!row.TryGetProperty(field, out var value) || value.ValueKind == JsonValueKind.Null)
        {
            return 0;
        }

        return decimal.Parse(value.ValueKind == JsonValueKind.String ? value.GetString()! : value.GetRawText(),
            NumberStyles.Float, CultureInfo.InvariantCulture);
    }

    private static decimal Compra(JsonElement row, string field)
    {
        if (!row.TryGetProperty(field, out var actions) || actions.ValueKind == JsonValueKind.Null)
        {
            return 0;
        }

        foreach (var tipo in new[] { "purchase", "offsite_conversion.fb_pixel_purchase" })
        {
            foreach (var action in actions.EnumerateArray())
            {
                if (action.TryGetProperty("action_type", out var type) && type.GetString() == tipo)
                {
                    return Numero(action, "value");
                }
            }
        }

        return 0;
    }
}
