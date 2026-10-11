using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

/// <summary>Desacople de remeras (sección 3.7 de reglas-artifact.md), con los casos reales del 10/10.</summary>
public sealed class StockDesacopleTests
{
    private const string BeigeXl = "beige_regular_xl";
    private const string NegroS = "negro_regular_s";

    private static readonly VariantePool[] Variantes =
    [
        new(BeigeXl, ProductId: 10, VariantId: 101),
        new(BeigeXl, ProductId: 20, VariantId: 201),
        new(NegroS, ProductId: 10, VariantId: 102),
    ];

    private static EstadoSync Estado(int beige, int negro, Dictionary<string, int> enviado,
        Dictionary<string, int>? desacoples) => new(
        new Dictionary<string, int> { [BeigeXl] = beige, [NegroS] = negro },
        Variantes, new HashSet<long>(), enviado, Watermark: 1000, desacoples);

    private static PedidoPagado Pedido(long number, long variant, int qty) =>
        new(number, [new LineaVendida(0, variant, qty)]);

    [Fact]
    public void PoolEnTresSinDesacoplarSeDesacoplaYPublicaCero()
    {
        // Lo que tenía que pasar el 10/10 con beige_regular_xl en 3.
        var plan = StockSync.Planificar(
            Estado(3, 20, new() { [BeigeXl] = 3, [NegroS] = 20 }, []), []);

        Assert.Equal(3, plan.StockNuevo[BeigeXl]);
        Assert.Equal(0, plan.Publicado[BeigeXl]);
        Assert.Equal(new CambioDesacople(BeigeXl, TipoCambioDesacople.Desacoplado, 3), Assert.Single(plan.CambiosDesacople));
        Assert.Equal([BeigeXl], plan.PoolsAEnviar);
        Assert.All(plan.Envios, e => Assert.Equal(0, e.Stock));
    }

    [Fact]
    public void DesacopladoQueBajaSigueEnCeroYNoSeEnvia()
    {
        var plan = StockSync.Planificar(
            Estado(3, 20, new() { [BeigeXl] = 0, [NegroS] = 20 }, new() { [BeigeXl] = 3 }),
            [Pedido(1001, 101, 1)]);

        Assert.Equal(2, plan.StockNuevo[BeigeXl]);
        Assert.Equal(0, plan.Publicado[BeigeXl]);
        Assert.Empty(plan.CambiosDesacople);
        Assert.Empty(plan.PoolsAEnviar);
    }

    [Fact]
    public void CargaQueSuperaElStockAlDesacoplarReactivaYPublicaElReal()
    {
        // Lucas carga 2: el pool pasa de 2 a 4, más que el stock_at_decouple de 3.
        var plan = StockSync.Planificar(
            Estado(4, 20, new() { [BeigeXl] = 0, [NegroS] = 20 }, new() { [BeigeXl] = 3 }), []);

        Assert.Equal(new CambioDesacople(BeigeXl, TipoCambioDesacople.Reactivado, 4), Assert.Single(plan.CambiosDesacople));
        Assert.Equal(4, plan.Publicado[BeigeXl]);
        Assert.Equal([BeigeXl], plan.PoolsAEnviar);
        Assert.All(plan.Envios, e => Assert.Equal(4, e.Stock));
    }

    [Fact]
    public void IgualAlStockAlDesacoplarNoReactiva()
    {
        var plan = StockSync.Planificar(
            Estado(3, 20, new() { [BeigeXl] = 0, [NegroS] = 20 }, new() { [BeigeXl] = 3 }), []);

        Assert.Empty(plan.CambiosDesacople);
        Assert.Equal(0, plan.Publicado[BeigeXl]);
    }

    [Fact]
    public void PoolEnCuatroQueVendeUnoSeDesacopla()
    {
        var plan = StockSync.Planificar(
            Estado(4, 20, new() { [BeigeXl] = 4, [NegroS] = 20 }, []), [Pedido(1001, 201, 1)]);

        Assert.Equal(3, plan.StockNuevo[BeigeXl]);
        Assert.Equal(0, plan.Publicado[BeigeXl]);
        Assert.Equal(new CambioDesacople(BeigeXl, TipoCambioDesacople.Desacoplado, 3), Assert.Single(plan.CambiosDesacople));
        Assert.Equal([101L, 201L], plan.Envios.Select(e => e.VariantId).Order());
        Assert.All(plan.Envios, e => Assert.Equal(0, e.Stock));
    }

    [Fact]
    public void ReactivadoQueQuedaEnTresOMenosSigueDesacopladoConElStockNuevo()
    {
        // Desacoplado con 1, carga 1: supera el stock_at_decouple pero sigue en la franja de 1 a 3.
        var plan = StockSync.Planificar(
            Estado(2, 20, new() { [BeigeXl] = 0, [NegroS] = 20 }, new() { [BeigeXl] = 1 }), []);

        Assert.Equal(new CambioDesacople(BeigeXl, TipoCambioDesacople.Desacoplado, 2), Assert.Single(plan.CambiosDesacople));
        Assert.Equal(0, plan.Publicado[BeigeXl]);
        Assert.Empty(plan.PoolsAEnviar);
    }

    [Fact]
    public void EnCeroRealNoSeDesacopla()
    {
        var plan = StockSync.Planificar(
            Estado(1, 20, new() { [BeigeXl] = 1, [NegroS] = 20 }, []), [Pedido(1001, 101, 1)]);

        Assert.Equal(0, plan.StockNuevo[BeigeXl]);
        Assert.Empty(plan.CambiosDesacople);
        Assert.Equal(0, plan.Publicado[BeigeXl]);
        Assert.Equal([BeigeXl], plan.PoolsAEnviar);
    }

    [Fact]
    public void DesacopladoConUltimoEnviadoDistintoDeCeroSeCorrigeACero()
    {
        // El estado del incidente del 10/10: desacoplado, pero en Tiendanube quedó publicado 3.
        var plan = StockSync.Planificar(
            Estado(3, 20, new() { [BeigeXl] = 3, [NegroS] = 20 }, new() { [BeigeXl] = 3 }), []);

        Assert.Equal([BeigeXl], plan.PoolsAEnviar);
        Assert.All(plan.Envios, e => Assert.Equal(0, e.Stock));
    }

    [Fact]
    public void BajaPorMovimientoManualSinPedidosTambienDesacopla()
    {
        // negro_regular_s bajó a 2 por una venta en negro cargada a mano, sin pedidos en la tienda.
        var plan = StockSync.Planificar(
            Estado(10, 2, new() { [BeigeXl] = 10, [NegroS] = 3 }, []), []);

        Assert.Equal(new CambioDesacople(NegroS, TipoCambioDesacople.Desacoplado, 2), Assert.Single(plan.CambiosDesacople));
        Assert.Equal([NegroS], plan.PoolsAEnviar);
        Assert.Equal(0, Assert.Single(plan.Envios).Stock);
    }

    [Fact]
    public void FamiliaSinDesacopleNuncaDesacopla()
    {
        // Buzos, pantalones, conjuntos y pool manual: se publica el real hasta llegar a 0.
        var plan = StockSync.Planificar(
            Estado(4, 20, new() { [BeigeXl] = 4, [NegroS] = 20 }, desacoples: null), [Pedido(1001, 101, 3)]);

        Assert.Empty(plan.CambiosDesacople);
        Assert.Equal(1, plan.Publicado[BeigeXl]);
        Assert.All(plan.Envios, e => Assert.Equal(1, e.Stock));
    }
}
