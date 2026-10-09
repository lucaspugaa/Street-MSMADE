using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class MetaInsightStore(IDbContextFactory<MismadeDbContext> factory) : IMetaInsightStore
{
    public async Task<bool> TieneFilasAsync(CuentaMeta cuenta, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var nombre = cuenta.ToString();
        return await db.MetaInsights.AnyAsync(x => x.Cuenta == nombre, ct);
    }

    public async Task ReemplazarAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta,
        IReadOnlyList<MetaInsight> filas, CancellationToken ct)
    {
        if (desde > hasta || filas.Any(x => x.Cuenta != cuenta || x.Fecha < desde || x.Fecha > hasta))
        {
            throw new InvalidOperationException("Los insights no corresponden a la cuenta o al rango solicitado.");
        }

        await using var db = await factory.CreateDbContextAsync(ct);
        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        var nombre = cuenta.ToString();
        await db.MetaInsights.Where(x => x.Cuenta == nombre && x.Fecha >= desde && x.Fecha <= hasta)
            .ExecuteDeleteAsync(ct);

        var ahora = DateTimeOffset.UtcNow;
        db.MetaInsights.AddRange(filas.Select(x => new MetaInsightEntity
        {
            Cuenta = nombre,
            Fecha = x.Fecha,
            CampaignId = x.CampaignId,
            CampaignName = x.CampaignName,
            Gasto = x.Gasto,
            Impresiones = x.Impresiones,
            Clicks = x.Clicks,
            Compras = x.Compras,
            ValorCompras = x.ValorCompras,
            ActualizadoEn = ahora
        }));

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);
    }

    public async Task<decimal> GastoAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var nombre = cuenta.ToString();
        return await db.MetaInsights.Where(x => x.Cuenta == nombre && x.Fecha >= desde && x.Fecha <= hasta)
            .SumAsync(x => x.Gasto, ct);
    }
}
