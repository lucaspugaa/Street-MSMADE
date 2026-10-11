using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

public sealed class MargenTests
{
    private static readonly DateOnly Octubre = new(2026, 10, 5);

    private static PedidoMargen Pedido(decimal total, string gateway = "Mercado Pago", string? envio = null,
        long number = 1800, params ItemPedido[] items) =>
        new(number, Octubre, total, gateway, envio, items.Length == 0 ? [new ItemPedido("Remera BTS", 1)] : items);

    [Fact]
    public void PedidoRestaComisionEnvioYCostoCombinado()
    {
        // Mercado Pago 5,10%, Andreani sobre el umbral de $95.000, una remera ($10.000) y un buzo ($24.500).
        var m = MargenCalculo.Pedido(Pedido(100_000m, envio: "Andreani a domicilio",
            items: [new ItemPedido("Remera Naruto", 1), new ItemPedido("Buzo F1", 1)]));

        Assert.Equal((5_100m, 9_000m, 34_500m), (m.Comision, m.Envio, m.Costo));
        Assert.Equal(51_400m, m.Margen);
        Assert.False(m.MedioDesconocido);
        Assert.Empty(m.ItemsSinCosto);
    }

    [Fact]
    public void CantidadMultiplicaElCosto()
    {
        var m = MargenCalculo.Pedido(Pedido(50_000m, items: [new ItemPedido("Jogging Baggy Básico", 2)]));
        Assert.Equal(40_000m, m.Costo);
    }

    [Fact]
    public void PagoNubeEnCuotasUsaTasaDeCuotas()
    {
        var pedido = Pedido(200_000m, gateway: "Pago Nube");

        Assert.Equal(46_060m, MargenCalculo.Pedido(pedido, EstadoPagoNube.Cuotas).Comision);
        Assert.False(MargenCalculo.Pedido(pedido, EstadoPagoNube.Cuotas).PagoNubeSinConfirmar);
        var pendiente = MargenCalculo.Pedido(pedido, EstadoPagoNube.Pending);
        Assert.Equal(10_960m, pendiente.Comision);
        Assert.True(pendiente.PagoNubeSinConfirmar);
        Assert.True(MargenCalculo.Pedido(pedido).PagoNubeSinConfirmar);
    }

    [Fact]
    public void PagoNubeBajoElUmbralNoPideConfirmacion()
        => Assert.False(MargenCalculo.Pedido(Pedido(170_000m, gateway: "Pago Nube")).PagoNubeSinConfirmar);

    [Fact]
    public void MedioDesconocidoYProductoSinCategoriaQuedanComoAviso()
    {
        var m = MargenCalculo.Pedido(Pedido(30_000m, gateway: "Efectivo", items: [new ItemPedido("Gorra", 1)]));
        var periodo = MargenCalculo.Periodo([m], 0m, [], [], []);

        Assert.Equal((0m, 0m), (m.Comision, m.Costo));
        Assert.Contains(periodo.Avisos, a => a.Contains("#1800") && a.Contains("medio de pago"));
        Assert.Contains(periodo.Avisos, a => a.Contains("Gorra"));
    }

    [Fact]
    public void PeriodoSumaPedidosRestaAdsYAplicaAjustesManuales()
    {
        var pedido = MargenCalculo.Pedido(Pedido(100_000m, envio: "Andreani",
            items: [new ItemPedido("Remera Naruto", 1), new ItemPedido("Buzo F1", 1)])); // margen 51.400

        var negro = new VentaNegro
        {
            TotalAmount = 38_000m,
            Items =
            [
                new VentaNegroItem { Tipo = "remera", Color = "Gris", Corte = "Oversize", Cantidad = 1 }, // 10.000
                new VentaNegroItem { Tipo = "buzo", Color = "Negro", Corte = "Oversize", Cantidad = 1 }, // 25.000
            ]
        };
        var perdida = new PerdidaMercaderia { Color = "Blanco", Corte = "Regular", Cantidad = 2 }; // 15.000
        var cambio = new CambioVenta { Monto = 12_000m };

        var p = MargenCalculo.Periodo([pedido], adsStreet: 20_000m, [negro], [perdida], [cambio]);

        Assert.Equal(1, p.Pedidos);
        Assert.Equal(3_000m, p.VentasNegroNeto);
        Assert.Equal(15_000m, p.Perdidas);
        Assert.Equal(12_000m, p.VentasCambio);
        Assert.Equal(115_000m, p.Ingresos); // 100.000 + 3.000 + 12.000
        Assert.Equal(51_400m - 20_000m + 3_000m - 15_000m + 12_000m, p.Margen);
    }

    [Fact]
    public void VentaEnNegroViejaSinTipoEsRemeraYSinCorteUsaAproximado()
    {
        var negro = new VentaNegro
        {
            TotalAmount = 15_000m,
            Items = [new VentaNegroItem { Tipo = "", Color = "Negro", Corte = "", Cantidad = 1 }]
        };

        var p = MargenCalculo.Periodo([], 0m, [negro], [], []);

        Assert.Equal(7_000m, p.VentasNegroNeto);
        Assert.Contains(p.Avisos, a => a.Contains("aproximado"));
    }
}
