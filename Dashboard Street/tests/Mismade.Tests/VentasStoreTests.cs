using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class VentasStoreTests
{
    [Fact]
    public async Task UpsertIdempotenteReemplazaItemsYActualizaCancelacion()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new VentasStore(factory);
        var orden = VentasSyncStepTests.Orden(1, VentasSyncStepTests.Ahora);
        Assert.Equal(new VentasUpsertResultado(1, 0), await store.UpsertAsync([orden, orden], default));
        Assert.Equal(new VentasUpsertResultado(0, 1), await store.UpsertAsync([orden], default));
        Assert.Single(await db.Ventas.AsNoTracking().ToListAsync());
        Assert.Single(await db.VentaItems.AsNoTracking().ToListAsync());
        var cancelada = orden with
        {
            UpdatedAtTiendanube = orden.UpdatedAtTiendanube.AddHours(1),
            CancelledAt = orden.CreatedAt.AddHours(1), Status = "cancelled", PaymentStatus = "refunded",
            Items = [new(9, 10, 2, 50, "Otra remera", null)]
        };
        await store.UpsertAsync([cancelada], default);
        var venta = await db.Ventas.AsNoTracking().Include(x => x.Items).SingleAsync();
        Assert.Equal("cancelled", venta.Status);
        Assert.Equal("refunded", venta.PaymentStatus);
        Assert.Equal(cancelada.CancelledAt, venta.CancelledAt);
        Assert.Equal(9, Assert.Single(venta.Items).ProductId);
        Assert.Single(await db.VentaItems.AsNoTracking().ToListAsync());
        // El reintento de una versión vieja no revierte una cancelación más reciente.
        Assert.Equal(new VentasUpsertResultado(0, 0), await store.UpsertAsync([orden], default));
        Assert.Equal("cancelled", (await db.Ventas.AsNoTracking().SingleAsync()).Status);

        Assert.Null(await store.GetEstadoAsync(default));
        await store.SetEstadoAsync(new() { UltimoUpdatedAt = orden.UpdatedAtTiendanube, HistorialDesde = orden.CreatedAt }, default);
        await store.SetEstadoAsync(new() { UltimoUpdatedAt = orden.UpdatedAtTiendanube.AddMinutes(-1) }, default);
        Assert.Equal(orden.UpdatedAtTiendanube, (await store.GetEstadoAsync(default))!.UltimoUpdatedAt);
        Assert.Single(await db.VentasSyncEstados.ToListAsync());
    }

    [Fact]
    public async Task LoteFallidoRevierteVentasEItems()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new VentasStore(factory);
        var orden = VentasSyncStepTests.Orden(1, VentasSyncStepTests.Ahora);
        await store.UpsertAsync([orden], default);
        await db.Database.ExecuteSqlRawAsync("""
            CREATE TRIGGER fallar_venta BEFORE INSERT ON VentaItems
            WHEN NEW.ProductId = 99
            BEGIN SELECT RAISE(ABORT, 'inserción fallida'); END;
            """);
        await Assert.ThrowsAsync<DbUpdateException>(() => store.UpsertAsync(
            [orden with { Total = 50, Items = [new(99, 1, 1, 50, "Falla", null)] }], default));
        Assert.Equal(100, (await db.Ventas.AsNoTracking().SingleAsync()).Total);
        Assert.Equal(7, (await db.VentaItems.AsNoTracking().SingleAsync()).ProductId);
    }

    [Fact]
    public async Task FacturacionFiltraPagosCancelacionesYUsaFechaEfectivaEnHoraArgentina()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new VentasStore(factory);
        Assert.False(await store.TieneVentasAsync(default));
        Assert.Equal(new FacturacionPeriodo(0, 0), await store.FacturacionAsync(
            VentasSyncStepTests.Ahora.AddDays(-1), VentasSyncStepTests.Ahora, default));
        var fechas = new[]
        {
            "2026-10-10T02:59:59Z", // Ayer en Argentina.
            "2026-10-10T03:00:00Z", // Hoy, inclusive.
            "2026-10-11T02:59:59Z", // Hoy hasta antes de medianoche.
            "2026-10-11T03:00:00Z", // Mañana, exclusivo.
            "2026-10-01T02:59:59Z", // Mes anterior.
            "2026-10-01T03:00:00Z", // Primer instante del mes.
            "2026-01-01T02:59:59Z", // Año anterior.
            "2026-01-01T03:00:00Z"  // Primer instante del año.
        };
        var ordenes = fechas.Select((fecha, i) => VentasSyncStepTests.Orden(i + 1, DateTimeOffset.Parse(fecha))
            with { PaidAt = null }).ToList();
        var hoy = DateTimeOffset.Parse("2026-10-10T12:00:00Z");
        ordenes.AddRange([
            VentasSyncStepTests.Orden(10, hoy) with { PaymentStatus = "pending" },
            VentasSyncStepTests.Orden(11, hoy) with { PaymentStatus = "refunded" },
            VentasSyncStepTests.Orden(12, hoy) with { CancelledAt = hoy },
            VentasSyncStepTests.Orden(13, hoy) with { Status = "cancelled" },
            VentasSyncStepTests.Orden(14, hoy) with { Status = "closed" }
        ]);
        await store.UpsertAsync(ordenes, default);
        var resumen = await new FinanzasConsulta(store, new VentasSyncStepTests.Clock()).ConsultarAsync(default);
        Assert.True(resumen.TieneVentas);
        Assert.Equal(new FacturacionPeriodo(300, 3), resumen.Hoy);
        Assert.Equal(new FacturacionPeriodo(600, 6), resumen.Mes);
        Assert.Equal(new FacturacionPeriodo(800, 8), resumen.Anio);
    }

    [Fact]
    public async Task MadrugadaUtcTodaviaPerteneceAlDiaMesYAnioAnteriorEnArgentina()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new VentasStore(factory);
        await store.UpsertAsync([
            VentasSyncStepTests.Orden(1, DateTimeOffset.Parse("2025-12-31T03:00:00Z")),
            VentasSyncStepTests.Orden(2, DateTimeOffset.Parse("2026-01-01T03:00:00Z"))
        ], default);
        var consulta = new FinanzasConsulta(store, new Reloj(DateTimeOffset.Parse("2026-01-01T02:30:00Z")));
        var resumen = await consulta.ConsultarAsync(default);
        Assert.Equal(new FacturacionPeriodo(100, 1), resumen.Hoy);
        Assert.Equal(new FacturacionPeriodo(100, 1), resumen.Mes);
        Assert.Equal(new FacturacionPeriodo(100, 1), resumen.Anio);
    }

    [Fact]
    public async Task CompletedAtSeActualizaSinDuplicarVentaYLaFechaGanaSobreElPago()
    {
        using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using var db = factory.CreateDbContext();
        await db.Database.EnsureCreatedAsync();
        var store = new VentasStore(factory);
        var orden = VentasSyncStepTests.Orden(1, DateTimeOffset.Parse("2026-10-11T12:00:00Z"));
        await store.UpsertAsync([orden], default);
        var completada = orden with { CompletedAt = DateTimeOffset.Parse("2026-10-10T23:00:00-03:00"), Total = 39395.18m };
        await store.UpsertAsync([completada], default);
        await store.UpsertAsync([completada], default);
        var venta = Assert.Single(await db.Ventas.AsNoTracking().ToListAsync());
        Assert.Equal(DateTimeOffset.Parse("2026-10-11T02:00:00Z"), venta.CompletedAt);
        Assert.Equal(1, (await store.FacturacionAsync(DateTimeOffset.Parse("2026-10-10T03:00:00Z"),
            DateTimeOffset.Parse("2026-10-11T03:00:00Z"), default)).Pedidos);
        Assert.Equal(0, (await store.FacturacionAsync(DateTimeOffset.Parse("2026-10-11T03:00:00Z"),
            DateTimeOffset.Parse("2026-10-12T03:00:00Z"), default)).Pedidos);
        await store.SetEstadoAsync(new() { UltimoUpdatedAt = orden.UpdatedAtTiendanube, CompletedAtBackfillDone = true }, default);
        await store.SetEstadoAsync(new() { UltimoUpdatedAt = orden.UpdatedAtTiendanube }, default);
        Assert.True((await store.GetEstadoAsync(default))!.CompletedAtBackfillDone);
    }

    private sealed class Reloj(DateTimeOffset ahora) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => ahora;
    }

    [Fact]
    public void ModeloPostgresConfiguraIndicesCascadaYPrecision()
    {
        using var db = new MismadeDbContext(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseNpgsql("Host=localhost;Database=test;Username=test;Password=test").Options);
        var venta = db.Model.FindEntityType(typeof(Venta))!;
        Assert.Contains(venta.GetIndexes(), x => x.IsUnique && x.Properties.Single().Name == nameof(Venta.TiendanubeOrderId));
        Assert.Contains(venta.GetIndexes(), x => x.Properties.Single().Name == nameof(Venta.Number));
        Assert.Equal(14, venta.FindProperty(nameof(Venta.Total))!.GetPrecision());
        Assert.Equal(2, venta.FindProperty(nameof(Venta.Total))!.GetScale());
        Assert.Equal(DeleteBehavior.Cascade, db.Model.FindEntityType(typeof(VentaItem))!.GetForeignKeys().Single().DeleteBehavior);
        var sql = db.Ventas.Where(FinanzasConsulta.EnPeriodo(VentasSyncStepTests.Ahora, VentasSyncStepTests.Ahora.AddDays(1)))
            .GroupBy(x => 1).Select(g => new FacturacionPeriodo(g.Sum(x => x.Total), g.Count())).ToQueryString();
        Assert.Contains("CompletedAt", sql);
        Assert.Contains("PaidAt", sql);
        Assert.Contains("CreatedAt", sql);
        Assert.Contains("sum", sql, StringComparison.OrdinalIgnoreCase);
    }

    private sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() => new(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseSqlite(connection).ReplaceService<IModelCustomizer, SqliteModel>().Options);
    }

    // SQLite no tiene comparación nativa de DateTimeOffset ni SUM de decimal.
    // Solo el modelo de pruebas convierte estos campos; PostgreSQL conserva timestamptz y numeric.
    public sealed class SqliteModel(ModelCustomizerDependencies dependencies) : ModelCustomizer(dependencies)
    {
        public override void Customize(ModelBuilder modelBuilder, DbContext context)
        {
            base.Customize(modelBuilder, context);
            foreach (var entity in modelBuilder.Model.GetEntityTypes()
                .Where(x => x.ClrType == typeof(Venta) || x.ClrType == typeof(VentasSyncEstado)))
            {
                foreach (var property in entity.GetProperties())
                {
                    if (property.ClrType == typeof(DateTimeOffset) || property.ClrType == typeof(DateTimeOffset?))
                    {
                        property.SetValueConverter(new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTimeOffset, long>(
                            x => x.UtcTicks, x => new DateTimeOffset(x, TimeSpan.Zero)));
                    }
                    else if (property.ClrType == typeof(decimal))
                    {
                        property.SetValueConverter(new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<decimal, double>(
                            x => (double)x, x => (decimal)x));
                    }
                }
            }
        }
    }
}
