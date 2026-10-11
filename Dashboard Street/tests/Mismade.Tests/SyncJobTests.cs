using Mismade.Application;
using Mismade.Domain;
using Xunit;

namespace Mismade.Tests;

public class SyncJobTests
{
    [Fact]
    public async Task SinLockRegistraSkipped()
    {
        var store = new FakeStore();
        var notifier = new FakeNotifier();
        await new SyncJob(new FakeLock(null), store, notifier, new FakeStock(), new FakeMeta(), new FakeVentas(), new FakeFinanzas()).RunAsync("Test", CancellationToken.None);

        Assert.Equal(EstadoJob.Skipped, store.Run!.Status);
        Assert.NotNull(store.Run.FinishedAt);
        Assert.Equal("Test", store.Run.Trigger);
        Assert.Equal(1, store.Saves);
        Assert.Equal(1, notifier.Notificaciones);
    }

    [Fact]
    public async Task ConLockCierraSucceededYLiberaLease()
    {
        var store = new FakeStore();
        var lease = new FakeLease();
        var notifier = new FakeNotifier();
        await new SyncJob(new FakeLock(lease), store, notifier, new FakeStock(), new FakeMeta(), new FakeVentas(), new FakeFinanzas()).RunAsync("Test", CancellationToken.None);

        Assert.Equal(EstadoJob.Succeeded, store.Run!.Status);
        Assert.NotNull(store.Run.FinishedAt);
        Assert.True(lease.Disposed);
        Assert.Equal(2, store.Saves);
        Assert.Equal(1, notifier.Notificaciones);
    }

    [Fact]
    public async Task CancelacionRegistraFailedAunqueTokenCancelado()
    {
        using var cts = new CancellationTokenSource();
        cts.Cancel();
        var store = new FakeStore();
        var lease = new FakeLease();

        await Assert.ThrowsAsync<OperationCanceledException>(() =>
            new SyncJob(new FakeLock(lease), store, new FakeNotifier(), new FakeStock(), new FakeMeta(), new FakeVentas(), new FakeFinanzas()).RunAsync("Test", cts.Token));

        Assert.Equal(EstadoJob.Failed, store.Run!.Status);
        Assert.NotNull(store.Run.Error);
        Assert.NotNull(store.Run.FinishedAt);
        Assert.False(store.LastToken.IsCancellationRequested);
        Assert.True(lease.Disposed);
    }

    [Fact]
    public async Task EnvioDeStockFallidoDejaFailedConElDetalleGuardado()
    {
        var store = new FakeStore();
        var stock = new FakeStock(detalle =>
        {
            detalle.PedidosProcesados = 3;
            detalle.PoolsEnviados.Add("crema_oversize_s");
            detalle.PoolsFallidos.Add("negro_oversize_xl");
            return new HttpRequestException("HTTP 500");
        });

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            new SyncJob(new FakeLock(new FakeLease()), store, new FakeNotifier(), stock, new FakeMeta(), new FakeVentas(), new FakeFinanzas()).RunAsync("Test", CancellationToken.None));

