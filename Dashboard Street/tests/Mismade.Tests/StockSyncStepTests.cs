using Mismade.Application;
using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

public sealed class StockSyncStepTests
{
    private static FamiliaStock Remeras(int stock = 30, long watermark = 1000, bool tieneWatermark = true,
        Dictionary<string, int>? enviado = null) => new("remeras", new EstadoSync(
        new Dictionary<string, int> { ["crema_oversize_s"] = stock, ["negro_oversize_xl"] = 5 },
        [
            new("crema_oversize_s", 10, 101), new("crema_oversize_s", 20, 201),
            new("negro_oversize_xl", 10, 102),
        ],
        new HashSet<long>(),
        enviado ?? new Dictionary<string, int> { ["crema_oversize_s"] = stock, ["negro_oversize_xl"] = 5 },
        watermark), tieneWatermark);

    private static FamiliaStock Buzo(long watermark) => new("manual:buzo_negro_xxl_regular", new EstadoSync(
        new Dictionary<string, int> { ["manual:buzo_negro_xxl_regular"] = 4 },
        [new("manual:buzo_negro_xxl_regular", 50, 501)],
        new HashSet<long>(),
        new Dictionary<string, int> { ["manual:buzo_negro_xxl_regular"] = 4 },
        watermark), true);

    private static PedidoTiendanube Pedido(long number, params (long variant, int qty)[] lineas) =>
        new(number, number, DateTimeOffset.UtcNow, 10000, "paid", "mercadopago", null, null,
            lineas.Select(l => new LineaPedido(0, l.variant, l.qty)).ToList());

    [Fact]
    public async Task SinTiendanubeConectadaNoFallaYDejaNota()
    {
        var store = new FakeStore(Remeras());
        var step = new StockSyncStep(store, new FakeTiendanube(), new FakeCredenciales(conectada: false));
        var detalle = new SyncDetalle();

        Assert.Null(await step.RunAsync(detalle, CancellationToken.None));
        Assert.Contains(detalle.Notas, n => n.Contains("sin conectar"));
        Assert.Equal(0, store.Aplicados);
    }

    [Fact]
    public async Task SinWatermarkInicializaYNoDescuentaPedidosViejos()
    {
        var store = new FakeStore(Remeras(tieneWatermark: false, watermark: 0));
        var tn = new FakeTiendanube(ultimo: 5432) { Pedidos = [Pedido(5000, (101, 10))] };
        var detalle = new SyncDetalle();

        await new StockSyncStep(store, tn, new FakeCredenciales()).RunAsync(detalle, CancellationToken.None);

        Assert.Equal(("remeras", 5432L), Assert.Single(store.Inicializados));
        Assert.Equal(0, store.Aplicados);
        Assert.Equal(0, tn.PedidosConsultados);
        Assert.Contains(detalle.Notas, n => n.Contains("#5432"));
    }

    [Fact]
    public async Task FlujoNormalGuardaEnviaYMarca()
    {
        var store = new FakeStore(Remeras());
        var tn = new FakeTiendanube { Pedidos = [Pedido(1001, (101, 2))] };
        var detalle = new SyncDetalle();

        Assert.Null(await new StockSyncStep(store, tn, new FakeCredenciales()).RunAsync(detalle, CancellationToken.None));

        Assert.Equal(1, store.Aplicados);
        var envio = Assert.Single(tn.Envios);
        Assert.Equal([101L, 201L], envio.Select(v => v.VariantId).Order());
        Assert.All(envio, v => Assert.Equal(28, v.Stock));
        Assert.Equal(("crema_oversize_s", 28), Assert.Single(store.Marcados));
        Assert.Equal(["crema_oversize_s"], detalle.PoolsEnviados);
        Assert.Equal(1, detalle.PedidosProcesados);
    }

    [Fact]
    public async Task EnvioFallidoNoMarcaEsePoolPeroSigueConLosDemas()
    {
        var store = new FakeStore(Remeras(enviado: []));
        var tn = new FakeTiendanube { FallarVariante = 102 };
        var detalle = new SyncDetalle();

        var error = await new StockSyncStep(store, tn, new FakeCredenciales()).RunAsync(detalle, CancellationToken.None);

        Assert.NotNull(error);
        Assert.Equal(["negro_oversize_xl"], detalle.PoolsFallidos);
        Assert.Equal(["crema_oversize_s"], detalle.PoolsEnviados);
        Assert.DoesNotContain(store.Marcados, m => m.Pool == "negro_oversize_xl");
    }

