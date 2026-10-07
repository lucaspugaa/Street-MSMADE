using Npgsql;

namespace Mismade.Infrastructure;

/// <summary>
/// Acepta la cadena en formato Npgsql (Host=...;Database=...) o como URL
/// (postgresql://usuario:clave@host/base?sslmode=require), que es lo que copian
/// Neon, Railway y Render. Los errores nunca incluyen la cadena, porque lleva la clave.
/// </summary>
public static class PostgresConnectionString
{
    private const string Invalid =
        "ConnectionStrings:Default no es válida. Usá Host=...;Database=...;Username=...;Password=...;SSL Mode=Require " +
        "o la URL postgresql://usuario:clave@host/base?sslmode=require.";

    public static string Normalize(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException("Falta ConnectionStrings:Default.");
        }

        value = value.Trim();
        try
        {
            return value.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
                || value.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase)
                ? FromUrl(value)
                : new NpgsqlConnectionStringBuilder(value).ConnectionString;
        }
        catch (Exception ex) when (ex is ArgumentException or FormatException or UriFormatException or KeyNotFoundException)
        {
            throw new InvalidOperationException(Invalid);
        }
    }

    private static string FromUrl(string value)
    {
        var uri = new Uri(value);
        var userInfo = uri.UserInfo.Split(':', 2);
        var builder = new NpgsqlConnectionStringBuilder
        {
            Host = uri.Host,
            Port = uri.IsDefaultPort || uri.Port <= 0 ? 5432 : uri.Port,
            Database = Uri.UnescapeDataString(uri.AbsolutePath.TrimStart('/')),
            Username = Uri.UnescapeDataString(userInfo[0]),
        };
        if (userInfo.Length == 2)
        {
            builder.Password = Uri.UnescapeDataString(userInfo[1]);
        }

        foreach (var pair in uri.Query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var parts = pair.Split('=', 2);
            var key = Uri.UnescapeDataString(parts[0]).ToLowerInvariant();
            var val = parts.Length == 2 ? Uri.UnescapeDataString(parts[1]) : "";
            switch (key)
            {
                case "sslmode":
                    builder.SslMode = Enum.Parse<SslMode>(val.Replace("-", ""), ignoreCase: true);
                    break;
                case "channel_binding":
                    builder.ChannelBinding = Enum.Parse<ChannelBinding>(val, ignoreCase: true);
                    break;
                case "options":
                    builder.Options = val;
                    break;
            }
        }

        return builder.ConnectionString;
    }
}
