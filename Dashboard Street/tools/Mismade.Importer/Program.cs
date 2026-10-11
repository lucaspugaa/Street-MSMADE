// Importa el export JSON del dashboard anterior (artifact) a PostgreSQL.
// Uso: dotnet run --project tools/Mismade.Importer -- <carpeta-export> [--confirmar]
// La cadena sale de ConnectionStrings__Default (por defecto, el Postgres local de docker-compose).
// Sin --confirmar solo muestra a qué base apunta y qué importaría, sin escribir nada.
using Microsoft.EntityFrameworkCore;
using Mismade.Infrastructure;
using Npgsql;

if (args.Length == 0 || args[0].StartsWith("--", StringComparison.Ordinal))
{
    Console.Error.WriteLine("Uso: Mismade.Importer <carpeta-export> [--confirmar]");
    return 2;
}

var carpeta = Path.GetFullPath(args[0]);
var confirmar = args.Contains("--confirmar");
var cadena = PostgresConnectionString.Normalize(
    Environment.GetEnvironmentVariable("ConnectionStrings__Default")
    ?? "Host=localhost;Database=mismade;Username=postgres;Password=dev");
var destino = new NpgsqlConnectionStringBuilder(cadena);
Console.WriteLine($"Base destino: {destino.Host}/{destino.Database}");
Console.WriteLine($"Export: {carpeta}");

await using var db = new MismadeDbContext(new DbContextOptionsBuilder<MismadeDbContext>().UseNpgsql(cadena).Options);
var pendientes = (await db.Database.GetPendingMigrationsAsync()).ToList();
if (pendientes.Count > 0)
{
    Console.Error.WriteLine("La base tiene migraciones pendientes; arrancá la app una vez antes de importar: "
        + string.Join(", ", pendientes));
    return 1;
}

await using var tx = await db.Database.BeginTransactionAsync();
var resumen = await ArtifactImporter.ImportarAsync(db, carpeta, CancellationToken.None);
foreach (var (tabla, filas) in resumen)
{
    Console.WriteLine($"  {tabla,-30} {filas,5}");
}

if (!confirmar)
{
    await tx.RollbackAsync();
    Console.WriteLine("Prueba sin escribir. Repetí con --confirmar para guardar.");
    return 0;
}

await tx.CommitAsync();
Console.WriteLine("Importación guardada.");
return 0;
