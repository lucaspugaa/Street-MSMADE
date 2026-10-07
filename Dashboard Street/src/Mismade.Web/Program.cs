using System.Security.Cryptography;
using System.Text;
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Infrastructure;
using Mismade.Web;
using Mismade.Web.Components;

var builder = WebApplication.CreateBuilder(args);
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddIdentity<IdentityUser, IdentityRole>()
    .AddEntityFrameworkStores<MismadeDbContext>().AddDefaultTokenProviders();
builder.Services.ConfigureApplicationCookie(options => options.LoginPath = "/Account/Login");
builder.Services.AddAuthorization();
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<Microsoft.AspNetCore.Components.Authorization.AuthenticationStateProvider,
    IdentityAuthenticationStateProvider>();
builder.Services.AddRazorPages();
builder.Services.AddRazorComponents().AddInteractiveServerComponents();
builder.Services.AddHealthChecks();

var mode = builder.Configuration["Jobs:Mode"] ?? "Endpoint";
if (mode.Equals("Hangfire", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddHangfire(configuration => configuration.UsePostgreSqlStorage(
        options => options.UseNpgsqlConnection(
            PostgresConnectionString.Normalize(builder.Configuration.GetConnectionString("Default")))));
    builder.Services.AddHangfireServer();
    builder.Services.AddScoped<ISyncQueue, HangfireSyncQueue>();
}
else if (mode.Equals("Endpoint", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddSingleton<SyncQueue>();
    builder.Services.AddSingleton<ISyncQueue>(services => services.GetRequiredService<SyncQueue>());
    builder.Services.AddHostedService<SyncWorker>();
}
else
{
    throw new InvalidOperationException("Jobs:Mode debe ser Endpoint o Hangfire.");
}

var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    scope.ServiceProvider.GetRequiredService<MismadeDbContext>().Database.Migrate();
    await IdentitySeeder.SeedAsync(scope.ServiceProvider);
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
}

app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();
app.MapStaticAssets();
app.MapRazorPages();
app.MapHealthChecks("/health").AllowAnonymous();

if (mode.Equals("Endpoint", StringComparison.OrdinalIgnoreCase))
{
    app.MapPost("/jobs/sync", async (HttpContext context, ISyncQueue queue, IConfiguration configuration) =>
    {
        var expected = configuration["Jobs:Key"];
        if (string.IsNullOrEmpty(expected))
        {
            return Results.StatusCode(StatusCodes.Status503ServiceUnavailable);
        }

        var header = context.Request.Headers["X-Job-Key"];
        if (header.Count != 1 || !JobKey.Matches(header[0] ?? "", expected))
        {
            return Results.Unauthorized();
        }

        await queue.EnqueueAsync("Endpoint", context.RequestAborted);
        return Results.Accepted();
    }).AllowAnonymous();
}
else
{
    app.UseHangfireDashboard("/hangfire", new DashboardOptions
    {
        Authorization = [new OwnerDashboardAuthorization()]
    });
    var recurring = app.Services.GetRequiredService<IRecurringJobManager>();
    recurring.AddOrUpdate<SyncJob>("sync", job => job.RunAsync("Hangfire", CancellationToken.None),
        "1 0,18 * * *", new RecurringJobOptions
        {
            TimeZone = TimeZoneInfo.FindSystemTimeZoneById("America/Argentina/Buenos_Aires")
        });
}

app.MapRazorComponents<App>().AddInteractiveServerRenderMode().RequireAuthorization();
app.Run();

internal static class JobKey
{
    public static bool Matches(string supplied, string expected) => CryptographicOperations.FixedTimeEquals(
        SHA256.HashData(Encoding.UTF8.GetBytes(supplied)),
        SHA256.HashData(Encoding.UTF8.GetBytes(expected)));
}
