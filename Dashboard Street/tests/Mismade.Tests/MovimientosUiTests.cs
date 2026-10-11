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

public sealed class MovimientosUiTests
{
    [Fact]
    public async Task RenderizaFormulariosYProtegeImportadosPeroPermiteBorrarCrisSinStock()
    {
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection);
        await using (var db = factory.CreateDbContext())
        {
            await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
                .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
            db.StockRemeras.Add(new StockRemera { Color = "Negro", Corte = "Regular", Talle = "XXL", Stock = 4 });
            db.VentasNegro.Add(new VentaNegro { Fecha = new DateOnly(2026, 10, 10), TotalAmount = 5000 });
            db.CrisLedger.Add(new CrisLedger { Fecha = new DateOnly(2026, 10, 10), Tipo = TipoMovimientoCris.Pago, Monto = 3000 });
            await db.SaveChangesAsync();
        }

        var servicio = new MovimientosManualesService(factory);
        await servicio.RegistrarPerdidaAsync(new PerdidaMercaderia
        {
            Fecha = new DateOnly(2026, 10, 11), Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = 1, Motivo = "Rotura"
        });
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddSingleton<IDbContextFactory<MismadeDbContext>>(factory);
        services.AddSingleton<IMovimientosManualesService>(servicio);
        await using var provider = services.BuildServiceProvider();
        await using var renderer = new HtmlRenderer(provider, provider.GetRequiredService<ILoggerFactory>());
        var html = await renderer.Dispatcher.InvokeAsync(async () =>
        {
            var component = await renderer.RenderComponentAsync<MovimientosPanel>(ParameterView.Empty);
            return WebUtility.HtmlDecode(component.ToHtmlString());
        });

        Assert.Contains("Venta en negro", html);
        Assert.Contains("Pérdida de mercadería", html);
        Assert.Contains("Movimiento con Cris", html);
        Assert.Contains("Cambio de prendas", html);
        Assert.Contains("Carga al stock de cambios", html);
        Assert.Contains("Venta de prenda de cambio", html);
        Assert.Contains("Importado · sin borrado", html);
        Assert.Contains(MovimientosManualesService.MensajeImportado, html);
        Assert.Equal(2, html.Split(">Borrar</button>").Length - 1);
        Assert.Contains("value=\"Negro\"", html);
        Assert.Contains("value=\"Regular\"", html);
        Assert.Contains("value=\"XXL\"", html);
    }

    private sealed class Factory(SqliteConnection connection) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() => new(
            new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection).Options);
    }
}
