using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Npgsql;

namespace Mismade.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connection = PostgresConnectionString.Normalize(configuration.GetConnectionString("Default"));

        services.AddSingleton(_ => NpgsqlDataSource.Create(connection));
        services.AddDbContextFactory<MismadeDbContext>(options => options.UseNpgsql(connection));
        services.AddDataProtection().PersistKeysToDbContext<MismadeDbContext>();
        services.Configure<TiendanubeOptions>(configuration.GetSection("Tiendanube"));
        services.Configure<MetaOptions>(configuration.GetSection("Meta"));
        services.AddScoped<ITiendanubeCredenciales, TiendanubeCredenciales>();
        services.AddHttpClient<TiendanubeTokenClient>().RemoveAllLoggers();
        services.AddHttpClient<ITiendanubeClient, TiendanubeClient>()
            .RedactLoggedHeaders(["Authentication"])
            .AddStandardResilienceHandler(options =>
            {
                options.Retry.ShouldRetryAfterHeader = false;
                options.Retry.DelayGenerator = args =>
                    new ValueTask<TimeSpan?>(TiendanubeRateLimit.GetDelay(args.Outcome.Result));
            });
        services.AddHttpClient<IMetaAdsClient, MetaAdsClient>(http => http.Timeout = TimeSpan.FromSeconds(60))
            .RemoveAllLoggers();
        services.AddScoped<IMetaConfiguration>(provider =>
            provider.GetRequiredService<Microsoft.Extensions.Options.IOptions<MetaOptions>>().Value);
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<IMetaInsightStore, MetaInsightStore>();
        services.AddScoped<IMetaSyncStep, MetaSyncStep>();
        services.AddScoped<IJobLock, PostgresJobLock>();
        services.AddScoped<IJobRunStore, JobRunStore>();
        services.AddSingleton<IDashboardNotifier, DashboardNotifier>();
        services.AddScoped<IStockSyncStore, StockSyncStore>();
        services.AddScoped<IStockSyncStep, StockSyncStep>();
        services.AddScoped<IVentasConfiguration>(provider =>
            provider.GetRequiredService<Microsoft.Extensions.Options.IOptions<TiendanubeOptions>>().Value);
        services.AddScoped<IVentasStore, VentasStore>();
        services.AddScoped<IVentasSyncStep, VentasSyncStep>();
        services.AddScoped<FinanzasConsulta>();
        services.AddScoped<SyncJob>();
        return services;
    }
}
