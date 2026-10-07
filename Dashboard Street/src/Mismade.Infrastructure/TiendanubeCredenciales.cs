using System.Globalization;
using System.Security.Cryptography;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class TiendanubeCredenciales(
    IDbContextFactory<MismadeDbContext> factory,
    IDataProtectionProvider protection,
    IOptions<TiendanubeOptions> options) : ITiendanubeCredenciales
{
    private readonly IDataProtector protector = protection.CreateProtector("Mismade.Tiendanube.AccessToken");

    public async Task<(long StoreId, string Token)?> GetAsync(CancellationToken ct)
    {
        var config = options.Value;
        if (!string.IsNullOrWhiteSpace(config.StoreId) && !string.IsNullOrWhiteSpace(config.AccessToken))
        {
            return (long.Parse(config.StoreId, CultureInfo.InvariantCulture), config.AccessToken);
        }

        await using var db = await factory.CreateDbContextAsync(ct);
        var connection = await db.TiendanubeConexiones.AsNoTracking().SingleOrDefaultAsync(ct);
        if (connection is null)
        {
            return null;
        }

        try
        {
            return (connection.StoreId, protector.Unprotect(connection.AccessTokenProtegido));
        }
        catch (CryptographicException)
        {
            return null;
        }
    }

    public async Task SaveAsync(long storeId, string token, string scope, string connectedBy, CancellationToken ct)
    {
        var encrypted = protector.Protect(token);
        var now = DateTimeOffset.UtcNow;

        await using var db = await factory.CreateDbContextAsync(ct);
        // Upsert atómico: dos callbacks simultáneos nunca crean una segunda fila.
        await db.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO "TiendanubeConexiones"
                ("Id", "StoreId", "AccessTokenProtegido", "Scope", "ConnectedAt", "ConnectedBy")
            VALUES (1, {storeId}, {encrypted}, {scope}, {now}, {connectedBy})
            ON CONFLICT ("Id") DO UPDATE SET
                "StoreId" = EXCLUDED."StoreId",
                "AccessTokenProtegido" = EXCLUDED."AccessTokenProtegido",
                "Scope" = EXCLUDED."Scope",
                "ConnectedAt" = EXCLUDED."ConnectedAt",
                "ConnectedBy" = EXCLUDED."ConnectedBy"
            """, ct);
    }
}
