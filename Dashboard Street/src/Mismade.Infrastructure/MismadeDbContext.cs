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
    public DbSet<Venta> Ventas => Set<Venta>();
    public DbSet<VentaItem> VentaItems => Set<VentaItem>();
    public DbSet<VentasSyncEstado> VentasSyncEstados => Set<VentasSyncEstado>();
    public DbSet<JobRun> JobRuns => Set<JobRun>();
    public DbSet<MetaInsightEntity> MetaInsights => Set<MetaInsightEntity>();
    public DbSet<TiendanubeConexion> TiendanubeConexiones => Set<TiendanubeConexion>();
    public DbSet<StockRemera> StockRemeras => Set<StockRemera>();
    public DbSet<StockManualPool> StockManualPools => Set<StockManualPool>();
    public DbSet<StockVariantMap> StockVariantMaps => Set<StockVariantMap>();
    public DbSet<StockVariantMapExclusion> StockVariantMapExclusions => Set<StockVariantMapExclusion>();
    public DbSet<StockPrenda> StockPrendas => Set<StockPrenda>();
    public DbSet<StockConjuntoVariant> StockConjuntoVariants => Set<StockConjuntoVariant>();
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

        modelBuilder.Entity<MetaInsightEntity>().ToTable("MetaInsights");
        modelBuilder.Entity<MetaInsightEntity>().HasKey(x => new { x.Cuenta, x.Fecha, x.CampaignId });

        modelBuilder.Entity<TiendanubeConexion>().ToTable("TiendanubeConexiones",
            table => table.HasCheckConstraint("CK_TiendanubeConexion_Unica", "\"Id\" = 1"));
        modelBuilder.Entity<TiendanubeConexion>().Property(x => x.Id).ValueGeneratedNever();

        foreach (var type in typeof(Entidad).Assembly.GetTypes()
            .Where(t => t.IsClass && !t.IsAbstract && typeof(Entidad).IsAssignableFrom(t)))
        {
            modelBuilder.Entity(type);
        }

        modelBuilder.Entity<Venta>().HasIndex(x => x.TiendanubeOrderId).IsUnique();
        modelBuilder.Entity<Venta>().HasIndex(x => x.Number);
        modelBuilder.Entity<VentasSyncEstado>().HasIndex(x => x.Clave).IsUnique();
        modelBuilder.Entity<VentasSyncEstado>().ToTable("VentasSyncEstados",
            table => table.HasCheckConstraint("CK_VentasSyncEstado_Unico", "\"Clave\" = 'ventas'"));
        modelBuilder.Entity<VentaItem>().HasOne(x => x.Venta)
            .WithMany(x => x.Items).HasForeignKey(x => x.VentaId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<StockRemera>().HasIndex(x => new { x.Color, x.Corte, x.Talle }).IsUnique();
        modelBuilder.Entity<StockCambio>().HasIndex(x => new { x.Color, x.Corte, x.Talle }).IsUnique();
        modelBuilder.Entity<StockPrenda>().HasIndex(x => new { x.Tipo, x.Color, x.Talle }).IsUnique();
        modelBuilder.Entity<StockConjuntoVariant>().HasIndex(x => x.TiendanubeVariantId).IsUnique();
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
            property.SetPrecision(property.DeclaringType.ClrType == typeof(Venta)
                || property.DeclaringType.ClrType == typeof(VentaItem) ? 14 : 18);
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
