using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class MetaInsightStoreTests
{
    private static readonly DateOnly Hoy = new(2026, 10, 9);

    [Fact]
    public async Task ReemplazaRangoInclusivoSinMezclarCuentasYBorraCampanasAusentes()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using (var db = factory.CreateDbContext())
        {
            await db.Database.EnsureCreatedAsync();
        }

        var store = new MetaInsightStore(factory);
        Assert.False(await store.TieneFilasAsync(CuentaMeta.Street, default));
        var ayer = Hoy.AddDays(-1);
        await store.ReemplazarAsync(CuentaMeta.Street, ayer, Hoy,
            [Row(CuentaMeta.Street, ayer, "fuera"), Row(CuentaMeta.Street, Hoy, "vieja")], default);
        await store.ReemplazarAsync(CuentaMeta.Kumo, Hoy, Hoy, [Row(CuentaMeta.Kumo, Hoy, "vieja")], default);
        await store.ReemplazarAsync(CuentaMeta.Street, Hoy, Hoy, [Row(CuentaMeta.Street, Hoy, "nueva")], default);

        await using var read = factory.CreateDbContext();
        var rows = await read.MetaInsights.AsNoTracking().ToListAsync();
        Assert.Equal(3, rows.Count);
        Assert.Contains(rows, x => x.Cuenta == "Street" && x.CampaignId == "fuera");
        Assert.Contains(rows, x => x.Cuenta == "Kumo" && x.CampaignId == "vieja");
        Assert.DoesNotContain(rows, x => x.Cuenta == "Street" && x.CampaignId == "vieja");
        Assert.All(rows, x => Assert.NotEqual(default, x.ActualizadoEn));
        Assert.True(await store.TieneFilasAsync(CuentaMeta.Street, default));

        await store.ReemplazarAsync(CuentaMeta.Street, Hoy, Hoy, [], default);
        Assert.Equal(2, await read.MetaInsights.CountAsync());
    }

    [Fact]
    public async Task InsercionFallidaRevierteBorradoYRechazaCuentaEquivocada()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new MetaInsightStore(factory);
        await store.ReemplazarAsync(CuentaMeta.Street, Hoy, Hoy, [Row(CuentaMeta.Street, Hoy, "original")], default);
        await Assert.ThrowsAsync<InvalidOperationException>(() => store.ReemplazarAsync(CuentaMeta.Street,
            Hoy, Hoy, [Row(CuentaMeta.Kumo, Hoy, "otra")], default));
        await Assert.ThrowsAsync<InvalidOperationException>(() => store.ReemplazarAsync(CuentaMeta.Street,
            Hoy, Hoy, [Row(CuentaMeta.Street, Hoy, "dup"), Row(CuentaMeta.Street, Hoy, "dup")], default));
        await db.Database.ExecuteSqlRawAsync("""
            CREATE TRIGGER fallar_meta BEFORE INSERT ON MetaInsights
            WHEN NEW.CampaignId = 'fallida'
            BEGIN SELECT RAISE(ABORT, 'insercion fallida'); END;
            """);
        await Assert.ThrowsAsync<DbUpdateException>(() => store.ReemplazarAsync(CuentaMeta.Street,
            Hoy, Hoy, [Row(CuentaMeta.Street, Hoy, "fallida")], default));
        Assert.Equal("original", (await db.MetaInsights.SingleAsync()).CampaignId);
    }

    private static MetaInsight Row(CuentaMeta cuenta, DateOnly fecha, string campaign) =>
        new(cuenta, fecha, campaign, campaign, 12.34m, 10, 2, 1, 100);

    private sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() => new(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseSqlite(connection).Options);
    }
}
