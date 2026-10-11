using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class PanelConsultasTests
{
    [Fact]
    public async Task RankingAgrupaPorIdOEmailYFiltraPagadosNoCancelados()
    {
        await using var fixture = await Fixture.CrearAsync();
        await using (var db = fixture.Factory.CreateDbContext())
        {
            db.Ventas.AddRange(
                Venta(1, 100, "2026-10-10T12:00:00Z", 7, "viejo@example.test"),
                Venta(2, 300, "2026-10-11T12:00:00Z", 7, "nuevo@example.test"),
                Venta(3, 50, "2026-10-10T12:00:00Z", null, "email@example.test"),
                Venta(4, 150, "2026-10-11T12:00:00Z", null, " EMAIL@example.test "),
                Venta(5, 999, "2026-10-10T12:00:00Z", 9),
                Venta(6, 999, "2026-10-10T12:00:00Z", 10),
                Venta(7, 999, "2026-10-10T12:00:00Z", 11),
                Venta(8, 999, "2026-10-10T12:00:00Z", 12),
                Venta(9, 999, "2026-10-10T12:00:00Z", null));
            db.Ventas.Local.Single(v => v.Number == 5).PaymentStatus = "pending";
            db.Ventas.Local.Single(v => v.Number == 6).Status = "cancelled";
            db.Ventas.Local.Single(v => v.Number == 7).Status = "refunded";
            db.Ventas.Local.Single(v => v.Number == 8).CancelledAt = DateTimeOffset.UtcNow;
            await db.SaveChangesAsync();
        }

        var ranking = await fixture.Clientes.ConsultarAsync(PeriodoClientes.EsteMes);
        Assert.Equal(2, ranking.Count);
        Assert.Equal(400m, ranking[0].Total);
        Assert.Equal(2, ranking[0].Pedidos);
        Assert.Equal(200m, ranking[0].TicketPromedio);
        Assert.Equal("nuevo@example.test", ranking[0].Email);
        Assert.Equal(new DateOnly(2026, 10, 11), ranking[0].UltimaCompra);
        Assert.Equal(200m, ranking[1].Total);
        Assert.Equal(2, ranking[1].Pedidos);
    }

    [Theory]
    [InlineData(PeriodoClientes.EsteMes, 2)]
    [InlineData(PeriodoClientes.Ultimos90Dias, 3)]
    [InlineData(PeriodoClientes.EsteAnio, 4)]
    [InlineData(PeriodoClientes.Todo, 5)]
    public async Task RankingRespetaPeriodosYCompletedAtEnArgentina(PeriodoClientes periodo, int pedidos)
    {
        await using var fixture = await Fixture.CrearAsync();
        await using (var db = fixture.Factory.CreateDbContext())
        {
            db.Ventas.AddRange(
                Venta(1, 100, "2025-12-31T12:00:00Z", 1),
                Venta(2, 100, "2026-01-01T03:00:00Z", 1),
                Venta(3, 100, "2026-07-14T03:00:00Z", 1),
                Venta(4, 100, "2026-10-01T03:00:00Z", 1),
                Venta(5, 100, "2026-10-12T02:00:00Z", 1));
            var ultima = db.Ventas.Local.Single(v => v.Number == 5);
            ultima.CompletedAt = ultima.PaidAt;
            ultima.PaidAt = DateTimeOffset.Parse("2026-10-12T12:00:00Z");
            await db.SaveChangesAsync();
        }

        var cliente = Assert.Single(await fixture.Clientes.ConsultarAsync(periodo));
        Assert.Equal(pedidos, cliente.Pedidos);
        Assert.Equal(new DateOnly(2026, 10, 11), cliente.UltimaCompra);
    }

    [Fact]
    public async Task RankingDevuelveTop50PorTotalDescendente()
    {
        await using var fixture = await Fixture.CrearAsync();
        await using (var db = fixture.Factory.CreateDbContext())
        {
            db.Ventas.AddRange(Enumerable.Range(1, 55)
                .Select(i => Venta(i, i * 100, "2026-10-10T12:00:00Z", i)));
            await db.SaveChangesAsync();
        }

        var ranking = await fixture.Clientes.ConsultarAsync(PeriodoClientes.Todo);
        Assert.Equal(50, ranking.Count);
        Assert.Equal(5500m, ranking[0].Total);
        Assert.Equal(600m, ranking[^1].Total);
        Assert.Equal(ranking.OrderByDescending(c => c.Total), ranking);
    }

    [Fact]
    public async Task HistorialOrdenadoYAnualSoloCerradosDelAnioMasParcialConKumoAparte()
    {
        await using var fixture = await Fixture.CrearAsync();
        await using (var db = fixture.Factory.CreateDbContext())
        {
            db.MonthlyHistories.AddRange(
                Mes("2026-02", true), Mes("2025-12", true),
                Mes("2026-01", true), Mes("2026-03", false), Mes("2027-01", true));
            db.MonthlyHistories.Local.Single(m => m.Mes == "2026-02").Nota = "Corrección histórica";
            foreach (var (cuenta, fecha, gasto) in new[]
            {
                ("Kumo", new DateOnly(2026, 10, 10), 7m),
                ("Kumo", new DateOnly(2026, 10, 11), 999m),
                ("Kumo", new DateOnly(2026, 9, 30), 999m),
                ("Street", new DateOnly(2026, 10, 10), 999m)
            })
            {
                db.MetaInsights.Add(new() { Cuenta = cuenta, Fecha = fecha, CampaignId = fecha.ToString(), Gasto = gasto });
            }
            await db.SaveChangesAsync();
        }

        var parcial = Parcial(2026);
        var resultado = await new FinanzasHistorialConsulta(fixture.Factory).ConsultarAsync(2026, parcial);
        Assert.Equal(new[] { "2025-12", "2026-01", "2026-02", "2026-03", "2027-01" }, resultado.Meses.Select(m => m.Mes));
        Assert.Equal("Corrección histórica", resultado.Meses[2].Nota);
        Assert.Same(parcial, resultado.Parcial);
        Assert.Equal(new TotalesAnuales(7, 320m, 23m, 44m, 65m, 86m, 17m, 200m), resultado.Anual);
    }

    [Fact]
    public async Task AnualNoAgregaParcialDeOtroAnio()
    {
        await using var fixture = await Fixture.CrearAsync();
        await using (var db = fixture.Factory.CreateDbContext())
        {
            db.MonthlyHistories.Add(Mes("2026-01", true));
            await db.SaveChangesAsync();
        }

        var resultado = await new FinanzasHistorialConsulta(fixture.Factory).ConsultarAsync(2026, Parcial(2027));
        Assert.Equal(new TotalesAnuales(2, 100m, 10m, 20m, 30m, 40m, 5m, 50m), resultado.Anual);
    }

    private static PeriodoFinanzas Parcial(int anio) => new("Este mes", new(anio, 10, 1), new(anio, 10, 11),
        new MargenPeriodo(3, 100m, 3m, 4m, 5m, 6m, 10m, 2m, 10m, []), true);

    private static MonthlyHistory Mes(string mes, bool cerrado) => new()
    {
        Mes = mes, Closed = cerrado, PedidosCount = 2, Facturado = 100m, Comision = 10m,
        Envio = 20m, CostoMercaderia = 30m, AdsStreet = 40m, AdsKumo = 5m, MargenReal = 50m
    };

    private static Venta Venta(long numero, decimal total, string fecha, long? cliente, string? email = null) => new()
    {
        Number = numero, TiendanubeOrderId = numero, CustomerId = cliente,
        CustomerEmail = email, CustomerName = "Cliente de prueba", Total = total,
        PaymentStatus = "paid", PaidAt = DateTimeOffset.Parse(fecha)
    };

    private sealed class Fixture(SqliteConnection connection, FinanzasMargenTests.Factory factory) : IAsyncDisposable
    {
        public FinanzasMargenTests.Factory Factory => factory;
        public ClientesConsulta Clientes { get; } = new(factory, new FinanzasMargenTests.Clock("2026-10-11T12:00:00Z"));

        public static async Task<Fixture> CrearAsync()
        {
            var connection = new SqliteConnection("Data Source=:memory:");
            await connection.OpenAsync();
            var factory = new FinanzasMargenTests.Factory(connection);
            await using var db = factory.CreateDbContext();
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            return new Fixture(connection, factory);
        }

        public ValueTask DisposeAsync() => connection.DisposeAsync();
    }
}
