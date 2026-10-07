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
        services.AddHttpClient<ITiendanubeClient, TiendanubeClient>().AddStandardResilienceHandler();
        services.AddHttpClient<IMetaAdsClient, MetaAdsClient>().AddStandardResilienceHandler();
        services.AddScoped<IJobLock, PostgresJobLock>();
        services.AddScoped<IJobRunStore, JobRunStore>();
        services.AddSingleton<IDashboardNotifier, DashboardNotifier>();
        services.AddScoped<SyncJob>();
        return services;
    }
}
