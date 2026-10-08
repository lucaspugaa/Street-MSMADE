using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Mismade.Application;
using Mismade.Infrastructure;

namespace Mismade.Web;

/// <summary>
/// Webhooks de privacidad obligatorios de Tiendanube. Llegan firmados con HMAC-SHA256
/// del cuerpo usando el Client Secret, en el header x-linkedstore-hmac-sha256.
/// </summary>
public static class TiendanubeWebhooks
{
    public const string SignatureHeader = "x-linkedstore-hmac-sha256";

    public static void MapTiendanubeWebhooks(this WebApplication app)
    {
        var group = app.MapGroup("/tiendanube/webhooks").AllowAnonymous().DisableAntiforgery();

        // La tienda desinstaló la app: borramos el token guardado.
        group.MapPost("/store-redact", (HttpContext context, IOptions<TiendanubeOptions> options,
            ITiendanubeCredenciales credentials, ILoggerFactory logs) =>
            HandleAsync(context, options, logs, async body =>
            {
                if (TryGetStoreId(body, out var storeId))
                {
                    await credentials.DeleteAsync(storeId, context.RequestAborted);
                }
            }));

        // No guardamos datos personales de clientes: solo hay que confirmar la recepción.
        group.MapPost("/customers-redact", (HttpContext context, IOptions<TiendanubeOptions> options, ILoggerFactory logs) =>
            HandleAsync(context, options, logs, _ => Task.CompletedTask));
        group.MapPost("/customers-data-request", (HttpContext context, IOptions<TiendanubeOptions> options, ILoggerFactory logs) =>
            HandleAsync(context, options, logs, _ => Task.CompletedTask));
    }

    private static async Task<IResult> HandleAsync(HttpContext context, IOptions<TiendanubeOptions> options,
        ILoggerFactory logs, Func<string, Task> action)
    {
        using var reader = new StreamReader(context.Request.Body, Encoding.UTF8);
        var body = await reader.ReadToEndAsync(context.RequestAborted);
        var logger = logs.CreateLogger("TiendanubeWebhooks");

        if (!IsValid(body, context.Request.Headers[SignatureHeader], options.Value.ClientSecret))
        {
            logger.LogWarning("Webhook de Tiendanube rechazado por firma inválida ({Path}).", context.Request.Path);
            return Results.Unauthorized();
        }

        await action(body);
        logger.LogInformation("Webhook de Tiendanube procesado ({Path}).", context.Request.Path);
        return Results.Ok();
    }

    public static bool IsValid(string body, string? signature, string secret)
    {
        if (string.IsNullOrWhiteSpace(signature) || string.IsNullOrWhiteSpace(secret))
        {
            return false;
        }

        var expected = HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), Encoding.UTF8.GetBytes(body));
        byte[] supplied;
        try
        {
            supplied = Convert.FromHexString(signature.Trim());
        }
        catch (FormatException)
        {
            return false;
        }

        return CryptographicOperations.FixedTimeEquals(expected, supplied);
    }

    private static bool TryGetStoreId(string body, out long storeId)
    {
        storeId = 0;
        try
        {
            using var json = JsonDocument.Parse(body);
            return json.RootElement.TryGetProperty("store_id", out var value)
                && (value.ValueKind == JsonValueKind.Number ? value.TryGetInt64(out storeId)
                    : long.TryParse(value.GetString(), out storeId));
        }
        catch (JsonException)
        {
            return false;
        }
    }
}
