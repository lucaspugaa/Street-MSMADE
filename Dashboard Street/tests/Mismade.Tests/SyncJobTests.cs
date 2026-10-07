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
        await new SyncJob(new FakeLock(null), store, notifier).RunAsync("Test", CancellationToken.None);

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
        await new SyncJob(new FakeLock(lease), store, notifier).RunAsync("Test", CancellationToken.None);

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
            new SyncJob(new FakeLock(lease), store, new FakeNotifier()).RunAsync("Test", cts.Token));

        Assert.Equal(EstadoJob.Failed, store.Run!.Status);
        Assert.NotNull(store.Run.Error);
        Assert.NotNull(store.Run.FinishedAt);
        Assert.False(store.LastToken.IsCancellationRequested);
        Assert.True(lease.Disposed);
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
