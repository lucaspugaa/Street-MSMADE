using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

public sealed class StockSyncTests
{
    // crema_oversize_s compartido por dos diseños; negro_oversize_xl con una variante concentrada (excluida).
    private static readonly VariantePool[] Variantes =
    [
        new("crema_oversize_s", ProductId: 10, VariantId: 101),
        new("crema_oversize_s", ProductId: 20, VariantId: 201),
        new("negro_oversize_xl", ProductId: 10, VariantId: 102),
        new("negro_oversize_xl", ProductId: 30, VariantId: 301),
    ];

    private static EstadoSync Estado(
        int crema = 30, int negro = 5, long watermark = 1000,
        Dictionary<string, int>? enviado = null, HashSet<long>? excluidas = null) => new(
        new Dictionary<string, int> { ["crema_oversize_s"] = crema, ["negro_oversize_xl"] = negro },
        Variantes,
        excluidas ?? [],
        enviado ?? new Dictionary<string, int> { ["crema_oversize_s"] = crema, ["negro_oversize_xl"] = negro },
        watermark);

    private static PedidoPagado Pedido(long number, params (long variant, int qty)[] lineas) =>
        new(number, lineas.Select(l => new LineaVendida(0, l.variant, l.qty)).ToList());

    [Fact]
    public void VentaDescuentaDelPoolYEnviaATodasSusVariantes()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(1001, (101, 2))]);

        Assert.Equal(28, plan.StockNuevo["crema_oversize_s"]);
        Assert.Equal(["crema_oversize_s"], plan.PoolsAEnviar);
        Assert.Equal([101L, 201L], plan.Envios.Select(e => e.VariantId).Order());
        Assert.All(plan.Envios, e => Assert.Equal(28, e.Stock));
        Assert.Equal(1001, plan.WatermarkNuevo);
        Assert.Equal(1, plan.PedidosProcesados);
    }

    [Fact]
    public void VentasDeDistintosDisenosDelMismoPoolSeSuman()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(1001, (101, 1)), Pedido(1002, (201, 3))]);

        Assert.Equal(26, plan.StockNuevo["crema_oversize_s"]);
        Assert.Equal(1002, plan.WatermarkNuevo);
    }

    [Fact]
    public void SinCambiosNoEnviaNada()
    {
        var plan = StockSync.Planificar(Estado(), []);

        Assert.Empty(plan.PoolsAEnviar);
        Assert.Empty(plan.Envios);
        Assert.Equal(1000, plan.WatermarkNuevo);
    }

    [Fact]
    public void PedidosYaProcesadosSeIgnoranYElWatermarkNoRetrocede()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(999, (101, 5)), Pedido(1000, (101, 5))]);

        Assert.Equal(30, plan.StockNuevo["crema_oversize_s"]);
        Assert.Equal(1000, plan.WatermarkNuevo);
        Assert.Equal(0, plan.PedidosProcesados);
    }

    [Fact]
    public void PedidoRepetidoEnLaPaginacionCuentaUnaVez()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(1001, (101, 2)), Pedido(1001, (101, 2))]);

        Assert.Equal(28, plan.StockNuevo["crema_oversize_s"]);
        Assert.Equal(1, plan.PedidosProcesados);
    }

    [Fact]
    public void VarianteConcentradaExcluidaNoDescuentaNiSeEnvia()
    {
        // Caso negro_oversize_xl: Lucas concentró el stock real en el listado 301 y lo sacó del pool.
        var plan = StockSync.Planificar(
            Estado(excluidas: [301]),
            [Pedido(1001, (301, 1)), Pedido(1002, (102, 1))]);

        Assert.Equal(4, plan.StockNuevo["negro_oversize_xl"]); // solo cuenta la venta de 102
        Assert.Equal(1, plan.LineasSinPool);
        Assert.DoesNotContain(plan.Envios, e => e.VariantId == 301);
        Assert.Contains(plan.Envios, e => e.VariantId == 102 && e.Stock == 4);
    }

    [Fact]
    public void LineaDeProductoFueraDeLosPoolsSeCuentaYNoRompe()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(1001, (999_999, 1), (101, 1))]);

        Assert.Equal(1, plan.LineasSinPool);
        Assert.Equal(29, plan.StockNuevo["crema_oversize_s"]);
    }

    [Fact]
    public void SobreventaQuedaEnCeroYAvisaCuantoFalta()
    {
        var plan = StockSync.Planificar(Estado(negro: 2), [Pedido(1001, (102, 5))]);

        Assert.Equal(0, plan.StockNuevo["negro_oversize_xl"]);
        var alerta = Assert.Single(plan.Alertas);
        Assert.Equal(TipoAlertaStock.Sobreventa, alerta.Tipo);
        Assert.Equal(3, alerta.Faltante);
    }

    [Fact]
    public void LlegarACeroAvisaSinStock()
    {
        var plan = StockSync.Planificar(Estado(negro: 2), [Pedido(1001, (102, 2))]);

        var alerta = Assert.Single(plan.Alertas);
        Assert.Equal(new AlertaStock("negro_oversize_xl", TipoAlertaStock.SinStock), alerta);
    }

    [Fact]
    public void PoolQueYaEstabaEnCeroNoVuelveAAvisarSinStock()
    {
        var plan = StockSync.Planificar(Estado(negro: 0), []);

        Assert.Empty(plan.Alertas);
    }

    [Fact]
    public void PoolNuncaEnviadoSeEnvia()
    {
        var plan = StockSync.Planificar(Estado(enviado: []), []);

        Assert.Equal(["crema_oversize_s", "negro_oversize_xl"], plan.PoolsAEnviar);
        Assert.Equal(4, plan.Envios.Count);
    }

    [Fact]
    public void CambioManualOEnvioFallidoSeReenviaSinVentas()
    {
        // El último envío quedó en 30 pero en la base hay 35 (carga manual o envío anterior que falló).
        var plan = StockSync.Planificar(
            Estado(crema: 35, enviado: new() { ["crema_oversize_s"] = 30, ["negro_oversize_xl"] = 5 }), []);

        Assert.Equal(["crema_oversize_s"], plan.PoolsAEnviar);
        Assert.All(plan.Envios, e => Assert.Equal(35, e.Stock));
    }

    [Fact]
    public void CantidadesNoPositivasSeIgnoran()
    {
        var plan = StockSync.Planificar(Estado(), [Pedido(1001, (101, 0), (101, -3))]);

        Assert.Equal(30, plan.StockNuevo["crema_oversize_s"]);
        Assert.Equal(1001, plan.WatermarkNuevo);
    }

    [Fact]
    public void VarianteDuplicadaEnElMapaSeEnviaUnaVez()
    {
        var estado = Estado(enviado: []) with { Variantes = [.. Variantes, new("crema_oversize_s", 10, 101)] };

        var plan = StockSync.Planificar(estado, []);

        Assert.Single(plan.Envios, e => e.VariantId == 101);
    }
}