    [Fact]
    public async Task PedidosSeTraenUnaVezDesdeElMenorWatermarkYCadaPoolUsaElSuyo()
    {
        var store = new FakeStore(Remeras(watermark: 1000), Buzo(watermark: 990));
        var tn = new FakeTiendanube { Pedidos = [Pedido(995, (501, 1)), Pedido(1001, (501, 1), (101, 1))] };
        var detalle = new SyncDetalle();

        await new StockSyncStep(store, tn, new FakeCredenciales()).RunAsync(detalle, CancellationToken.None);

        Assert.Equal([990L], tn.Desdes);
        // El buzo descuenta los dos pedidos; las remeras solo el 1001 (el 995 ya lo tenían).
        Assert.Contains(store.Marcados, m => m == ("manual:buzo_negro_xxl_regular", 2));
        Assert.Contains(store.Marcados, m => m == ("crema_oversize_s", 29));
    }

    [Fact]
    public async Task SobreventaQuedaComoAlertaEnElDetalle()
    {
        var store = new FakeStore(Remeras());
        var tn = new FakeTiendanube { Pedidos = [Pedido(1001, (102, 8))] };
        var detalle = new SyncDetalle();

        await new StockSyncStep(store, tn, new FakeCredenciales()).RunAsync(detalle, CancellationToken.None);

        var alerta = Assert.Single(detalle.Alertas);
        Assert.Equal(new AlertaDetalle("negro_oversize_xl", "Sobreventa", 3), alerta);
    }

    [Theory]
    [InlineData("Gris Prelavado", "Oversize", "XL", "gris_prelavado_oversize_xl")]
    [InlineData(" Crema ", "Oversize", "s", "crema_oversize_s")]
    public void PoolKeyDeRemera(string color, string corte, string talle, string esperado) =>
        Assert.Equal(esperado, PoolKeys.Remera(color, corte, talle));

    [Fact]
    public void PoolKeyManualYLegible()
    {
        Assert.Equal("manual:buzo_negro_xxl_regular", PoolKeys.Manual("Buzo Negro XXL Regular"));
        Assert.Equal("Buzo negro xxl regular", PoolKeys.Legible("manual:buzo_negro_xxl_regular"));
        Assert.Equal("Crema oversize s", PoolKeys.Legible("crema_oversize_s"));
    }

    // ---------- fakes ----------

    private sealed class FakeStore(params FamiliaStock[] familias) : IStockSyncStore
    {
        public int Aplicados { get; private set; }
        public List<(string Pool, int Stock)> Marcados { get; } = [];
        public List<(string Clave, long Number)> Inicializados { get; } = [];

        public Task<IReadOnlyList<FamiliaStock>> CargarAsync(CancellationToken ct) =>
            Task.FromResult<IReadOnlyList<FamiliaStock>>(familias);

        public Task<PlanSync> AplicarAsync(string clave, Func<EstadoSync, PlanSync> planificar, CancellationToken ct)
        {
            Aplicados++;
            return Task.FromResult(planificar(familias.Single(f => f.Clave == clave).Estado));
        }

        public Task MarcarEnviadoAsync(string poolKey, int stock, CancellationToken ct)
        {
            Marcados.Add((poolKey, stock));
            return Task.CompletedTask;
        }

        public Task InicializarWatermarkAsync(string clave, long orderNumber, CancellationToken ct)
        {
            Inicializados.Add((clave, orderNumber));
            return Task.CompletedTask;
        }
    }

    private sealed class FakeTiendanube(long ultimo = 0) : ITiendanubeClient
    {
        public List<PedidoTiendanube> Pedidos { get; init; } = [];
        public List<IReadOnlyList<VarianteTiendanube>> Envios { get; } = [];
        public List<long> Desdes { get; } = [];
        public int PedidosConsultados => Desdes.Count;
        public long? FallarVariante { get; init; }

        public Task<string> GetStoreNameAsync(CancellationToken ct) => Task.FromResult("Test");

        public Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desde, CancellationToken ct)
        {
            Desdes.Add(desde);
            return Task.FromResult<IReadOnlyList<PedidoTiendanube>>(Pedidos.Where(p => p.Number > desde).ToList());
        }

        public Task<long> GetLatestOrderNumberAsync(CancellationToken ct) => Task.FromResult(ultimo);

        public Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long productId, CancellationToken ct) =>
            Task.FromResult<IReadOnlyList<VarianteTiendanube>>([]);

        public Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct)
        {
            if (variantes.Any(v => v.VariantId == FallarVariante))
            {
                throw new HttpRequestException("HTTP 500");
            }

            Envios.Add(variantes);
            return Task.CompletedTask;
        }
    }

    private sealed class FakeCredenciales(bool conectada = true) : ITiendanubeCredenciales
    {
        public Task<(long StoreId, string Token)?> GetAsync(CancellationToken ct) =>
            Task.FromResult<(long, string)?>(conectada ? (1, "t") : null);

        public Task SaveAsync(long storeId, string token, string scope, string connectedBy, CancellationToken ct) =>
            Task.CompletedTask;

        public Task DeleteAsync(long storeId, CancellationToken ct) => Task.CompletedTask;
    }
}
