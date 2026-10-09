using System.Globalization;
using System.Net;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;
using Mismade.Application;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class MetaAdsClientTests
{
    private static readonly DateOnly Fecha = new(2026, 10, 9);
    private const string Token = "secret-meta-token";

    [Theory]
    [InlineData("123")]
    [InlineData("act_123")]
    [InlineData(" act_ 123 ")]
    public async Task PaginaNormalizaYUsaHeaderSinTokenEnUrl(string account)
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(request =>
        {
            calls++;
            Assert.Equal("Bearer", request.Headers.Authorization!.Scheme);
            Assert.Equal(Token, request.Headers.Authorization.Parameter);
            Assert.DoesNotContain(Token, request.RequestUri!.AbsoluteUri);
            Assert.DoesNotContain("access_token", request.RequestUri.Query);
            Assert.Equal("/v23.0/act_123/insights", request.RequestUri.AbsolutePath);
            var query = QueryHelpers.ParseQuery(request.RequestUri.Query);
            if (calls == 1)
            {
                Assert.Equal("campaign", query["level"].ToString());
                Assert.Equal("1", query["time_increment"].ToString());
                Assert.Equal("500", query["limit"].ToString());
                Assert.Equal("campaign_id,campaign_name,spend,impressions,clicks,actions,action_values", query["fields"].ToString());
                Assert.Equal("{\"since\":\"2026-10-09\",\"until\":\"2026-10-09\"}", query["time_range"].ToString());
                return Json("""
                    {"data":[{"date_start":"2026-10-09","campaign_id":"a","campaign_name":"Uno","spend":"12.34",
                    "impressions":"100","clicks":"5","actions":[{"action_type":"purchase","value":"2"},
                    {"action_type":"offsite_conversion.fb_pixel_purchase","value":"99"}],
                    "action_values":[{"action_type":"purchase","value":"50.75"},
                    {"action_type":"offsite_conversion.fb_pixel_purchase","value":"999"}]}],
                    "paging":{"next":"https://graph.facebook.com/v23.0/act_123/insights?after=abc&access_token=secret-meta-token"}}
                    """);
            }

            Assert.Equal("abc", query["after"].ToString());
            return Json("""
                {"data":[{"date_start":"2026-10-09","campaign_id":"b","actions":
                [{"action_type":"offsite_conversion.fb_pixel_purchase","value":"3"}],
                "action_values":[{"action_type":"offsite_conversion.fb_pixel_purchase","value":"70.25"}]}]}
                """);
        }));
        var before = CultureInfo.CurrentCulture;
        try
        {
            CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo("es-AR");
            var rows = await Client(http, account).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default);
            Assert.Equal(2, calls);
            Assert.Equal(new MetaInsight(CuentaMeta.Street, Fecha, "a", "Uno", 12.34m, 100, 5, 2, 50.75m), rows[0]);
            Assert.Equal(new MetaInsight(CuentaMeta.Street, Fecha, "b", "", 0, 0, 0, 3, 70.25m), rows[1]);
        }
        finally
        {
            CultureInfo.CurrentCulture = before;
        }
    }

    [Fact]
    public async Task Reintenta17()
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ => ++calls == 1
            ? Json("""{"error":{"code":17}}""", HttpStatusCode.BadRequest) : Json("""{"data":[]} """)));
        Assert.Empty(await Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Equal(2, calls);
    }

    [Theory]
    [InlineData(190, "El token de Meta venció o no es válido")]
    [InlineData(10, "Al token le falta acceso a la cuenta Street")]
    [InlineData(200, "Al token le falta acceso a la cuenta Street")]
    [InlineData(294, "Al token le falta acceso a la cuenta Street")]
    public async Task ErroresPermanentesNoReintentanNiExponenToken(int code, string message)
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ =>
        {
            calls++;
            return Json(System.Text.Json.JsonSerializer.Serialize(new { error = new { code, message = Token } }),
                HttpStatusCode.InternalServerError);
        }));
        var error = await Assert.ThrowsAsync<MetaAdsException>(() =>
            Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Equal(message, error.Message);
        Assert.DoesNotContain(Token, error.ToString());
        Assert.Equal(1, calls);
    }

    [Theory]
    [InlineData("abc")]
    [InlineData("act_123x")]
    [InlineData("")]
    public async Task IdInvalidoDaErrorDeConfiguracion(string id)
    {
        using var http = new HttpClient(new Handler(_ => throw new Exception("No debe enviar")));
        var error = await Assert.ThrowsAsync<MetaAdsException>(() =>
            Client(http, id).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Contains("ID de la cuenta Meta Street", error.Message);
    }

    [Fact]
    public async Task KumoVersionConfigurableYCamposAusentes()
    {
        using var http = new HttpClient(new Handler(request =>
        {
            Assert.Equal("/v24.0/act_456/insights", request.RequestUri!.AbsolutePath);
            return Json("""{"data":[{"date_start":"2026-10-09","campaign_id":"a"}]}""");
        }));
        var client = new MetaAdsClient(http, Options.Create(new MetaOptions
        {
            SystemUserToken = Token, KumoAccountId = "456", GraphVersion = "v24.0"
        }));
        Assert.Equal(new MetaInsight(CuentaMeta.Kumo, Fecha, "a", "", 0, 0, 0, 0, 0),
            Assert.Single(await client.GetInsightsAsync(CuentaMeta.Kumo, Fecha, Fecha, default)));
    }

    [Fact]
    public async Task PaginaExternaNoRecibeToken()
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ =>
        {
            calls++;
            return Json("""{"data":[],"paging":{"next":"https://example.com/insights"}}""");
        }));
        await Assert.ThrowsAsync<MetaAdsException>(() =>
            Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Equal(1, calls);
    }

    [Theory]
    [InlineData(1)]
    [InlineData(2)]
    [InlineData(4)]
    [InlineData(32)]
    [InlineData(613)]
    [InlineData(80004)]
    public async Task ReintentaCodigosTransitorios(int code)
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ => ++calls == 1
            ? Json(System.Text.Json.JsonSerializer.Serialize(new { error = new { code } }), HttpStatusCode.BadRequest)
            : Json("""{"data":[]} """)));
        await Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default);
        Assert.Equal(2, calls);
    }

    [Fact]
    public async Task LimitaAUnaSolicitudYTresReintentosAnte5xxSinJson()
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ =>
        {
            calls++;
            return Json(Token, HttpStatusCode.ServiceUnavailable);
        }));
        var error = await Assert.ThrowsAsync<MetaAdsException>(() =>
            Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Equal(4, calls);
        Assert.DoesNotContain(Token, error.ToString());
    }

    [Fact]
    public async Task ReintentaTimeout()
    {
        var calls = 0;
        using var http = new HttpClient(new Handler(_ =>
        {
            if (++calls == 1)
            {
                throw new TaskCanceledException(Token);
            }

            return Json("""{"data":[]} """);
        }));
        await Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default);
        Assert.Equal(2, calls);
    }

    [Fact]
    public async Task PurchaseCeroNoSumaFallback()
    {
        using var http = new HttpClient(new Handler(_ => Json("""
            {"data":[{"date_start":"2026-10-09","campaign_id":"a",
            "actions":[{"action_type":"purchase","value":"0"},
            {"action_type":"offsite_conversion.fb_pixel_purchase","value":"5"}],
            "action_values":[{"action_type":"purchase","value":"0"},
            {"action_type":"offsite_conversion.fb_pixel_purchase","value":"50"}]}]}
            """)));
        var row = Assert.Single(await Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.Equal(0, row.Compras);
        Assert.Equal(0, row.ValorCompras);
    }

    [Fact]
    public async Task ErrorDeTransporteNoExponeToken()
    {
        using var http = new HttpClient(new Handler(_ => throw new HttpRequestException(Token)));
        var error = await Assert.ThrowsAsync<MetaAdsException>(() =>
            Client(http).GetInsightsAsync(CuentaMeta.Street, Fecha, Fecha, default));
        Assert.DoesNotContain(Token, error.ToString());
    }

    private static MetaAdsClient Client(HttpClient http, string account = "123") =>
        new(http, Options.Create(new MetaOptions { SystemUserToken = Token, StreetAccountId = account }));

    private static HttpResponseMessage Json(string body, HttpStatusCode status = HttpStatusCode.OK) =>
        new(status) { Content = new StringContent(body) };

    private sealed class Handler(Func<HttpRequestMessage, HttpResponseMessage> respond) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct) =>
            Task.FromResult(respond(request));
    }
}
