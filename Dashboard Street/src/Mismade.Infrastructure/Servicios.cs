using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class JobRunStore(IDbContextFactory<MismadeDbContext> factory) : IJobRunStore
{
    public async Task SaveAsync(JobRun jobRun, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);

        if (await db.JobRuns.AnyAsync(x => x.Id == jobRun.Id, ct))
        {
            db.Update(jobRun);
        }
        else
        {
            db.Add(jobRun);
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task<JobRun?> GetLatestAsync(CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        return await db.JobRuns.AsNoTracking().OrderByDescending(x => x.StartedAt).FirstOrDefaultAsync(ct);
    }
}

public sealed class DashboardNotifier : IDashboardNotifier
{
    public event Action? Refrescar;
    public void Notify() => Refrescar?.Invoke();
}