        Assert.Equal(EstadoJob.Failed, store.Run!.Status);
        Assert.Equal(3, store.Run.OrdersProcessed);
        Assert.Equal(1, store.Run.CombinationsPushed);
        Assert.Contains("negro_oversize_xl", store.Run.Detalle);
    }

    [Fact]
    public async Task CorridaExitosaGuardaContadoresYDetalle()
    {
        var store = new FakeStore();
        var stock = new FakeStock(detalle =>
        {
            detalle.PedidosProcesados = 2;
            detalle.PoolsEnviados.AddRange(["a", "b"]);
            detalle.Notas.Add("ok");
            return null;
        });

        await new SyncJob(new FakeLock(new FakeLease()), store, new FakeNotifier(), stock, new FakeMeta(), new FakeVentas(), new FakeFinanzas()).RunAsync("Test", CancellationToken.None);

        Assert.Equal(EstadoJob.Succeeded, store.Run!.Status);
        Assert.Equal(2, store.Run.OrdersProcessed);
        Assert.Equal(2, store.Run.CombinationsPushed);
        Assert.Contains("ok", store.Run.Detalle);
    }

    [Fact]
    public async Task FalloMetaDejaFailedConAvisoYDetalleAunqueStockSeComplete()
    {
        var store = new FakeStore();
        var stock = new FakeStock(detalle =>
        {
            detalle.PoolsEnviados.Add("a");
            return null;
        });
        await new SyncJob(new FakeLock(new FakeLease()), store, new FakeNotifier(), stock, new FailedMeta(), new FakeVentas(), new FakeFinanzas())
            .RunAsync("Test", default);
        Assert.Equal(EstadoJob.Failed, store.Run!.Status);
        Assert.Equal(1, store.Run.CombinationsPushed);
        Assert.Contains("Street", store.Run.Error);
        var detalle = System.Text.Json.JsonSerializer.Deserialize<SyncDetalle>(store.Run.Detalle!);
        Assert.Contains(detalle!.Meta, x => x.Cuenta == CuentaMeta.Kumo && x.Estado == "ok");
    }

    [Theory]
    [InlineData(0, 4, 4)]
    [InlineData(6, 4, 6)]
    public async Task VentasFallidasNoBloqueanStockNiMetaYGuardaMayorContador(int pedidosStock, int ventasNuevas, int esperado)
    {
        var store = new FakeStore();
        var stockCorrio = false;
        var metaCorrio = false;
        var ventas = new FakeVentas(detalle =>
        {
            detalle.VentasNuevas = ventasNuevas;
            detalle.ErrorVentas = "Falló ventas";
        });
        var stock = new FakeStock(detalle =>
        {
            stockCorrio = true;
            Assert.Equal("Falló ventas", detalle.ErrorVentas);
            detalle.PedidosProcesados = pedidosStock;
            return null;
        });
        var meta = new FakeMeta(() => metaCorrio = true);
        await new SyncJob(new FakeLock(new FakeLease()), store, new FakeNotifier(), stock, meta, ventas, new FakeFinanzas())
            .RunAsync("Test", default);
        Assert.True(stockCorrio);
        Assert.True(metaCorrio);
        Assert.Equal(EstadoJob.Failed, store.Run!.Status);
        Assert.Contains("Falló ventas", store.Run.Error);
        Assert.Equal(esperado, store.Run.OrdersProcessed);
    }

    [Fact]
    public async Task FinanzasCreaPendientesDespuesDeVentasYCierraDespuesDeMeta()
    {
        var pasos = new List<string>();
        var ventas = new FakeVentas(_ => pasos.Add("ventas"));
        var meta = new FakeMeta(() => pasos.Add("meta"));
        var finanzas = new FakeFinanzas(pasos);
        await new SyncJob(new FakeLock(new FakeLease()), new FakeStore(), new FakeNotifier(),
            new FakeStock(), meta, ventas, finanzas).RunAsync("Test", default);
        Assert.Equal(["ventas", "pending", "meta", "cierre"], pasos);
    }

    private sealed class FakeFinanzas(List<string>? pasos = null) : IFinanzasMargenService
    {
        public Task CrearPendientesAsync(CancellationToken ct = default)
        {
            pasos?.Add("pending");
            return Task.CompletedTask;
        }

        public Task CerrarMesesAsync(CancellationToken ct = default)
        {
            pasos?.Add("cierre");
            return Task.CompletedTask;
        }

        public Task<MargenPeriodo> ConsultarAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default) =>
            throw new NotSupportedException();
        public Task<bool> TieneDatosMetaStreetAsync(DateOnly desde, DateOnly hasta, CancellationToken ct = default) =>
            throw new NotSupportedException();
        public Task<IReadOnlyList<PagoNubeCuota>> PendientesAsync(CancellationToken ct = default) =>
            throw new NotSupportedException();
        public Task ConfirmarPagoNubeAsync(long number, EstadoPagoNube estado, CancellationToken ct = default) =>
            throw new NotSupportedException();
    }

    private sealed class FakeVentas(Action<SyncDetalle>? run = null) : IVentasSyncStep
    {
        public Task RunAsync(SyncDetalle detalle, CancellationToken ct)
        {
            run?.Invoke(detalle);
            return Task.CompletedTask;
        }
    }

    private sealed class FailedMeta : IMetaSyncStep
    {
        public Task RunAsync(SyncDetalle detalle, CancellationToken ct)
        {
            var fecha = new DateOnly(2026, 10, 9);
            detalle.Meta.Add(new(CuentaMeta.Street, "error", "Token vencido", 0, fecha, fecha));
            detalle.Meta.Add(new(CuentaMeta.Kumo, "ok", "Sincronizada", 1, fecha, fecha));
            return Task.CompletedTask;
        }
    }

    private sealed class FakeMeta(Action? run = null) : IMetaSyncStep
    {
        public Task RunAsync(SyncDetalle detalle, CancellationToken ct)
        {
            run?.Invoke();
            return Task.CompletedTask;
        }
    }

    private sealed class FakeStock(Func<SyncDetalle, Exception?>? run = null) : IStockSyncStep
    {
        public Task<Exception?> RunAsync(SyncDetalle detalle, CancellationToken ct) =>
            Task.FromResult(run?.Invoke(detalle));
    }

    private sealed class FakeLock(IAsyncDisposable? lease) : IJobLock
    {
        public Task<IAsyncDisposable?> TryAcquireAsync(CancellationToken ct) => Task.FromResult(lease);
    }

    private sealed class FakeLease : IAsyncDisposable
    {
        public bool Disposed { get; private set; }
        public ValueTask DisposeAsync()
        {
            Disposed = true;
            return ValueTask.CompletedTask;
        }
    }

    private sealed class FakeStore : IJobRunStore
    {
        public JobRun? Run { get; private set; }
        public int Saves { get; private set; }
        public CancellationToken LastToken { get; private set; }

        public Task SaveAsync(JobRun jobRun, CancellationToken ct)
        {
            Run = jobRun;
            Saves++;
            LastToken = ct;
            return Task.CompletedTask;
        }

        public Task<JobRun?> GetLatestAsync(CancellationToken ct) => Task.FromResult(Run);
    }

    private sealed class FakeNotifier : IDashboardNotifier
    {
        public event Action? Refrescar;
        public int Notificaciones { get; private set; }
        public void Notify()
        {
            Notificaciones++;
            Refrescar?.Invoke();
        }
    }
}
