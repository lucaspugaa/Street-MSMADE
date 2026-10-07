using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Mismade.Infrastructure;

public sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<MismadeDbContext>
{
    public MismadeDbContext CreateDbContext(string[] args)
    {
        var connection = Environment.GetEnvironmentVariable("ConnectionStrings__Default")
            ?? "Host=localhost;Database=mismade;Username=postgres;Password=dev";

        return new MismadeDbContext(new DbContextOptionsBuilder<MismadeDbContext>()
            .UseNpgsql(connection).Options);
    }
}
