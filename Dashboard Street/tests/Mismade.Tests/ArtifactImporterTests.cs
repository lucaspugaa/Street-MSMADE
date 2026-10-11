using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class ArtifactImporterTests : IDisposable
{
    private readonly string carpeta = Directory.CreateTempSubdirectory("export-mismade-").FullName;

    public void Dispose() => Directory.Delete(carpeta, recursive: true);

    [Fact]
    public async Task ImportaCadaColeccionConSusRelaciones()
    {
        Doc("stock_remeras", "negro_oversize_l", """{"color":"Negro","corte":"Oversize","talle":"L","stock":12,"updated_at":"2026-10-05T03:02:00Z"}""");
        Doc("stock_variant_map", "negro_oversize_l", """{"count":2,"variants":[{"product_id":1,"variant_id":11},{"product_id":2,"variant_id":22}]}""");
        Doc("stock_buzos", "crema_l", """{"color":"Crema","talle":"L","stock":0}""");
        Doc("stock_pantalones", "crema_l", """{"color":"Crema","talle":"L","stock":1}""");
        Doc("stock_variant_map_conjuntos", "crema_l", """{"buzo_pool_key":"crema_l","pantalon_pool_key":"crema_l","effective_stock":0,"variants":[{"product_id":3,"variant_id":33}]}""");
        Doc("stock_manual_pools", "buzo_negro_xxl_regular", """{"label":"Buzo Negro XXL Regular (pool manual, 2 unidades reales)","stock":2,"variants":[{"product_id":4,"variant_id":44}]}""");
        Doc("stock_remeras_meta", "sync_watermark", """{"last_order_number_synced":1763}""");
        Doc("stock_remeras_meta", "last_pushed", """{"values":{"negro_oversize_l":12}}""");
        Doc("ventas_negro", "a", """{"date":"2026-10-01","note":"","total_amount":38000,"created_at":"2026-10-01T20:18:24.618Z","items":[{"cantidad":1,"color":"Gris","corte":"Oversize","talle":"XXL"},{"cantidad":1,"color":"Negro","corte":"Oversize","talle":"S","tipo":"buzo"}]}""");
        Doc("perdida_mercaderia", "b", """{"date":"2026-10-09","cantidad":1,"color":"Blanco","corte":"Oversize","talle":"S","motivo":"Mal estampado","nota":""}""");
        Doc("cris_ledger", "c", """{"date":"2026-09-26","tipo":"saldo_inicial","amount":2222300,"nota":"Saldo inicial"}""");
        Doc("cris_ledger", "d", """{"date":"2026-10-07","tipo":"devolucion","amount":24000,"cantidad":3,"color":"Crema","corte":"Oversize","talle":"XXL","nota":""}""");
        Doc("cambios_prendas", "e", """{"date":"2026-10-09","nota":"x","items_salida":[{"cantidad":1,"color":"Negro","corte":"Regular","talle":"M"}],"items_recibidos":[{"cantidad":1,"color":"Crema","corte":"Regular","talle":"S"}]}""");
        Doc("stock_cambios", "crema_regular_l", """{"color":"Crema","corte":"Regular","talle":"L","disponible":2}""");
        Doc("gastos_manuales", "f", """{"date":"2026-09-14","category":"Alquiler","description":"","amount":1000000}""");
        Doc("pago_nube_cuotas", "1334", """{"date":"2026-08-19","order_number":1334,"status":"cuotas","total":114299.1,"marked_at":"2026-09-17T14:19:21.258Z"}""");
        Doc("monthly_history", "2026-01", """{"month":"2026-01","orders":61,"revenue":3016436.15,"margin":1651625.5,"fee":149674.37,"shipping":0,"cogs":1020000,"ads_street":195136.28,"ads_kumo":0,"closed":true}""");

        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await db.Database.EnsureCreatedAsync();

        var resumen = await ArtifactImporter.ImportarAsync(db, carpeta, default);

        Assert.Equal(2, resumen["Variantes de remeras"]);
        var remera = await db.StockRemeras.Include(r => r.Id == Guid.Empty ? null! : r).SingleAsync();
        Assert.Equal(12, remera.Stock);
        Assert.All(await db.StockVariantMaps.ToListAsync(), v => Assert.Equal(remera.Id, v.StockRemeraId));
        Assert.Equal(2, await db.StockPrendas.CountAsync());
        var conjunto = await db.StockConjuntoVariants.SingleAsync();
        Assert.Equal(("Crema", "L", 33L), (conjunto.Color, conjunto.Talle, conjunto.TiendanubeVariantId));

        var pool = await db.StockManualPools.SingleAsync();
        Assert.Equal("manual:buzo_negro_xxl_regular", PoolKeys.Manual(pool.Nombre));
        Assert.Equal(44, (await db.StockManualPoolVariants.SingleAsync()).TiendanubeVariantId);
        Assert.Equal(1763, (await db.SyncWatermarks.SingleAsync(w => w.Clave == StockSyncStore.RemerasClave)).LastOrderNumberSynced);
        Assert.Equal(12, (await db.LastPushedStocks.SingleAsync(x => x.PoolKey == "negro_oversize_l")).Stock);

        var venta = await db.VentasNegro.Include(v => v.Items).SingleAsync();
        Assert.Null(venta.Nota);
        Assert.Equal(new DateTimeOffset(2026, 10, 1, 20, 18, 24, 618, TimeSpan.Zero), venta.CreatedAt);
        Assert.Equal(["buzo", "remera"], venta.Items.Select(i => i.Tipo).Order());

        var devolucion = await db.CrisLedger.SingleAsync(x => x.Tipo == TipoMovimientoCris.Devolucion);
        Assert.Equal((3, "XXL"), (devolucion.Cantidad, devolucion.Talle));
        Assert.Equal(2222300m, (await db.CrisLedger.SingleAsync(x => x.Tipo == TipoMovimientoCris.SaldoInicial)).Monto);

        var cambio = await db.CambiosPrenda.Include(c => c.ItemsSalida).Include(c => c.ItemsRecibidos).SingleAsync();
        Assert.Equal(("M", "S"), (cambio.ItemsSalida.Single().Talle, cambio.ItemsRecibidos.Single().Talle));
        Assert.Equal(EstadoPagoNube.Cuotas, (await db.PagoNubeCuotas.SingleAsync()).Status);
        var mes = await db.MonthlyHistories.SingleAsync();
        Assert.Equal((61, 195136.28m, true), (mes.PedidosCount, mes.AdsStreet, mes.Closed));
        Assert.Equal(0, resumen["Ventas de prendas de cambio"]);
    }

    [Fact]
    public async Task NoImportaSobreTablasConDatos()
    {
        Doc("gastos_manuales", "f", """{"date":"2026-09-14","category":"Alquiler","description":"","amount":1}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await db.Database.EnsureCreatedAsync();
        await ArtifactImporter.ImportarAsync(db, carpeta, default);

        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => ArtifactImporter.ImportarAsync(db, carpeta, default));
        Assert.Contains("GastosManuales", error.Message);
        Assert.Equal(1, await db.GastosManuales.CountAsync());
    }

    [Fact]
    public async Task RechazaVariantesDeUnaRemeraInexistente()
    {
        Doc("stock_variant_map", "rosa_regular_s", """{"variants":[{"product_id":1,"variant_id":11}]}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await db.Database.EnsureCreatedAsync();

        await Assert.ThrowsAsync<InvalidDataException>(() => ArtifactImporter.ImportarAsync(db, carpeta, default));
        Assert.False(await db.StockVariantMaps.AnyAsync());
    }

    /// <summary>Corre el export real si se indica con MISMADE_EXPORT; los datos del cliente no se suben al repo.</summary>
    [Fact]
    public async Task ExportRealSiEstaDisponible()
    {
        var real = Environment.GetEnvironmentVariable("MISMADE_EXPORT");
        if (string.IsNullOrEmpty(real))
        {
            return;
        }

        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await db.Database.EnsureCreatedAsync();
        var resumen = await ArtifactImporter.ImportarAsync(db, real, default);
        foreach (var (tabla, filas) in resumen)
        {
            Console.WriteLine($"{tabla}: {filas}");
        }

        Assert.Equal(50, resumen["Stock remeras"]);
    }

    private void Doc(string coleccion, string id, string json)
    {
        Directory.CreateDirectory(Path.Combine(carpeta, coleccion));
        File.WriteAllText(Path.Combine(carpeta, coleccion, id + ".json"), json);
    }

    private static MismadeDbContext Db(SqliteConnection connection) =>
        new(new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection).Options);
}
