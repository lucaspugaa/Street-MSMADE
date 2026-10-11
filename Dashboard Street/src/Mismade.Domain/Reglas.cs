using System.Globalization;
using System.Text;

namespace Mismade.Domain;

/// <summary>Comisión de un pedido. Un medio de pago desconocido no resta nada y se marca para avisar.</summary>
public sealed record ComisionPago(decimal Monto, bool MedioConocido);

public static class ComisionMedioPago
{
    public static decimal UmbralCuotas(DateOnly fecha) =>
        fecha < new DateOnly(2026, 10, 2) ? 100_000m : 170_000m;

    /// <summary>
    /// Acepta tanto el nombre que muestra Tiendanube ("Mercado Pago", "Pago Nube", "GOcuotas", "Personalizado")
    /// como su identificador ("mercadopago", "pago_nube"): se comparan sin espacios, guiones ni mayúsculas.
    /// </summary>
    public static ComisionPago Calcular(
        string? provider, decimal total, DateOnly fecha,
        EstadoPagoNube? statusCuotas = null, Func<DateOnly, decimal>? umbralProveedor = null)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(total);
        var umbral = (umbralProveedor ?? UmbralCuotas)(fecha);
        decimal? tasa = Normalizar(provider) switch
        {
            "mercadopago" => 0.0510m,
            "pagonube" or "nuvempago" when total > umbral && statusCuotas == EstadoPagoNube.Cuotas => 0.2303m,
            "pagonube" or "nuvempago" => 0.0548m,
            "gocuotas" => 0.1201m,
            // Transferencia: el 10% de descuento ya viene en el total, solo se resta el 1% de CPT.
            "transferencia" or "personalizado" => 0.01m,
            _ => null
        };

        return tasa is null ? new ComisionPago(0m, false) : new ComisionPago(total * tasa.Value, true);
    }

    public static bool EsPagoNube(string? provider) => Normalizar(provider) is "pagonube" or "nuvempago";

    private static string Normalizar(string? texto) => new((texto ?? "")
        .Normalize(NormalizationForm.FormD)
        .Where(c => char.IsLetterOrDigit(c) && CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
        .Select(char.ToLowerInvariant).ToArray());
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
        return total >= umbral;
    }
}

/// <summary>
/// Costo solo de la prenda (sin estampado): para ventas en negro y pérdidas de mercadería (paso 3.9).
/// No usar para pedidos de Tiendanube: esos usan <see cref="CostoMercaderiaTiendanube"/>.
/// </summary>
public static class CostoPrenda
{
    /// <summary>Remera sin corte cargado (documentos viejos): el artifact usa este aproximado.</summary>
    public const decimal RemeraSinCorte = 8_000m;

    public static decimal Calcular(string tipo, string? color = null, string? corte = null)
    {
        // El stock y los movimientos guardan "Gris"; la tabla de Lucas lo llama "Gris Prelavado"
        // (no figura entre los "otros colores"), así que los dos usan el precio de prelavado.
        var gris = color?.Trim().ToLowerInvariant() is "gris" or "gris prelavado";

        return (tipo.Trim().ToLowerInvariant(), corte?.Trim().ToLowerInvariant()) switch
        {
            ("remera", "regular") => gris ? 9_000m : 7_500m,
            ("remera", "oversize") => gris ? 10_000m : 8_000m,
            ("remera", _) => RemeraSinCorte,
            ("buzo", _) => 25_000m,
            ("pantalón" or "pantalon", _) => 20_000m,
            ("baby tee", _) => 4_500m,
            _ => throw new ArgumentException("Prenda o corte desconocido.", nameof(tipo))
        };
    }
}

/// <summary>
/// Costo combinado prenda + estampado por ítem de un pedido de Tiendanube (paso 2.a), según el nombre
/// del producto. Null si el nombre no corresponde a ninguna categoría, para avisarlo en vez de inventarlo.
/// </summary>
public static class CostoMercaderiaTiendanube
{
    public static decimal? PorProducto(string? nombre)
    {
        var n = new string((nombre ?? "").Normalize(NormalizationForm.FormD)
            .Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark).ToArray())
            .ToLowerInvariant();

        // El orden importa: un conjunto incluye buzo y pantalón, y una baby tee puede decir "remera".
        if (n.Contains("conjunto")) return 44_500m;
        if (n.Contains("baby")) return 6_500m;
        if (n.Contains("buzo") || n.Contains("hoodie")) return 24_500m;
        if (n.Contains("pantalon") || n.Contains("jogging")) return 20_000m;
        if (n.Contains("remera")) return 10_000m;
        return null;
    }
}
