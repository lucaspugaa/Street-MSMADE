using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class FinanzasMargenTests
{
    private static Venta Venta(long number, string fechaPago, decimal total = 100_000m, string gateway = "Mercado Pago",
        string nombre = "Remera", int cantidad = 1) => new()
    {
        Number = number, TiendanubeOrderId = number, PaymentStatus = "paid", Status = "open", Total = total,
        Gateway = gateway, PaidAt = DateTimeOffset.Parse(fechaPago), CreatedAt = DateTimeOffset.Parse("2026-09-01T12:00:00Z"),
        Items = [new VentaItem { Name = nombre, Quantity = cantidad }]
    };

    private static MetaInsightEntity Ads(string cuenta, string fecha, decimal gasto, string campaign = "1") => new()
    {
        Cuenta = cuenta, Fecha = DateOnly.Parse(fecha), CampaignId = campaign, CampaignName = "Campaña", Gasto = gasto
    };

    [Fact]
    public async Task ConsultaFiltraPagoArtCruzaCuotasAdsStreetYAjustesPorFecha()
    {
        await using var f = await Fixture.CrearAsync();
        await using (var db = f.Factory.CreateDbContext())
        {
            var primera = Venta(1, "2026-10-11T02:59:59Z", nombre: "Remera Argentina", cantidad: 2);
            primera.ShippingOption = "Andreani";
            var segunda = Venta(2, "2026-10-10T03:00:00Z", 200_000m, "Pago Nube", "Hoodie Básico");
            var fallback = Venta(3, "2026-11-01T12:00:00Z", 50_000m, "Personalizado", "Jogging Baggy");
            fallback.PaidAt = null;
            fallback.CreatedAt = DateTimeOffset.Parse("2026-10-10T12:00:00Z");
            var fuera = Venta(4, "2026-10-11T03:00:00Z");
            fuera.CreatedAt = fallback.CreatedAt;
            var pendiente = Venta(5, "2026-10-10T12:00:00Z");
            pendiente.PaymentStatus = "pending";
            var reembolso = Venta(6, "2026-10-10T12:00:00Z");
            reembolso.PaymentStatus = "refunded";
            var cancelada = Venta(7, "2026-10-10T12:00:00Z");
            cancelada.CancelledAt = cancelada.PaidAt;
            var estadoCancelado = Venta(8, "2026-10-10T12:00:00Z");
            estadoCancelado.Status = "cancelled";
            var previo = Venta(9, "2026-10-10T02:59:59Z");
            var desconocida = Venta(10, "2026-10-10T12:00:00Z", 1000m, "Desconocido", "Taza");
            desconocida.Status = "closed";
            var estadoReembolso = Venta(11, "2026-10-10T12:00:00Z");
            estadoReembolso.Status = "refunded";
            db.Ventas.AddRange(primera, segunda, fallback, fuera, pendiente, reembolso, cancelada,
                estadoCancelado, previo, desconocida, estadoReembolso);
            db.PagoNubeCuotas.Add(new PagoNubeCuota { OrderNumber = 2, Fecha = new DateOnly(2026, 10, 10), Status = EstadoPagoNube.Cuotas });
            db.MetaInsights.AddRange(Ads("Street", "2026-10-10", 100), Ads("Street", "2026-10-10", 150, "2"),
                Ads("Kumo", "2026-10-10", 900), Ads("Street", "2026-10-09", 999), Ads("Street", "2026-10-11", 888));
            foreach (var fecha in new[] { new DateOnly(2026, 10, 9), new DateOnly(2026, 10, 10), new DateOnly(2026, 10, 11) })
            {
                db.VentasNegro.Add(new VentaNegro
                {
                    Fecha = fecha, TotalAmount = 40_000m,
                    Items = [new VentaNegroItem { Tipo = "remera", Color = "Negro", Corte = "Regular", Cantidad = 2 }]
                });
                db.PerdidasMercaderia.Add(new PerdidaMercaderia { Fecha = fecha, Color = "Negro", Corte = "Regular", Cantidad = 1 });
                db.CambioVentas.Add(new CambioVenta { Fecha = fecha, Monto = 3000m });
            }

            await db.SaveChangesAsync();
        }

        var resultado = await f.Servicio.ConsultarAsync(new DateOnly(2026, 10, 10), new DateOnly(2026, 10, 11));
        Assert.Equal(4, resultado.Pedidos);
        Assert.Equal(351_000m, resultado.IngresosTiendanube);
        Assert.Equal(51_660m, resultado.Comision);
        Assert.Equal(9_000m, resultado.Envio);
        Assert.Equal(64_500m, resultado.Costo);
        Assert.Equal(250m, resultado.AdsStreet);
        Assert.Equal(25_000m, resultado.VentasNegroNeto);
        Assert.Equal(7_500m, resultado.Perdidas);
        Assert.Equal(3_000m, resultado.VentasCambio);
        Assert.Equal(379_000m, resultado.Ingresos);
        Assert.Equal(246_090m, resultado.Margen);
        Assert.Contains(resultado.Avisos, a => a.Contains("#10") && a.Contains("medio de pago desconocido"));
        Assert.Contains(resultado.Avisos, a => a.Contains("Taza"));
        Assert.DoesNotContain(resultado.Avisos, a => a.Contains("Pago Nube sin confirmar"));
    }

    [Fact]
    public async Task PendingSoloMiraMesEnCursoYUltimosSieteDias()
    {
        // Hoy 11/10: entra desde el 1/10; el 1/10 a la madrugada UTC todavía es 30/9 en Argentina.
        await using var f = await Fixture.CrearAsync();
        await using (var db = f.Factory.CreateDbContext())
        {
            db.Ventas.AddRange(
                Venta(10, "2026-08-20T15:00:00Z", 300_000m, "pago-nube"),
                Venta(11, "2026-10-01T02:00:00Z", 300_000m, "pago-nube"),
                Venta(12, "2026-10-01T03:00:00Z", 300_000m, "pago-nube"));
            await db.SaveChangesAsync();
        }

        await f.Servicio.CrearPendientesAsync();

        Assert.Equal([12L], (await f.Servicio.PendientesAsync()).Select(p => p.OrderNumber));
    }

    [Fact]
    public async Task PendingRespetaUmbralSegunFechaPagoArtYNoDuplicaNiPisaConfirmados()
    {
        await using var f = await Fixture.CrearAsync();
        await using (var db = f.Factory.CreateDbContext())
        {
            db.Ventas.AddRange(
                Venta(1, "2026-10-02T02:59:59Z", 120_000m, "pago_nube"),
                Venta(2, "2026-10-02T02:00:00Z", 100_000m, "Pago Nube"),
                Venta(3, "2026-10-02T03:00:00Z", 170_001m, "Nuvem Pago"),
                Venta(4, "2026-10-02T03:00:00Z", 170_000m, "Pago Nube"),
                Venta(5, "2026-10-02T12:00:00Z", 200_000m, "Mercado Pago"),
                Venta(6, "2026-10-02T12:00:00Z", 200_000m, "Pago Nube"));
            var noPaga = Venta(7, "2026-10-02T12:00:00Z", 200_000m, "Pago Nube");
            noPaga.PaymentStatus = "refunded";
            var cancelada = Venta(8, "2026-10-02T12:00:00Z", 200_000m, "Pago Nube");
            cancelada.Status = "cancelled";
            var fallback = Venta(9, "2026-10-02T12:00:00Z", 200_000m, "Pago Nube");
            fallback.PaidAt = null;
            fallback.CreatedAt = DateTimeOffset.Parse("2026-10-02T02:59:59Z");
            db.Ventas.AddRange(noPaga, cancelada, fallback);
            db.PagoNubeCuotas.Add(new PagoNubeCuota
            {
                OrderNumber = 6, Status = EstadoPagoNube.Simple, Total = 199_999m,
                MarkedAt = DateTimeOffset.Parse("2026-10-03T12:00:00Z")
            });
            await db.SaveChangesAsync();
        }

        await f.Servicio.CrearPendientesAsync();
        await f.Servicio.CrearPendientesAsync();
        var pendientes = await f.Servicio.PendientesAsync();
        Assert.Equal([1L, 9L, 3L], pendientes.Select(p => p.OrderNumber));
        Assert.Equal(new DateOnly(2026, 10, 1), pendientes[0].Fecha);
        Assert.Equal(120_000m, pendientes[0].Total);
        Assert.All(pendientes, p => Assert.Null(p.MarkedAt));
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(4, await verificacion.PagoNubeCuotas.CountAsync());
        var confirmada = await verificacion.PagoNubeCuotas.SingleAsync(p => p.OrderNumber == 6);
        Assert.Equal(EstadoPagoNube.Simple, confirmada.Status);
        Assert.Equal(199_999m, confirmada.Total);
        Assert.Equal(DateTimeOffset.Parse("2026-10-03T12:00:00Z"), confirmada.MarkedAt);
    }

    [Theory]
    [InlineData(EstadoPagoNube.Cuotas, 46_060)]
    [InlineData(EstadoPagoNube.Simple, 10_960)]
    public async Task ConfirmacionMarcaFechaYRecalculaComision(EstadoPagoNube estado, int comision)
    {
        await using var f = await Fixture.CrearAsync();
        await using (var db = f.Factory.CreateDbContext())
        {
            db.Ventas.Add(Venta(1, "2026-10-10T12:00:00Z", 200_000m, "Pago Nube"));
            await db.SaveChangesAsync();
        }

        await f.Servicio.CrearPendientesAsync();
        var antes = await f.Servicio.ConsultarAsync(new DateOnly(2026, 10, 10), new DateOnly(2026, 10, 11));
        Assert.Contains(antes.Avisos, a => a.Contains("sin confirmar"));
        await f.Servicio.ConfirmarPagoNubeAsync(1, estado);
        Assert.Empty(await f.Servicio.PendientesAsync());
        var despues = await f.Servicio.ConsultarAsync(new DateOnly(2026, 10, 10), new DateOnly(2026, 10, 11));
        Assert.Equal(comision, despues.Comision);
        Assert.DoesNotContain(despues.Avisos, a => a.Contains("sin confirmar"));
        await using var dbFinal = f.Factory.CreateDbContext();
        Assert.Equal(f.Clock.GetUtcNow(), (await dbFinal.PagoNubeCuotas.SingleAsync()).MarkedAt);
    }

    [Fact]
    public async Task CierreIdempotenteUsaMesCompletoYSumaKumoAparteSinPisarImportados()
    {
        await using var f = await Fixture.CrearAsync("2026-12-01T03:00:00Z");
        await using (var db = f.Factory.CreateDbContext())
        {
            db.MonthlyHistories.AddRange(
                new MonthlyHistory { Mes = "2026-09", MargenReal = 77m, Nota = "importado" },
                new MonthlyHistory { Mes = "2026-10", MargenReal = 88m, Facturado = 99m, Closed = true, Nota = "importado octubre" });
            db.Ventas.AddRange(Venta(1, "2026-12-01T02:59:59Z"), Venta(2, "2026-12-01T03:00:00Z"));
            db.MetaInsights.AddRange(Ads("Street", "2026-11-30", 100m), Ads("Kumo", "2026-11-30", 900m), Ads("Kumo", "2026-12-01", 500m));
            db.VentasNegro.Add(new VentaNegro { Fecha = new DateOnly(2026, 11, 1), TotalAmount = 5000m });
            db.CambioVentas.Add(new CambioVenta { Fecha = new DateOnly(2026, 11, 30), Monto = 2000m });
            await db.SaveChangesAsync();
        }

        var esperado = await f.Servicio.ConsultarAsync(new DateOnly(2026, 11, 1), new DateOnly(2026, 12, 1));
        await f.Servicio.CerrarMesesAsync();
        await f.Servicio.CerrarMesesAsync();
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(3, await verificacion.MonthlyHistories.CountAsync());
        var mes = await verificacion.MonthlyHistories.SingleAsync(m => m.Mes == "2026-11");
        Assert.Equal(1, mes.PedidosCount);
        Assert.Equal(107_000m, mes.Facturado);
        Assert.Equal(esperado.Margen, mes.MargenReal);
        Assert.Equal(esperado.Comision, mes.Comision);
        Assert.Equal(esperado.Envio, mes.Envio);
        Assert.Equal(esperado.Costo, mes.CostoMercaderia);
        Assert.Equal(100m, mes.AdsStreet);
        Assert.Equal(900m, mes.AdsKumo);
        Assert.True(mes.Closed);
        var septiembre = await verificacion.MonthlyHistories.SingleAsync(m => m.Mes == "2026-09");
        Assert.Equal((77m, false, "importado"), (septiembre.MargenReal, septiembre.Closed, septiembre.Nota));
        var octubre = await verificacion.MonthlyHistories.SingleAsync(m => m.Mes == "2026-10");
        Assert.Equal((88m, 99m, "importado octubre"), (octubre.MargenReal, octubre.Facturado, octubre.Nota));
    }

    [Theory]
    [InlineData("2026-11-01T02:59:59Z", 0)]
    [InlineData("2026-11-01T03:00:00Z", 1)]
    [InlineData("2027-01-01T03:00:00Z", 3)]
    public async Task CierreEmpiezaEnOctubreYNoCierraElMesActualArt(string ahora, int meses)
    {
        await using var f = await Fixture.CrearAsync(ahora);
        await f.Servicio.CerrarMesesAsync();
        await f.Servicio.CerrarMesesAsync();
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(meses, await db.MonthlyHistories.CountAsync());
        Assert.All(await db.MonthlyHistories.ToListAsync(), m => Assert.True(string.CompareOrdinal(m.Mes, "2026-10") >= 0));
    }

    [Fact]
    public async Task TarjetasRespetanArtYMesHastaAyerInclusoElPrimerDia()
    {
        await using var f = await Fixture.CrearAsync("2026-11-01T02:30:00Z");
        var tarjetas = await new MargenConsulta(f.Servicio, f.Clock).ConsultarAsync();
        Assert.Equal(new DateOnly(2026, 10, 30), tarjetas[0].Desde);
        Assert.Equal(new DateOnly(2026, 10, 31), tarjetas[1].Desde);
        Assert.Equal(new DateOnly(2026, 10, 24), tarjetas[2].Desde);
        Assert.Equal(new DateOnly(2026, 10, 31), tarjetas[2].Hasta);
        Assert.Equal((new DateOnly(2026, 10, 1), new DateOnly(2026, 10, 31)), (tarjetas[3].Desde, tarjetas[3].Hasta));
        var primerDia = await new MargenConsulta(f.Servicio, new Clock("2026-11-01T03:00:00Z")).ConsultarAsync();
        Assert.Equal(primerDia[3].Desde, primerDia[3].Hasta);
        Assert.Equal(0, primerDia[3].Margen.Pedidos);
    }

    [Fact]
    public async Task MetaSinConfigurarOSinDatosStreetNoSeMuestraComoCeroSilencioso()
    {
        await using var f = await Fixture.CrearAsync();
        var desde = new DateOnly(2026, 10, 10);
        var hasta = desde.AddDays(1);
        Assert.False(await f.Servicio.TieneDatosMetaStreetAsync(desde, hasta));
        await using (var db = f.Factory.CreateDbContext())
        {
            db.MetaInsights.Add(Ads("Kumo", "2026-10-10", 100));
            await db.SaveChangesAsync();
        }

        Assert.False(await f.Servicio.TieneDatosMetaStreetAsync(desde, hasta));
        await using (var db = f.Factory.CreateDbContext())
        {
            db.MetaInsights.Add(Ads("Street", "2026-10-10", 0));
            await db.SaveChangesAsync();
        }

        Assert.True(await f.Servicio.TieneDatosMetaStreetAsync(desde, hasta));
        var sinConfig = new FinanzasMargenService(f.Factory, f.Clock, new MetaConfig(false));
        Assert.False(await sinConfig.TieneDatosMetaStreetAsync(desde, hasta));
    }

    public sealed class Clock(string ahora) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => DateTimeOffset.Parse(ahora);
    }

    public sealed record MetaConfig(bool Configurada) : IMetaConfiguration
    {
        public bool EstaConfigurada(CuentaMeta cuenta) => Configurada;
    }

    public sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() => new(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseSqlite(connection).ReplaceService<IModelCustomizer, VentasStoreTests.SqliteModel>().Options);
    }

    private sealed class Fixture(SqliteConnection connection, Factory factory, Clock clock) : IAsyncDisposable
    {
        public Factory Factory { get; } = factory;
        public Clock Clock { get; } = clock;
        public FinanzasMargenService Servicio { get; } = new(factory, clock, new MetaConfig(true));
        public static async Task<Fixture> CrearAsync(string ahora = "2026-10-11T12:00:00Z")
        {
            var connection = new SqliteConnection("Data Source=:memory:");
            await connection.OpenAsync();
            var factory = new Factory(connection);
            await using var db = factory.CreateDbContext();
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            return new Fixture(connection, factory, new Clock(ahora));
        }

        public ValueTask DisposeAsync() => connection.DisposeAsync();
    }
}
