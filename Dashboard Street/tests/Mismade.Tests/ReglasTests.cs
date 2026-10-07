using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

public class ComisionMedioPagoTests
{
    [Theory]
    [InlineData("MercadoPago", 51.00)]
    [InlineData("PagoNube", 54.80)]
    [InlineData("GOcuotas", 120.10)]
    [InlineData("transferencia", 10.00)]
    [InlineData("personalizado", 10.00)]
    [InlineData(" MERCADOPAGO ", 51.00)]
    public void AplicaTasasBase(string provider, decimal esperado)
        => Assert.Equal(esperado, ComisionMedioPago.Calcular(provider, 1_000m, new DateOnly(2026, 10, 2)));

    [Theory]
    [InlineData("2026-10-01", 99999, 0.0548)]
    [InlineData("2026-10-01", 100000, 0.0548)]
    [InlineData("2026-10-01", 100001, 0.2303)]
    [InlineData("2026-10-02", 100001, 0.0548)]
    [InlineData("2026-10-02", 169999, 0.0548)]
    [InlineData("2026-10-02", 170000, 0.0548)]
    [InlineData("2026-10-02", 170001, 0.2303)]
    [InlineData("2026-10-03", 170001, 0.2303)]
    public void RespetaFechasYUmbralesEstrictos(string fecha, decimal total, decimal tasa)
        => Assert.Equal(total * tasa,
            ComisionMedioPago.Calcular("PagoNube", total, DateOnly.Parse(fecha), EstadoPagoNube.Cuotas));

    [Theory]
    [InlineData(null)]
    [InlineData(EstadoPagoNube.Pending)]
    [InlineData(EstadoPagoNube.Simple)]
    public void SinConfirmacionCuotasUsaTasaBase(EstadoPagoNube? status)
        => Assert.Equal(10_960m,
            ComisionMedioPago.Calcular("PagoNube", 200_000m, new DateOnly(2026, 10, 2), status));

    [Fact]
    public void PermiteProveedorDeUmbralHistorico()
    {
        var fecha = new DateOnly(2026, 10, 2);
        decimal Proveedor(DateOnly recibida)
        {
            Assert.Equal(fecha, recibida);
            return 500m;
        }

        Assert.Equal(27.4m, ComisionMedioPago.Calcular("PagoNube", 500m, fecha, EstadoPagoNube.Cuotas, Proveedor));
        Assert.Equal(115.3803m, ComisionMedioPago.Calcular("PagoNube", 501m, fecha, EstadoPagoNube.Cuotas, Proveedor));
    }

    [Theory]
    [InlineData("2026-10-01", 100000)]
    [InlineData("2026-10-02", 170000)]
    public void UmbralPredeterminadoEsHistorico(string fecha, decimal esperado)
        => Assert.Equal(esperado, ComisionMedioPago.UmbralCuotas(DateOnly.Parse(fecha)));

    [Fact]
    public void TotalCeroNoGeneraComision()
        => Assert.Equal(0m, ComisionMedioPago.Calcular("PagoNube", 0, new DateOnly(2026, 10, 2)));
}

public class EnvioAbsorbidoTests
{
    [Theory]
    [InlineData("2026-08-14", 999999, false)]
    [InlineData("2026-08-15", 59999, false)]
    [InlineData("2026-08-15", 60000, false)]
    [InlineData("2026-08-15", 60001, true)]
    [InlineData("2026-10-01", 60000, false)]
    [InlineData("2026-10-01", 60001, true)]
    [InlineData("2026-10-02", 60001, false)]
    [InlineData("2026-10-02", 94999, false)]
    [InlineData("2026-10-02", 95000, false)]
    [InlineData("2026-10-02", 95001, true)]
    [InlineData("2026-10-03", 95001, true)]
    public void RespetaFechasYUmbralesEstrictos(string fecha, decimal total, bool esperado)
        => Assert.Equal(esperado, EnvioAbsorbido.Aplica(DateOnly.Parse(fecha), total, "360003123", null));

    [Theory]
    [InlineData(null, "Punto de retiro", false)]
    [InlineData(null, "Punto de retiro Andreani", false)]
    [InlineData("360003123", "Punto de retiro Andreani", true)]
    [InlineData("123456", "Punto de retiro", false)]
    [InlineData("360003", "Punto de retiro", true)]
    [InlineData("360003987", "Correo distinto", true)]
    [InlineData(null, "Envío ANDREANI a domicilio", true)]
    [InlineData("123", "Andreani", true)]
    [InlineData(null, "Correo Argentino", false)]
    [InlineData(null, null, false)]
    public void IdentificaAndreaniPorTrackingONombre(string? tracking, string? nombre, bool esperado)
        => Assert.Equal(esperado, EnvioAbsorbido.Aplica(new DateOnly(2026, 10, 2), 100_000m, tracking, nombre));

    [Fact]
    public void CostoEstimadoEsConstante() => Assert.Equal(9_000m, EnvioAbsorbido.CostoEstimado);
}

public class CostoPrendaTests
{
    [Theory]
    [InlineData("Remera", "Negro", "Regular", 7500)]
    [InlineData("Remera", "Blanco", "Oversize", 8000)]
    [InlineData("Remera", "Gris Prelavado", "Regular", 9000)]
    [InlineData("Remera", "Gris Prelavado", "Oversize", 10000)]
    [InlineData("Remera", "GRIS PRELAVADO", "REGULAR", 9000)]
    [InlineData("Buzo", null, null, 25000)]
    [InlineData("Pantalón", null, null, 20000)]
    [InlineData("Pantalon", null, null, 20000)]
    [InlineData("Baby Tee", null, null, 4500)]
    public void DevuelveSoloCostoDePrenda(string tipo, string? color, string? corte, decimal esperado)
        => Assert.Equal(esperado, CostoPrenda.Calcular(tipo, color, corte));

    [Fact]
    public void RechazaPrendaDesconocida()
        => Assert.Throws<ArgumentException>(() => CostoPrenda.Calcular("Desconocida"));
}
