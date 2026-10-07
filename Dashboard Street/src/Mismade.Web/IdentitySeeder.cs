using Microsoft.AspNetCore.Identity;

namespace Mismade.Web;

/// <summary>
/// Crea los roles y, si todavía no existe ningún Owner, el Owner inicial a partir de
/// Seed:OwnerUser / Seed:OwnerPassword (opcional Seed:OwnerEmail). Una vez que hay un
/// Owner no toca nada: cambiar la clave en la config no pisa la del usuario existente.
/// </summary>
public static class IdentitySeeder
{
    public const string OwnerRole = "Owner";
    public const string OperadorRole = "Operador";

    public static async Task SeedAsync(IServiceProvider services)
    {
        var roles = services.GetRequiredService<RoleManager<IdentityRole>>();
        var users = services.GetRequiredService<UserManager<IdentityUser>>();
        var configuration = services.GetRequiredService<IConfiguration>();
        var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger(nameof(IdentitySeeder));

        foreach (var role in new[] { OwnerRole, OperadorRole })
        {
            if (!await roles.RoleExistsAsync(role))
            {
                Ensure(await roles.CreateAsync(new IdentityRole(role)), $"crear el rol {role}");
            }
        }

        if ((await users.GetUsersInRoleAsync(OwnerRole)).Count > 0)
        {
            return;
        }

        var userName = configuration["Seed:OwnerUser"];
        var password = configuration["Seed:OwnerPassword"];
        if (string.IsNullOrWhiteSpace(userName) || string.IsNullOrEmpty(password))
        {
            logger.LogWarning("No hay ningún usuario Owner. Definí Seed__OwnerUser y Seed__OwnerPassword y reiniciá la app.");
            return;
        }

        var user = await users.FindByNameAsync(userName);
        if (user is null)
        {
            user = new IdentityUser { UserName = userName, Email = NullIfEmpty(configuration["Seed:OwnerEmail"]) };
            Ensure(await users.CreateAsync(user, password), $"crear el usuario {userName}");
        }

        Ensure(await users.AddToRoleAsync(user, OwnerRole), $"asignar Owner a {userName}");
        logger.LogInformation("Owner inicial {User} creado. Ya podés borrar Seed__OwnerPassword.", userName);
    }

    private static void Ensure(IdentityResult result, string action)
    {
        if (!result.Succeeded)
        {
            throw new InvalidOperationException(
                $"No se pudo {action}: {string.Join("; ", result.Errors.Select(x => x.Description))}");
        }
    }

    private static string? NullIfEmpty(string? value) => string.IsNullOrWhiteSpace(value) ? null : value;
}
