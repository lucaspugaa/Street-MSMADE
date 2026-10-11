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
    [InlineData("Mercado Pago", 51.00)]
    [InlineData("Pago Nube", 54.80)]
    [InlineData("pago_nube", 54.80)]
    [InlineData("GoCuotas", 120.10)]
    [InlineData("Personalizado", 10.00)]
    public void AplicaTasasBase(string provider, decimal esperado)
        => Assert.Equal(new ComisionPago(esperado, true), ComisionMedioPago.Calcular(provider, 1_000m, new DateOnly(2026, 10, 2)));

    [Theory]
    [InlineData("Efectivo")]
    [InlineData("")]
    [InlineData(null)]
    public void MedioDesconocidoNoRestaYQuedaMarcado(string? provider)
        => Assert.Equal(new ComisionPago(0m, false), ComisionMedioPago.Calcular(provider, 1_000m, new DateOnly(2026, 10, 2)));

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
            ComisionMedioPago.Calcular("PagoNube", total, DateOnly.Parse(fecha), EstadoPagoNube.Cuotas).Monto);

    [Theory]
    [InlineData(null)]
    [InlineData(EstadoPagoNube.Pending)]
    [InlineData(EstadoPagoNube.Simple)]
    public void SinConfirmacionCuotasUsaTasaBase(EstadoPagoNube? status)
        => Assert.Equal(10_960m,
            ComisionMedioPago.Calcular("PagoNube", 200_000m, new DateOnly(2026, 10, 2), status).Monto);

    [Fact]
    public void PermiteProveedorDeUmbralHistorico()
    {
        var fecha = new DateOnly(2026, 10, 2);
        decimal Proveedor(DateOnly recibida)
        {
            Assert.Equal(fecha, recibida);
            return 500m;
        }

        Assert.Equal(27.4m, ComisionMedioPago.Calcular("PagoNube", 500m, fecha, EstadoPagoNube.Cuotas, Proveedor).Monto);
        Assert.Equal(115.3803m, ComisionMedioPago.Calcular("PagoNube", 501m, fecha, EstadoPagoNube.Cuotas, Proveedor).Monto);
    }

    [Theory]
    [InlineData("2026-10-01", 100000)]
    [InlineData("2026-10-02", 170000)]
    public void UmbralPredeterminadoEsHistorico(string fecha, decimal esperado)
        => Assert.Equal(esperado, ComisionMedioPago.UmbralCuotas(DateOnly.Parse(fecha)));

    [Fact]
    public void TotalCeroNoGeneraComision()
        => Assert.Equal(0m, ComisionMedioPago.Calcular("PagoNube", 0, new DateOnly(2026, 10, 2)).Monto);
}

public class EnvioAbsorbidoTests
{
    [Theory]
    [InlineData("2026-08-14", 999999, false)]
    [InlineData("2026-08-15", 59999, false)]
    [InlineData("2026-08-15", 60000, true)]
    [InlineData("2026-08-15", 60001, true)]
    [InlineData("2026-10-01", 60000, true)]
    [InlineData("2026-10-01", 60001, true)]
    [InlineData("2026-10-02", 60001, false)]
    [InlineData("2026-10-02", 94999, false)]
    [InlineData("2026-10-02", 95000, true)]
    [InlineData("2026-10-02", 95001, true)]
    [InlineData("2026-10-03", 95001, true)]
    public void RespetaFechasYUmbralInclusivo(string fecha, decimal total, bool esperado)
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
    [InlineData("Remera", "Gris", "Oversize", 10000)]
    [InlineData("Remera", "Gris", "Regular", 9000)]
    [InlineData("Remera", "Negro", null, 8000)]
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

public class CostoMercaderiaTiendanubeTests
{
    [Theory]
    [InlineData("Remera BTS - 2.0 Black", 10000)]
    [InlineData("Buzo Argentina", 24500)]
    [InlineData("Hoodie Básico", 24500)]
    [InlineData("Jogging Baggy Básico", 20000)]
    [InlineData("Pantalón Cargo", 20000)]
    [InlineData("Remera Baby Tee Cherry", 6500)]
    [InlineData("Conjunto Oversize Básico Gris", 44500)]
    public void UsaElCostoCombinadoPorCategoria(string nombre, decimal esperado)
        => Assert.Equal(esperado, CostoMercaderiaTiendanube.PorProducto(nombre));

    [Theory]
    [InlineData("Gorra")]
    [InlineData(null)]
    public void ProductoSinCategoriaDevuelveNull(string? nombre)
        => Assert.Null(CostoMercaderiaTiendanube.PorProducto(nombre));
}
