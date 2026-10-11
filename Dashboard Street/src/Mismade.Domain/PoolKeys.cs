namespace Mismade.Domain;

/// <summary>Claves de pool como las usaba el dashboard anterior (ej. "crema_oversize_s").</summary>
public static class PoolKeys
{
    public const string ManualPrefix = "manual:";

    public static string Remera(string color, string corte, string talle) =>
        string.Join('_', new[] { color, corte, talle }.Select(Normalizar));

    public static string Prenda(string tipo, string color, string talle) =>
        tipo.ToLowerInvariant() + ":" + Normalizar(color) + "_" + Normalizar(talle);

    public static string Manual(string nombre) => ManualPrefix + Normalizar(nombre);

    /// <summary>"manual:buzo_negro_xxl_regular" → "Buzo negro xxl regular".</summary>
    public static string Legible(string poolKey)
    {
        var texto = poolKey.StartsWith(ManualPrefix, StringComparison.Ordinal)
            ? poolKey[ManualPrefix.Length..]
            : poolKey;
        texto = texto.Replace('_', ' ').Trim();
        return texto.Length == 0 ? texto : char.ToUpperInvariant(texto[0]) + texto[1..];
    }

    private static string Normalizar(string valor) => string.Join('_',
        valor.Trim().ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries));
}
