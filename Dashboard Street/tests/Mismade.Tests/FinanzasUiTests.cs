using System.Net;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Mismade.Web.Components.Ui;
using Xunit;

namespace Mismade.Tests;

public sealed class FinanzasUiTests
{
    [Fact]
    public async Task RenderizaCuatroPeriodosDesgloseAvisosMetaYPendingConBotones()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new FinanzasMargenTests.Factory(connection);
        await using (var db = factory.CreateDbContext())
        {
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            db.MonthlyHistories.Add(new MonthlyHistory
            {
                Mes = "2026-01", Closed = true, Facturado = 100m, MargenReal = -10m, Nota = "Mes con pérdida"
            });
            db.Ventas.Add(new Venta
            {
                Number = 9, TiendanubeOrderId = 9, CreatedAt = DateTimeOffset.Parse("2026-10-10T12:00:00Z"),
                PaidAt = DateTimeOffset.Parse("2026-10-10T12:00:00Z"), PaymentStatus = "paid", Gateway = "Pago Nube", Total = 200_000m,
                Items = [new VentaItem { Name = "Taza", Quantity = 1 }]
            });
            await db.SaveChangesAsync();
        }

        var clock = new FinanzasMargenTests.Clock("2026-10-11T12:00:00Z");
        var service = new FinanzasMargenService(factory, clock, new FinanzasMargenTests.MetaConfig(false));
        await service.CrearPendientesAsync();
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddSingleton<IFinanzasMargenService>(service);
        services.AddSingleton<IFinanzasHistorialConsulta>(new FinanzasHistorialConsulta(factory));
        services.AddSingleton(new MargenConsulta(service, clock));
        services.AddSingleton(new FinanzasConsulta(new VentasStore(factory), clock));
        await using var provider = services.BuildServiceProvider();
        await using var renderer = new HtmlRenderer(provider, provider.GetRequiredService<ILoggerFactory>());
        var html = await renderer.Dispatcher.InvokeAsync(async () =>
        {
            var component = await renderer.RenderComponentAsync<FinanzasPanel>(ParameterView.Empty);
            return WebUtility.HtmlDecode(component.ToHtmlString());
        });

        foreach (var texto in new[]
        {
            "Historial mensual (Street)", "Resultado anual 2026 (Street)", "Ads Kumo (aparte)",
            "2026-10 (parcial, 1 al 10/10)", "Ayer", "Hoy (parcial)", "Últimos 7 días", "Este mes (1 al ayer)", "Ingresos", "Margen", "% sobre ingresos",
            "Comisión", "Envío absorbido", "Costo de mercadería", "Ventas en negro (neto)", "Pérdida de mercadería",
            "Ventas de prendas de cambio", "Confirmación pendiente — Pago Nube", "#9", "10/10/2026", "Fue en cuotas", "Sin cuotas",
            "Pago Nube sin confirmar", "Taza", "Facturación bruta · fecha de finalización"
        })
        {
            Assert.Contains(texto, html);
        }

        Assert.Contains("$ 200.000,00", html);
        Assert.Contains("Mes con pérdida", html);
        Assert.Contains("class=\"anomaly\"", html);
        Assert.DoesNotContain("¤", html);
        Assert.Equal(4, html.Split("Ads de Street: sin datos de Meta").Length - 1);
    }
}
