using System.Globalization;

namespace Mismade.Web.Components.Ui;

public static class Moneda
{
    private static readonly CultureInfo Argentina = CultureInfo.GetCultureInfo("es-AR");
    public static string Formatear(decimal monto, int decimales = 0) =>
        "$ " + monto.ToString($"N{decimales}", Argentina);
}
