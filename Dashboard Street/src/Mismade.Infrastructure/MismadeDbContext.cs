using Microsoft.AspNetCore.DataProtection.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class MismadeDbContext(DbContextOptions<MismadeDbContext> options)
    : IdentityDbContext<IdentityUser>(options), IDataProtectionKeyContext
{
    public DbSet<DataProtectionKey> DataProtectionKeys { get; set; } = null!;
    public DbSet<JobRun> JobRuns => Set<JobRun>();
    public DbSet<StockRemera> StockRemeras => Set<StockRemera>();
    public DbSet<StockManualPool> StockManualPools => Set<StockManualPool>();
    public DbSet<StockVariantMap> StockVariantMaps => Set<StockVariantMap>();
    public DbSet<StockVariantMapExclusion> StockVariantMapExclusions => Set<StockVariantMapExclusion>();
    public DbSet<StockManualPoolVariant> StockManualPoolVariants => Set<StockManualPoolVariant>();
    public DbSet<StockManualPoolWatermark> StockManualPoolWatermarks => Set<StockManualPoolWatermark>();
    public DbSet<VentaNegro> VentasNegro => Set<VentaNegro>();
    public DbSet<VentaNegroItem> VentaNegroItems => Set<VentaNegroItem>();
    public DbSet<PerdidaMercaderia> PerdidasMercaderia => Set<PerdidaMercaderia>();
    public DbSet<CrisLedger> CrisLedger => Set<CrisLedger>();
    public DbSet<CambioPrenda> CambiosPrenda => Set<CambioPrenda>();
    public DbSet<CambioItemSalida> CambioItemsSalida => Set<CambioItemSalida>();
    public DbSet<CambioItemRecibido> CambioItemsRecibidos => Set<CambioItemRecibido>();
    public DbSet<StockCambio> StockCambios => Set<StockCambio>();
    public DbSet<CambioStockCarga> CambioStockCargas => Set<CambioStockCarga>();
    public DbSet<CambioVenta> CambioVentas => Set<CambioVenta>();
    public DbSet<GastoManual> GastosManuales => Set<GastoManual>();
    public DbSet<PagoNubeCuota> PagoNubeCuotas => Set<PagoNubeCuota>();
    public DbSet<MonthlyHistory> MonthlyHistories => Set<MonthlyHistory>();
    public DbSet<SyncWatermark> SyncWatermarks => Set<SyncWatermark>();
    public DbSet<LastPushedStock> LastPushedStocks => Set<LastPushedStock>();
    public DbSet<ConfigHistorica> ConfigHistorica => Set<ConfigHistorica>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        foreach (var type in typeof(Entidad).Assembly.GetTypes()
            .Where(t => t.IsClass && !t.IsAbstract && typeof(Entidad).IsAssignableFrom(t)))
        {
            modelBuilder.Entity(type);
        }

        modelBuilder.Entity<StockRemera>().HasIndex(x => new { x.Color, x.Corte, x.Talle }).IsUnique();
        modelBuilder.Entity<StockCambio>().HasIndex(x => new { x.Color, x.Corte, x.Talle }).IsUnique();
        modelBuilder.Entity<PagoNubeCuota>().HasIndex(x => x.OrderNumber).IsUnique();
        modelBuilder.Entity<StockManualPoolWatermark>().HasIndex(x => x.StockManualPoolId).IsUnique();
        modelBuilder.Entity<MonthlyHistory>().Property(x => x.Mes).HasMaxLength(7);
        modelBuilder.Entity<StockRemera>().Property<uint>("xmin").IsRowVersion();
        modelBuilder.Entity<StockManualPool>().Property<uint>("xmin").IsRowVersion();

        modelBuilder.Entity<CambioItemSalida>().HasOne(x => x.CambioPrenda)
            .WithMany(x => x.ItemsSalida).HasForeignKey(x => x.CambioPrendaId)
            .OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<CambioItemRecibido>().HasOne(x => x.CambioPrenda)
            .WithMany(x => x.ItemsRecibidos).HasForeignKey(x => x.CambioPrendaId)
            .OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<VentaNegroItem>().HasOne(x => x.VentaNegro)
            .WithMany(x => x.Items).HasForeignKey(x => x.VentaNegroId)
            .OnDelete(DeleteBehavior.Cascade);

        foreach (var property in modelBuilder.Model.GetEntityTypes().SelectMany(x => x.GetProperties())
            .Where(p => p.ClrType == typeof(decimal) || p.ClrType == typeof(decimal?)))
        {
            property.SetPrecision(18);
            property.SetScale(2);
        }
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<Entidad>().Where(x => x.State == EntityState.Modified))
        {
            entry.Entity.UpdatedAt = DateTimeOffset.UtcNow;
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
