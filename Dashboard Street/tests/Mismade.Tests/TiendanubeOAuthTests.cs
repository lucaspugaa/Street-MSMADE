using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Infrastructure;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Mismade.Infrastructure;
using Mismade.Web;
using Xunit;

namespace Mismade.Tests;

public sealed class TiendanubeOAuthTests
{
    private static readonly IOptions<TiendanubeOptions> Config = Options.Create(new TiendanubeOptions
    {
        AppId = "test-app", ClientSecret = "fake-secret"
    });

    [Theory]
    [InlineData("user_id", "\"123\"")]
    [InlineData("store_id", "123")]
    public async Task TokenExchangeSendsCorrectJsonAndAcceptsBothStoreIdentifiers(string key, string value)
    {
        using var http = new HttpClient(new FakeHttpHandler(async (request, ct) =>
        {
            Assert.Equal(HttpMethod.Post, request.Method);
            Assert.Equal("https://www.tiendanube.com/apps/authorize/token", request.RequestUri!.AbsoluteUri);
            Assert.Equal("application/json", request.Content!.Headers.ContentType!.MediaType);
            using var body = JsonDocument.Parse(await request.Content.ReadAsStringAsync(ct));
            var root = body.RootElement;
            Assert.Equal(4, root.EnumerateObject().Count());
            Assert.Equal("test-app", root.GetProperty("client_id").GetString());
            Assert.Equal("fake-secret", root.GetProperty("client_secret").GetString());
            Assert.Equal("authorization_code", root.GetProperty("grant_type").GetString());
            Assert.Equal("fake-code", root.GetProperty("code").GetString());
            return TiendanubeClientTests.Json($$"""{"{{key}}":{{value}},"access_token":"fake-token","scope":"read_orders"}""");
        }));

        var result = await new TiendanubeTokenClient(http, Config).ExchangeAsync("fake-code", default);
        Assert.Equal(new TiendanubeToken(123, "fake-token", "read_orders"), result);
    }

    [Fact]
    public void StateIsRandomProtectedAndRejectsMismatchTamperingMissingAndExpiry()
    {
        var protection = new EphemeralDataProtectionProvider();
        var states = new TiendanubeOAuthState(protection);
        var (state, cookie) = states.Create();
        Assert.NotEqual(state, states.Create().State);
        Assert.DoesNotContain(state, cookie);
        Assert.True(states.Validate(state, cookie));
        Assert.False(states.Validate(state + "x", cookie));
        Assert.False(states.Validate(state, cookie + "x"));
        Assert.False(states.Validate(null, cookie));
        Assert.False(states.Validate(state, null));
        var expired = protection.CreateProtector("Mismade.Tiendanube.OAuthState")
            .ToTimeLimitedDataProtector().Protect(state, DateTimeOffset.UtcNow.AddMinutes(-1));
        Assert.False(states.Validate(state, expired));
    }

    [Fact]
    public void ConnectSetsSecureCookieAndIncludesSameStateInRedirect()
    {
        var context = new DefaultHttpContext();
        var states = new TiendanubeOAuthState(new EphemeralDataProtectionProvider());
        var redirect = Assert.IsType<RedirectHttpResult>(TiendanubeOAuth.Connect(context, Config, states));
        Assert.StartsWith("https://www.tiendanube.com/apps/test-app/authorize?state=", redirect.Url);
        var cookieHeader = context.Response.Headers.SetCookie.ToString();
        Assert.Contains("httponly", cookieHeader, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("secure", cookieHeader, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("samesite=lax", cookieHeader, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("expires=", cookieHeader, StringComparison.OrdinalIgnoreCase);
        var cookie = cookieHeader.Split(';')[0].Split('=', 2)[1];
        var state = redirect.Url.Split("state=")[1];
        Assert.True(states.Validate(state, cookie));
    }

    [Fact]
    public void MissingConfigurationRedirectsWithoutSettingCookie()
    {
        var context = new DefaultHttpContext();
        var redirect = Assert.IsType<RedirectHttpResult>(TiendanubeOAuth.Connect(context,
            Options.Create(new TiendanubeOptions()), new TiendanubeOAuthState(new EphemeralDataProtectionProvider())));
        Assert.Equal("/?tiendanube=config", redirect.Url);
        Assert.Equal(0, context.Response.Headers.SetCookie.Count);
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task CallbackValidatesBeforeExchangeDeletesCookieAndOnlySavesValidState(bool valid)
    {
        var states = new TiendanubeOAuthState(new EphemeralDataProtectionProvider());
        var (state, cookie) = states.Create();
        var context = new DefaultHttpContext();
        context.Request.Headers.Cookie = $"{TiendanubeOAuth.CookieName}={cookie}";
        context.Request.QueryString = new QueryString($"?state={(valid ? state : "invalid")}&code=fake-code");
        context.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.Name, "Owner")], "Test"));
        var calls = 0;
        using var http = new HttpClient(new FakeHttpHandler((_, _) =>
        {
            calls++;
            return Task.FromResult(TiendanubeClientTests.Json(
                """{"user_id":123,"access_token":"fake-token","scope":"read_orders"}"""));
        }));
        var credentials = new FakeCredentials();
        var result = await TiendanubeOAuth.CallbackAsync(context, Config, states,
            new TiendanubeTokenClient(http, Config), credentials, NullLoggerFactory.Instance);

        Assert.Equal(valid ? "/?tiendanube=ok" : "/?tiendanube=error", Assert.IsType<RedirectHttpResult>(result).Url);
        Assert.Contains("expires=Thu, 01 Jan 1970", context.Response.Headers.SetCookie.ToString());
        Assert.Equal(valid ? 1 : 0, calls);
        if (valid)
        {
            Assert.Equal((123L, "fake-token", "read_orders", "Owner"), credentials.Saved!.Value);
        }
        else
        {
            Assert.Null(credentials.Saved);
        }
    }

