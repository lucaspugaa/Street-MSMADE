using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Options;
using Mismade.Application;
using Mismade.Infrastructure;

namespace Mismade.Web;

public sealed class TiendanubeOAuthState(IDataProtectionProvider protection)
{
    private readonly ITimeLimitedDataProtector protector = protection
        .CreateProtector("Mismade.Tiendanube.OAuthState").ToTimeLimitedDataProtector();

    public (string State, string Cookie) Create()
    {
        var state = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
        return (state, protector.Protect(state, TimeSpan.FromMinutes(10)));
    }

    public bool Validate(string? state, string? cookie)
    {
        if (string.IsNullOrWhiteSpace(state) || string.IsNullOrWhiteSpace(cookie))
        {
            return false;
        }

        try
        {
            var expected = protector.Unprotect(cookie);
            return CryptographicOperations.FixedTimeEquals(
                SHA256.HashData(Encoding.UTF8.GetBytes(state)),
                SHA256.HashData(Encoding.UTF8.GetBytes(expected)));
        }
        catch (CryptographicException)
        {
            return false;
        }
    }
}

public static class TiendanubeOAuth
{
    public const string CookieName = "Mismade.Tiendanube.State";

    public static void MapTiendanubeOAuth(this WebApplication app)
    {
        app.MapGet("/tiendanube/conectar", Connect).RequireAuthorization(policy => policy.RequireRole("Owner"));
        app.MapGet("/tiendanube/callback", CallbackAsync).RequireAuthorization(policy => policy.RequireRole("Owner"));
    }

    public static IResult Connect(HttpContext context, IOptions<TiendanubeOptions> options, TiendanubeOAuthState states)
    {
        if (!Configured(options.Value))
        {
            return Results.Redirect("/?tiendanube=config");
        }

        var (state, cookie) = states.Create();
        var cookieOptions = CookieOptions();
        cookieOptions.Expires = DateTimeOffset.UtcNow.AddMinutes(10);
        context.Response.Cookies.Append(CookieName, cookie, cookieOptions);
        return Results.Redirect($"https://www.tiendanube.com/apps/{Uri.EscapeDataString(options.Value.AppId)}/authorize?state={state}");
    }

    public static async Task<IResult> CallbackAsync(HttpContext context, IOptions<TiendanubeOptions> options,
        TiendanubeOAuthState states, TiendanubeTokenClient tokens, ITiendanubeCredenciales credentials,
        ILoggerFactory loggerFactory)
    {
        var cookie = context.Request.Cookies[CookieName];
        context.Response.Cookies.Delete(CookieName, CookieOptions());
        var logger = loggerFactory.CreateLogger("TiendanubeOAuth");

        try
        {
            var state = context.Request.Query["state"];
            var code = context.Request.Query["code"];
            if (state.Count != 1 || code.Count != 1 || string.IsNullOrWhiteSpace(code[0])
                || !states.Validate(state[0], cookie))
            {
                throw new InvalidOperationException("State OAuth inválido.");
            }

            if (!Configured(options.Value))
            {
                return Results.Redirect("/?tiendanube=config");
            }

            var token = await tokens.ExchangeAsync(code[0]!, context.RequestAborted);
            await credentials.SaveAsync(token.StoreId, token.AccessToken, token.Scope,
                context.User.Identity?.Name ?? "", context.RequestAborted);
            return Results.Redirect("/?tiendanube=ok");
        }
        catch (Exception error)
        {
            // Solo el tipo de error (y el status HTTP si lo hay): mensaje, URL y payload pueden tener secretos.
            var status = (error as HttpRequestException)?.StatusCode;
            logger.LogWarning("No se pudo completar la conexión OAuth de Tiendanube ({Tipo}{Status}).",
                error.GetType().Name, status is null ? "" : $", HTTP {(int)status}");
            return Results.Redirect("/?tiendanube=error");
        }
    }

    private static bool Configured(TiendanubeOptions options) =>
        !string.IsNullOrWhiteSpace(options.AppId) && !string.IsNullOrWhiteSpace(options.ClientSecret);

    private static CookieOptions CookieOptions() => new()
    {
        HttpOnly = true,
        Secure = true,
        SameSite = SameSiteMode.Lax,
        Path = "/tiendanube",
        IsEssential = true
    };
}
