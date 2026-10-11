using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class VentasSyncStepTests
{
    internal static readonly DateTimeOffset Ahora = DateTimeOffset.Parse("2026-10-10T12:00:00Z");

    [Theory]
    [InlineData(400)]
    [InlineData(30)]
    public async Task CargaInicialUsaHistorialConfiguradoYGuardaMaximo(int dias)
    {
        var store = new Store();
        var client = new Client { Ventas = [Orden(1, Ahora.AddHours(-2)), Orden(2, Ahora.AddHours(-1))] };
        var detalle = new SyncDetalle();
        await Step(store, client, dias).RunAsync(detalle, default);
        Assert.Equal(Ahora.AddDays(-dias), client.Desde);
        Assert.Equal(Ahora.AddHours(-1), store.Estado!.UltimoUpdatedAt);
        Assert.Equal(client.Desde, store.Estado.HistorialDesde);
        Assert.Equal(2, detalle.VentasNuevas);
        Assert.Contains(detalle.Notas, x => x.Contains("Carga inicial"));
        Assert.Equal(400, new TiendanubeOptions().HistorialVentasDias);
    }

    [Fact]
    public async Task IncrementalSolapaDiezMinutosYNoRetrocede()
    {
        var store = new Store { Estado = new() { UltimoUpdatedAt = Ahora, HistorialDesde = Ahora.AddDays(-400), CompletedAtBackfillDone = true } };
        var client = new Client { Ventas = [Orden(1, Ahora.AddMinutes(-5))] };
        var detalle = new SyncDetalle();
        await Step(store, client).RunAsync(detalle, default);
        Assert.Equal(Ahora.AddMinutes(-10), client.Desde);
        Assert.Equal(Ahora, store.Estado!.UltimoUpdatedAt);
        Assert.Equal(Ahora.AddDays(-400), store.Estado.HistorialDesde);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task ErrorDeLecturaOPersistenciaNoAvanzaCursor(bool alGuardar)
    {
        var store = new Store { Fallar = alGuardar, Estado = new() { UltimoUpdatedAt = Ahora } };
        var client = new Client { Error = alGuardar ? null : new HttpRequestException("fallo"), Ventas = [Orden(1, Ahora.AddHours(1))] };
        var detalle = new SyncDetalle();
        await Step(store, client).RunAsync(detalle, default);
        Assert.NotNull(detalle.ErrorVentas);
        Assert.Equal(Ahora, store.Estado!.UltimoUpdatedAt);
        Assert.Equal(0, store.EstadosGuardados);
        Assert.False(store.Estado.CompletedAtBackfillDone);
    }

    [Fact]
    public async Task CancelacionSePropaga()
    {
        var client = new Client { Error = new OperationCanceledException() };
        await Assert.ThrowsAsync<OperationCanceledException>(() => Step(new Store(), client).RunAsync(new(), default));
    }

    [Fact]
    public async Task DesconectadaNoConsultaPedidos()
    {
        var client = new Client();
        var detalle = new SyncDetalle();
        await new VentasSyncStep(new Store(), client, new Desconectada(), new TiendanubeOptions(), new Clock())
            .RunAsync(detalle, default);
        Assert.Null(client.Desde);
        Assert.Single(detalle.Notas);
    }

    [Fact]
    public async Task SinPedidosInicializaCursorEnInicioDelHistorial()
    {
        var store = new Store();
        await Step(store, new Client()).RunAsync(new(), default);
        Assert.Equal(Ahora.AddDays(-400), store.Estado!.UltimoUpdatedAt);
    }

    [Fact]
    public async Task BackfillDesdeHistorialUnaSolaVezYDespuesIncremental()
    {
        var inicio = Ahora.AddDays(-400);
        var store = new Store { Estado = new() { UltimoUpdatedAt = Ahora, HistorialDesde = inicio } };
        var client = new Client { Ventas = [Orden(1, Ahora) with { CompletedAt = Ahora.AddHours(-1) }] };
        var detalle = new SyncDetalle();
        await Step(store, client).RunAsync(detalle, default);
        Assert.Equal(inicio, client.Desde);
        Assert.True(store.Estado!.CompletedAtBackfillDone);
        Assert.Equal(Ahora, store.Estado.UltimoUpdatedAt);
        Assert.Contains(detalle.Notas, n => n.Contains("Recarga única"));

        await Step(store, client).RunAsync(new(), default);
        Assert.Equal(Ahora.AddMinutes(-10), client.Desde);
        Assert.Equal(inicio, store.Estado.HistorialDesde);
    }

    private static VentasSyncStep Step(Store store, Client client, int dias = 400) =>
        new(store, client, new FakeCredentials(), new TiendanubeOptions { HistorialVentasDias = dias }, new Clock());

    internal static VentaTiendanube Orden(long id, DateTimeOffset fecha) =>
        new(id, id, fecha, fecha, fecha, null, "open", "paid", 100, 100, 0, 0, 0,
            "offline", null, "ARS", null, null, null, [new(7, 8, 1, 100, "Remera", "R")]);

    internal sealed class Clock : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => Ahora;
    }

    private sealed class Store : IVentasStore
    {
        public VentasSyncEstado? Estado { get; set; }
        public bool Fallar { get; init; }
        public int EstadosGuardados { get; private set; }
        public Task<VentasSyncEstado?> GetEstadoAsync(CancellationToken ct) => Task.FromResult(Estado);
        public Task SetEstadoAsync(VentasSyncEstado estado, CancellationToken ct)
        {
            Estado = estado;
            EstadosGuardados++;
            return Task.CompletedTask;
        }
        public Task<VentasUpsertResultado> UpsertAsync(IReadOnlyList<VentaTiendanube> ventas, CancellationToken ct) =>
            Fallar ? throw new InvalidOperationException("fallo") : Task.FromResult(new VentasUpsertResultado(ventas.Count, 0));
        public Task<bool> TieneVentasAsync(CancellationToken ct) => Task.FromResult(false);
        public Task<FacturacionPeriodo> FacturacionAsync(DateTimeOffset desde, DateTimeOffset hasta, CancellationToken ct) =>
            Task.FromResult(new FacturacionPeriodo(0, 0));
    }

    private sealed class Client : ITiendanubeClient
    {
        public IReadOnlyList<VentaTiendanube> Ventas { get; init; } = [];
        public Exception? Error { get; init; }
        public DateTimeOffset? Desde { get; private set; }
        public Task<IReadOnlyList<VentaTiendanube>> GetOrdersUpdatedSinceAsync(DateTimeOffset desde, CancellationToken ct)
        {
            Desde = desde;
            return Error is null ? Task.FromResult(Ventas) : throw Error;
        }
        public Task<string> GetStoreNameAsync(CancellationToken ct) => throw new NotImplementedException();
        public Task<IReadOnlyList<PedidoTiendanube>> GetOrdersAsync(long desde, CancellationToken ct) => throw new NotImplementedException();
        public Task<long> GetLatestOrderNumberAsync(CancellationToken ct) => throw new NotImplementedException();
        public Task<IReadOnlyList<VarianteTiendanube>> GetProductVariantsAsync(long id, CancellationToken ct) => throw new NotImplementedException();
        public Task UpdateStockAsync(IReadOnlyList<VarianteTiendanube> variantes, CancellationToken ct) => throw new NotImplementedException();
    }

    private sealed class Desconectada : ITiendanubeCredenciales
    {
        public Task<(long StoreId, string Token)?> GetAsync(CancellationToken ct) => Task.FromResult<(long, string)?>(null);
        public Task SaveAsync(long id, string token, string scope, string by, CancellationToken ct) => throw new NotImplementedException();
        public Task DeleteAsync(long id, CancellationToken ct) => throw new NotImplementedException();
    }
}