    [Fact]
    public async Task BothEndpointsRequireOwnerRole()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddScoped<TiendanubeOAuthState>();
        builder.Services.AddSingleton(new TiendanubeTokenClient(new HttpClient(), Config));
        builder.Services.AddScoped<Mismade.Application.ITiendanubeCredenciales, FakeCredentials>();
        await using var app = builder.Build();
        app.MapTiendanubeOAuth();
        var endpoints = ((IEndpointRouteBuilder)app).DataSources.SelectMany(source => source.Endpoints).ToArray();
        Assert.Equal(2, endpoints.Length);
        Assert.All(endpoints, endpoint =>
        {
            var policies = endpoint.Metadata.GetOrderedMetadata<AuthorizationPolicy>();
            Assert.Contains(policies.SelectMany(p => p.Requirements).OfType<RolesAuthorizationRequirement>(),
                requirement => requirement.AllowedRoles.Contains("Owner"));
        });
    }

    [Fact]
    public async Task CallbackFailureNeverLogsCodeTokenSecretOrException()
    {
        var states = new TiendanubeOAuthState(new EphemeralDataProtectionProvider());
        var (state, cookie) = states.Create();
        var context = new DefaultHttpContext();
        context.Request.Headers.Cookie = $"{TiendanubeOAuth.CookieName}={cookie}";
        context.Request.QueryString = new QueryString($"?state={state}&code=fake-code");
        using var http = new HttpClient(new FakeHttpHandler((_, _) =>
            throw new HttpRequestException("fake-code fake-secret fake-token")));
        var logs = new CapturedLogs();
        using var loggerFactory = LoggerFactory.Create(builder => builder.AddProvider(logs));
        var credentials = new FakeCredentials();

        var result = await TiendanubeOAuth.CallbackAsync(context, Config, states,
            new TiendanubeTokenClient(http, Config), credentials, loggerFactory);
        Assert.Equal("/?tiendanube=error", Assert.IsType<RedirectHttpResult>(result).Url);
        Assert.Null(credentials.Saved);
        var message = Assert.Single(logs.Messages);
        Assert.DoesNotContain("fake-code", message);
        Assert.DoesNotContain("fake-secret", message);
        Assert.DoesNotContain("fake-token", message);
    }

    [Fact]
    public async Task ConfiguredOverridesNeverReadDatabase()
    {
        var options = Options.Create(new TiendanubeOptions { StoreId = "456", AccessToken = "fake-override" });
        var credentials = new TiendanubeCredenciales(new UnusedDatabase(), new EphemeralDataProtectionProvider(), options);
        Assert.Equal((456L, "fake-override"), await credentials.GetAsync(default));
    }

    [Fact]
    public void DatabaseModelEnforcesSingleConnectionRow()
    {
        using var db = new MismadeDbContext(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseNpgsql("Host=localhost;Database=fake;Username=fake;Password=fake").Options);
        var entity = db.GetService<Microsoft.EntityFrameworkCore.Metadata.IDesignTimeModel>().Model
            .FindEntityType(typeof(Mismade.Domain.TiendanubeConexion))!;
        Assert.Equal("\"Id\" = 1", Assert.Single(entity.GetCheckConstraints()).Sql);
        Assert.Equal(Microsoft.EntityFrameworkCore.Metadata.ValueGenerated.Never, entity.FindProperty("Id")!.ValueGenerated);
    }

    private sealed class UnusedDatabase : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext() => throw new InvalidOperationException("No debe consultar la base.");
    }

    private sealed class CapturedLogs : ILoggerProvider, ILogger
    {
        public List<string> Messages { get; } = [];
        public ILogger CreateLogger(string categoryName) => this;
        public bool IsEnabled(LogLevel logLevel) => true;
        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state,
            Exception? exception, Func<TState, Exception?, string> formatter)
        {
            Assert.Null(exception);
            Messages.Add(formatter(state, exception));
        }
        public void Dispose() { }
    }
}
