using System.Net;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Mismade.Application;
using Mismade.Web.Components.Ui;
using Xunit;

namespace Mismade.Tests;

public sealed class ClientesUiTests
{
    [Fact]
    public async Task RenderizaRankingFiltrosMonedaYNotaFranquicias()
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddSingleton<IClientesConsulta>(new ConsultaPrueba());
        await using var provider = services.BuildServiceProvider();
        await using var renderer = new HtmlRenderer(provider, provider.GetRequiredService<ILoggerFactory>());
        var html = await renderer.Dispatcher.InvokeAsync(async () =>
        {
            var component = await renderer.RenderComponentAsync<ClientesPanel>(ParameterView.Empty);
            return WebUtility.HtmlDecode(component.ToHtmlString());
        });

        foreach (var texto in new[]
        {
            "Ranking de franquicias: falta definir qué clientes son franquicias", "Este mes",
            "Últimos 90 días", "Este año", "Todo", "Nombre de prueba", "cliente@example.test",
            "Ticket promedio", "$ 63.000,00", "$ 31.500,00", "10/10/2026"
        })
        {
            Assert.Contains(texto, html);
        }
    }

    private sealed class ConsultaPrueba : IClientesConsulta
    {
        public Task<IReadOnlyList<ClienteRanking>> ConsultarAsync(PeriodoClientes periodo, CancellationToken ct = default)
        {
            Assert.Equal(PeriodoClientes.EsteMes, periodo);
            return Task.FromResult<IReadOnlyList<ClienteRanking>>(
                [new("Nombre de prueba", "cliente@example.test", 2, 63000m, 31500m, new(2026, 10, 10))]);
        }
    }
}
