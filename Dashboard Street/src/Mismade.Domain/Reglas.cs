namespace Mismade.Domain;

public static class ComisionMedioPago
{
    public static decimal UmbralCuotas(DateOnly fecha) =>
        fecha < new DateOnly(2026, 10, 2) ? 100_000m : 170_000m;

    public static decimal Calcular(
        string provider, decimal total, DateOnly fecha,
        EstadoPagoNube? statusCuotas = null, Func<DateOnly, decimal>? umbralProveedor = null)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(total);
        var umbral = (umbralProveedor ?? UmbralCuotas)(fecha);
        var tasa = provider.Trim().ToLowerInvariant() switch
        {
            "mercadopago" => 0.0510m,
            "pagonube" when total > umbral && statusCuotas == EstadoPagoNube.Cuotas => 0.2303m,
            "pagonube" => 0.0548m,
            "gocuotas" => 0.1201m,
            "transferencia" or "personalizado" => 0.01m,
            _ => throw new ArgumentException("Medio de pago desconocido.", nameof(provider))
        };

        return total * tasa;
    }
}

public static class EnvioAbsorbido
{
    public const decimal CostoEstimado = 9_000m;

    public static bool Aplica(DateOnly fecha, decimal total, string? trackingNumber, string? shippingName)
    {
        var trackingAndreani = trackingNumber?.StartsWith("360003", StringComparison.Ordinal) == true;
        var retiro = shippingName?.Contains("Punto de retiro", StringComparison.OrdinalIgnoreCase) == true;
        var andreani = trackingAndreani
            || (!retiro && shippingName?.Contains("Andreani", StringComparison.OrdinalIgnoreCase) == true);

        if (!andreani || fecha < new DateOnly(2026, 8, 15))
        {
            return false;
        }

        var umbral = fecha < new DateOnly(2026, 10, 2) ? 60_000m : 95_000m;
        return total > umbral;
    }
}

public static class CostoPrenda
{
    public static decimal Calcular(string tipo, string? color = null, string? corte = null)
    {
        var gris = string.Equals(color, "Gris Prelavado", StringComparison.OrdinalIgnoreCase);

        return (tipo.Trim().ToLowerInvariant(), corte?.Trim().ToLowerInvariant()) switch
        {
            ("remera", "regular") => gris ? 9_000m : 7_500m,
            ("remera", "oversize") => gris ? 10_000m : 8_000m,
            ("buzo", _) => 25_000m,
            ("pantalón" or "pantalon", _) => 20_000m,
            ("baby tee", _) => 4_500m,
            _ => throw new ArgumentException("Prenda o corte desconocido.", nameof(tipo))
        };
    }
}
