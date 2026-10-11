using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class StockSyncStoreTests
{
    [Fact]
    public async Task DesacoplesSeCarganYSeGuardanSegunElPlan()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using (var db = factory.CreateDbContext())
        {
            // xmin es columna de sistema de PostgreSQL; en SQLite hay que darle un valor por defecto.
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            var beigeS = new StockRemera { Color = "Beige", Corte = "Oversize", Talle = "S", Stock = 1 };
            var beigeXl = new StockRemera { Color = "Beige", Corte = "Regular", Talle = "XL", Stock = 5 };
            var negroS = new StockRemera { Color = "Negro", Corte = "Regular", Talle = "S", Stock = 2 };
            db.StockRemeras.AddRange(beigeS, beigeXl, negroS);
            db.StockVariantMaps.AddRange(
                new StockVariantMap { StockRemera = beigeS, TiendanubeProductId = 1, TiendanubeVariantId = 11 },
                new StockVariantMap { StockRemera = beigeXl, TiendanubeProductId = 1, TiendanubeVariantId = 12 },
                new StockVariantMap { StockRemera = negroS, TiendanubeProductId = 1, TiendanubeVariantId = 13 });
            db.StockDesacoples.AddRange(
                new StockDesacople { PoolKey = "beige_oversize_s", StockAtDecouple = 1, AutoCreated = true },
                new StockDesacople { PoolKey = "beige_regular_xl", StockAtDecouple = 3, AutoCreated = true });
            db.SyncWatermarks.Add(new SyncWatermark { Clave = StockSyncStore.RemerasClave, LastOrderNumberSynced = 1789 });
            await db.SaveChangesAsync();
        }

        var store = new StockSyncStore(factory);
        var remeras = Assert.Single(await store.CargarAsync(default));
        Assert.Equal(new Dictionary<string, int> { ["beige_oversize_s"] = 1, ["beige_regular_xl"] = 3 },
            remeras.Estado.Desacoples);

        // beige_regular_xl en 5 > 3: se reactiva; negro_regular_s en 2: se desacopla; beige_oversize_s sigue igual.
        var plan = await store.AplicarAsync(StockSyncStore.RemerasClave, e => StockSync.Planificar(e, []), default);
        Assert.Equal(2, plan.CambiosDesacople.Count);

        await using var verificacion = factory.CreateDbContext();
        var desacoples = await verificacion.StockDesacoples.OrderBy(d => d.PoolKey).ToListAsync();
        Assert.Equal(["beige_oversize_s", "negro_regular_s"], desacoples.Select(d => d.PoolKey));
        var negro = desacoples[1];
        Assert.Equal((2, true), (negro.StockAtDecouple, negro.AutoCreated));
        Assert.StartsWith("auto:", negro.Reason);
    }

    private sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() =>
            new(new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection).Options);
    }
}
