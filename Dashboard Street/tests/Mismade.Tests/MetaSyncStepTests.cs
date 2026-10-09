using Mismade.Application;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class MetaSyncStepTests
{
    [Theory]
    [InlineData(false, "2026-09-01")]
    [InlineData(true, "2026-10-03")]
    public void VentanaUsaHoyArgentinaYEstadoDeLaCuenta(bool tieneFilas, string esperado)
    {
        // Las 02:00 UTC del 10 todavía son el 9 en Argentina.
        var (desde, hasta) = MetaSyncVentana.Calcular(tieneFilas, DateTimeOffset.Parse("2026-10-10T02:00:00Z"));
        Assert.Equal(DateOnly.Parse(esperado), desde);
        Assert.Equal(new DateOnly(2026, 10, 9), hasta);
    }

    [Fact]
    public void VentanaVaciaCruzaElAno()
    {
        Assert.Equal(new DateOnly(2025, 12, 1),
            MetaSyncVentana.Calcular(false, DateTimeOffset.Parse("2026-01-01T12:00:00Z")).Desde);
    }

    [Fact]
    public async Task FalloStreetNoFrenaKumoYRegistraRangosSeparados()
    {
        var store = new Store();
        var detalle = new SyncDetalle();
        var step = new MetaSyncStep(new Client(), store, new MetaOptions
        {
            SystemUserToken = "secret", StreetAccountId = "123", KumoAccountId = "456"
        }, new Clock());
        await step.RunAsync(detalle, default);

        var street = Assert.Single(detalle.Meta, x => x.Cuenta == CuentaMeta.Street);
        var kumo = Assert.Single(detalle.Meta, x => x.Cuenta == CuentaMeta.Kumo);
        Assert.Equal("error", street.Estado);
        Assert.Equal("El token de Meta venció o no es válido", street.Mensaje);
        Assert.Equal(new DateOnly(2026, 10, 3), street.Desde);
        Assert.Equal("ok", kumo.Estado);
        Assert.Equal(1, kumo.Filas);
        Assert.Equal(new DateOnly(2026, 9, 1), kumo.Desde);
        Assert.Equal(CuentaMeta.Kumo, Assert.Single(store.Guardadas));
    }

    [Fact]
    public async Task SinConfiguracionOmiteCadaCuentaSinConsultarNiGuardar()
    {
        var store = new Store();
        var detalle = new SyncDetalle();
        await new MetaSyncStep(new Client(), store, new MetaOptions(), new Clock()).RunAsync(detalle, default);
        Assert.Equal(2, detalle.Meta.Count);
        Assert.All(detalle.Meta, x => Assert.Equal("omitido", x.Estado));
        Assert.Empty(store.Guardadas);
        Assert.Equal(0, store.Consultas);
    }

    [Fact]
    public async Task ConfiguracionParcialSincronizaLaCuentaPresente()
    {
        var store = new Store();
        var detalle = new SyncDetalle();
        await new MetaSyncStep(new Client(), store, new MetaOptions
        {
            SystemUserToken = "secret", KumoAccountId = "456"
        }, new Clock()).RunAsync(detalle, default);
        Assert.Equal("omitido", detalle.Meta[0].Estado);
        Assert.Equal("ok", detalle.Meta[1].Estado);
        Assert.Equal(CuentaMeta.Kumo, Assert.Single(store.Guardadas));
    }

    [Fact]
    public async Task CancelacionNoSeConvierteEnErrorDeCuenta()
    {
        using var cts = new CancellationTokenSource();
        cts.Cancel();
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() =>
            new MetaSyncStep(new Client(), new Store(), new MetaOptions(), new Clock())
                .RunAsync(new SyncDetalle(), cts.Token));
    }

    private sealed class Clock : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => DateTimeOffset.Parse("2026-10-10T02:00:00Z");
    }

    private sealed class Client : IMetaAdsClient
    {
        public Task<IReadOnlyList<MetaInsight>> GetInsightsAsync(
            CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct)
        {
            if (cuenta == CuentaMeta.Street)
            {
                throw new MetaAdsException("El token de Meta venció o no es válido");
            }

            return Task.FromResult<IReadOnlyList<MetaInsight>>([new(cuenta, hasta, "a", "a", 1, 2, 3, 4, 5)]);
        }
    }

    private sealed class Store : IMetaInsightStore
    {
        public int Consultas { get; private set; }
        public List<CuentaMeta> Guardadas { get; } = [];

        public Task<bool> TieneFilasAsync(CuentaMeta cuenta, CancellationToken ct)
        {
            Consultas++;
            return Task.FromResult(cuenta == CuentaMeta.Street);
        }

        public Task ReemplazarAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta,
            IReadOnlyList<MetaInsight> filas, CancellationToken ct)
        {
            Guardadas.Add(cuenta);
            return Task.CompletedTask;
        }

        public Task<decimal> GastoAsync(CuentaMeta cuenta, DateOnly desde, DateOnly hasta, CancellationToken ct) =>
            Task.FromResult(0m);
    }
}
