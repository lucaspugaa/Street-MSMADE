using System.Threading.Channels;
using Hangfire;
using Hangfire.Dashboard;
using Mismade.Application;

namespace Mismade.Web;

public sealed class SyncQueue : ISyncQueue
{
    private readonly Channel<string> channel = Channel.CreateBounded<string>(new BoundedChannelOptions(100)
    {
        SingleReader = true,
        FullMode = BoundedChannelFullMode.Wait
    });

    public ValueTask EnqueueAsync(string trigger, CancellationToken ct = default)
        => channel.Writer.WriteAsync(trigger, ct);

    public IAsyncEnumerable<string> ReadAllAsync(CancellationToken ct) => channel.Reader.ReadAllAsync(ct);
}

public sealed class SyncWorker(SyncQueue queue, IServiceScopeFactory scopes, ILogger<SyncWorker> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {
            await foreach (var trigger in queue.ReadAllAsync(stoppingToken))
            {
                await using var scope = scopes.CreateAsyncScope();
                try
                {
                    await scope.ServiceProvider.GetRequiredService<SyncJob>().RunAsync(trigger, stoppingToken);
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception error)
                {
                    logger.LogError(error, "Falló el job de sincronización ({Trigger})", trigger);
                }
            }
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            // Cierre normal del consumidor al detener el host.
        }
    }
}

public sealed class HangfireSyncQueue(IBackgroundJobClient client) : ISyncQueue
{
    public ValueTask EnqueueAsync(string trigger, CancellationToken ct = default)
    {
        ct.ThrowIfCancellationRequested();
        client.Enqueue<SyncJob>(job => job.RunAsync(trigger, CancellationToken.None));
        return ValueTask.CompletedTask;
    }
}

public sealed class OwnerDashboardAuthorization : IDashboardAuthorizationFilter
{
    public bool Authorize(DashboardContext context) => context.GetHttpContext().User.IsInRole("Owner");
}
