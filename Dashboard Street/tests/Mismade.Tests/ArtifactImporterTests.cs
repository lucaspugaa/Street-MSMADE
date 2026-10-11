using System.Text.Json;
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

    private void PrepararColecciones()
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
    }

    [Fact]
    public async Task ImportaCadaColeccionConSusRelaciones()
    {
        PrepararColecciones();

        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);

        var resumen = await ArtifactImporter.ImportarAsync(db, carpeta, default);

        Assert.Equal(2, resumen["Variantes de remeras"]);
        var remera = await db.StockRemeras.SingleAsync();
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
        await CrearEsquemaAsync(db);
        await ArtifactImporter.ImportarAsync(db, carpeta, default);

        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => ArtifactImporter.ImportarAsync(db, carpeta, default));
        Assert.Contains("GastosManuales", error.Message);
        Assert.Contains("--reemplazar", error.Message);
        Assert.Equal(1, await db.GastosManuales.CountAsync());
    }

    [Fact]
    public async Task RechazaVariantesDeUnaRemeraInexistente()
    {
        Doc("stock_variant_map", "rosa_regular_s", """{"variants":[{"product_id":1,"variant_id":11}]}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);

        await Assert.ThrowsAsync<InvalidDataException>(() => ArtifactImporter.ImportarAsync(db, carpeta, default));
        Assert.False(await db.StockVariantMaps.AnyAsync());
    }

    [Fact]
    public async Task UltimaCarpetaReemplazaColeccionEnteraConLayoutAnidado()
    {
        Doc("stock_remeras", "vieja", """{"color":"Blanco","corte":"Regular","talle":"S","stock":9}""");
        Doc("stock_remeras", "negro", """{"color":"Negro","corte":"Regular","talle":"L","stock":12}""");
        var segunda = Path.Combine(carpeta, "segunda");
        Directory.CreateDirectory(Path.Combine(segunda, "stock_remeras", "stock_remeras"));
        File.WriteAllText(Path.Combine(segunda, "stock_remeras", "stock_remeras", "negro.json"),
            """{"color":"Negro","corte":"Regular","talle":"L","stock":3}""");
        Doc("gastos_manuales", "f", """{"date":"2026-09-14","category":"Alquiler","amount":1}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);

        await ArtifactImporter.ImportarAsync(db, [carpeta, segunda], false, default);

        Assert.Equal(3, (await db.StockRemeras.SingleAsync()).Stock);
        Assert.Equal(1, await db.GastosManuales.CountAsync());
    }

    [Theory]
    [InlineData(StockPrenda.Buzo, "buzo:crema_l")]
    [InlineData(StockPrenda.Pantalon, "pantalon:crema_l")]
    [InlineData(StockPrenda.Conjunto, "conjunto:crema_l")]
    public void ClavePrendaNormaliza(string tipo, string esperada) =>
        Assert.Equal(esperada, PoolKeys.Prenda(tipo, " Crema ", " L "));

    [Fact]
    public async Task ImportaDesacoplesVariantesYMetadatos()
    {
        Doc("stock_variant_map_meta", "negro_regular_l_desacoplado",
            """{"pool_key":"negro_regular_l","stock_at_decouple":3,"auto_created":true,"reason":"stock bajo","created_at":"2026-10-10T03:00:00Z"}""");
        Doc("stock_variant_map_meta", "excluded_products", "{}");
        Doc("stock_buzos", "crema_l", """{"color":"Crema","talle":"L","stock":2}""");
        Doc("stock_pantalones", "crema_l", """{"color":"Crema","talle":"L","stock":4}""");
        Doc("stock_variant_map_buzos", "crema_l", """{"variants":[{"product_id":1,"variant_id":11}]}""");
        Doc("stock_variant_map_pantalones", "crema_l", """{"variants":[{"product_id":2,"variant_id":22}]}""");
        Doc("stock_buzos_pantalones_meta", "sync_watermark", """{"last_order_number_synced":1788}""");
        Doc("stock_buzos_pantalones_meta", "last_pushed",
            """{"buzo_values":{"crema_l":{"push_value":2}},"pantalon_values":{"crema_l":{"push_value":4}},"conjunto_values":{"crema_l":{"push_value":2}}}""");
        Doc("stock_manual_pools", "buzo_negro_xxl_regular", """{"label":"Buzo Negro XXL Regular","stock":2}""");
        Doc("stock_manual_pools_meta", "buzo_negro_xxl_regular_watermark", """{"last_order_number_synced":1787}""");
        Doc("stock_manual_pools_meta", "buzo_negro_xxl_regular_last_pushed", """{"stock":2}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);

        var resumen = await ArtifactImporter.ImportarAsync(db, [carpeta], false, default);

        var desacople = await db.StockDesacoples.SingleAsync();
        Assert.Equal(("negro_regular_l", 3, true, "stock bajo"),
            (desacople.PoolKey, desacople.StockAtDecouple, desacople.AutoCreated, desacople.Reason));
        Assert.Equal(DateTimeOffset.Parse("2026-10-10T03:00:00Z"), desacople.CreatedAt);
        var variantes = await db.StockPrendaVariants.Include(x => x.StockPrenda).OrderBy(x => x.TiendanubeVariantId).ToListAsync();
        Assert.Equal((StockPrenda.Buzo, 1L, 11L),
            (variantes[0].StockPrenda.Tipo, variantes[0].TiendanubeProductId, variantes[0].TiendanubeVariantId));
        Assert.Equal((StockPrenda.Pantalon, 2L, 22L),
            (variantes[1].StockPrenda.Tipo, variantes[1].TiendanubeProductId, variantes[1].TiendanubeVariantId));
        Assert.Equal(1788, (await db.SyncWatermarks.SingleAsync(x => x.Clave == StockSyncStore.PrendasClave)).LastOrderNumberSynced);
        var watermark = await db.StockManualPoolWatermarks.SingleAsync();
        Assert.Equal((await db.StockManualPools.SingleAsync()).Id, watermark.StockManualPoolId);
        Assert.Equal(1787, watermark.LastOrderNumberSynced);
        var enviados = await db.LastPushedStocks.ToDictionaryAsync(x => x.PoolKey, x => x.Stock);
        Assert.Equal(2, enviados["buzo:crema_l"]);
        Assert.Equal(4, enviados["pantalon:crema_l"]);
        Assert.Equal(2, enviados["conjunto:crema_l"]);
        Assert.Equal(2, enviados["manual:buzo_negro_xxl_regular"]);
        Assert.Equal(1, resumen["Desacoples"]);
        Assert.Equal(1, resumen["Variantes de buzo"]);
        Assert.Equal(1, resumen["Variantes de pantalon"]);
        Assert.Equal(3, resumen["Último stock enviado de prendas"]);
        Assert.Equal(1, resumen["Watermarks de pools manuales"]);

        var repetido = await ArtifactImporter.ImportarAsync(db, [carpeta], true, default);
        Assert.Equal(resumen.OrderBy(x => x.Key), repetido.OrderBy(x => x.Key));
        Assert.Equal(1, await db.StockDesacoples.CountAsync());
        Assert.Equal(2, await db.StockPrendaVariants.CountAsync());
        Assert.Equal(1, await db.StockManualPoolWatermarks.CountAsync());
        Assert.Equal(4, await db.LastPushedStocks.CountAsync());
    }

    [Theory]
    [InlineData("stock_variant_map_buzos", "crema_l", """{"variants":[{"product_id":1,"variant_id":11}]}""")]
    [InlineData("stock_variant_map_pantalones", "crema_l", """{"variants":[{"product_id":1,"variant_id":11}]}""")]
    [InlineData("stock_manual_pools_meta", "inexistente_watermark", """{"last_order_number_synced":1}""")]
    [InlineData("stock_manual_pools_meta", "inexistente_last_pushed", """{"stock":1}""")]
    public async Task RechazaRelacionesInexistentes(string coleccion, string id, string json)
    {
        Doc(coleccion, id, json);
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);

        await Assert.ThrowsAsync<InvalidDataException>(() =>
            ArtifactImporter.ImportarAsync(db, [carpeta], false, default));
    }

    [Theory]
    [InlineData("""{"ModoSombra":false}""", false)]
    [InlineData("""{"ModoSombra":true}""", true)]
    [InlineData("{}", false)]
    [InlineData("invalido", false)]
    [InlineData(null, false)]
    public async Task ExigeModoSombraEnUltimoExitoso(string? detalle, bool permite)
    {
        Doc("gastos_manuales", "f", """{"date":"2026-09-14","category":"Alquiler","amount":1}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);
        if (detalle is not null)
        {
            db.JobRuns.Add(new JobRun
            {
                Status = EstadoJob.Succeeded, StartedAt = DateTimeOffset.UtcNow.AddDays(-2),
                Detalle = permite ? """{"ModoSombra":false}""" : """{"ModoSombra":true}"""
            });
        }

        db.JobRuns.Add(new JobRun { Status = EstadoJob.Succeeded, StartedAt = DateTimeOffset.UtcNow.AddDays(-1), Detalle = detalle });
        db.JobRuns.Add(new JobRun { Status = EstadoJob.Failed, StartedAt = DateTimeOffset.UtcNow, Detalle = """{"ModoSombra":false}""" });
        await db.SaveChangesAsync();

        if (permite)
        {
            await ArtifactImporter.ImportarAsync(db, [carpeta], false, default);
            Assert.Equal(1, await db.GastosManuales.CountAsync());
        }
        else
        {
            var error = await Assert.ThrowsAsync<InvalidOperationException>(() =>
                ArtifactImporter.ImportarAsync(db, [carpeta], true, default));
            Assert.Equal("El panel no está en modo sombra; no importo.", error.Message);
            Assert.False(await db.GastosManuales.AnyAsync());
        }
    }

    [Fact]
    public async Task ReemplazaSinTocarVentasNiJobsYRespetaRollbackExterno()
    {
        PrepararColecciones();

        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);
        var venta = new Venta { TiendanubeOrderId = 123, Items = [new VentaItem { VariantId = 456 }] };
        var job = new JobRun { Status = EstadoJob.Succeeded, StartedAt = DateTimeOffset.UtcNow, Detalle = """{"ModoSombra":true}""" };
        db.Ventas.Add(venta);
        db.JobRuns.Add(job);
        await db.SaveChangesAsync();
        await ArtifactImporter.ImportarAsync(db, [carpeta], false, default);
        var anterior = (await db.StockRemeras.SingleAsync()).Id;

        await using (var tx = await db.Database.BeginTransactionAsync())
        {
            await ArtifactImporter.ImportarAsync(db, [carpeta], true, default);
            Assert.NotEqual(anterior, (await db.StockRemeras.AsNoTracking().SingleAsync()).Id);
            await tx.RollbackAsync();
        }

        db.ChangeTracker.Clear();
        Assert.Equal(anterior, (await db.StockRemeras.SingleAsync()).Id);
        await ArtifactImporter.ImportarAsync(db, [carpeta], true, default);
        Assert.NotEqual(anterior, (await db.StockRemeras.SingleAsync()).Id);
        Assert.Equal(2, await db.VentaNegroItems.CountAsync());
        Assert.Equal(1, await db.CambioItemsSalida.CountAsync());
        Assert.Equal(1, await db.CambioItemsRecibidos.CountAsync());
        Assert.Equal(venta.Id, (await db.Ventas.SingleAsync()).Id);
        Assert.Equal(456, (await db.VentaItems.SingleAsync()).VariantId);
        Assert.Equal(job.Id, (await db.JobRuns.SingleAsync()).Id);
    }

    [Fact]
    public async Task ReemplazoFallidoRevierteBorrados()
    {
        Doc("gastos_manuales", "f", """{"date":"2026-09-14","category":"Alquiler","amount":1}""");
        await using var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = Db(connection);
        await CrearEsquemaAsync(db);
        await ArtifactImporter.ImportarAsync(db, [carpeta], false, default);
        Doc("stock_variant_map_buzos", "inexistente", """{"variants":[]}""");

        await Assert.ThrowsAsync<InvalidDataException>(() =>
            ArtifactImporter.ImportarAsync(db, [carpeta], true, default));

        Assert.Equal(1, await db.GastosManuales.CountAsync());
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
        await CrearEsquemaAsync(db);
        var carpetas = real.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        await using var tx = await db.Database.BeginTransactionAsync();
        var resumen = await ArtifactImporter.ImportarAsync(db, carpetas, false, default);
        foreach (var (tabla, filas) in resumen)
        {
            Console.WriteLine($"{tabla}: {filas}");
        }

        List<JsonElement> Documentos(string coleccion, Func<string, bool>? filtro = null)
        {
            var origen = carpetas.LastOrDefault(c => Directory.Exists(Path.Combine(c, coleccion)));
            if (origen is null)
            {
                return [];
            }

            var dir = Path.Combine(origen, coleccion);
            if (Directory.Exists(Path.Combine(dir, coleccion)))
            {
                dir = Path.Combine(dir, coleccion);
            }

            return Directory.EnumerateFiles(dir, "*.json")
                .Where(f => filtro is null || filtro(Path.GetFileNameWithoutExtension(f)))
                .Select(f =>
                {
                    using var json = JsonDocument.Parse(File.ReadAllBytes(f));
                    return json.RootElement.Clone();
                }).ToList();
        }

        int Variantes(string coleccion) => Documentos(coleccion).Sum(d =>
            d.TryGetProperty("variants", out var v) ? v.GetArrayLength() : 0);

        Assert.Equal(Documentos("stock_remeras").Count, await db.StockRemeras.CountAsync());
        Assert.Equal(Variantes("stock_variant_map"), await db.StockVariantMaps.CountAsync());
        Assert.Equal(Documentos("stock_buzos").Count + Documentos("stock_pantalones").Count, await db.StockPrendas.CountAsync());
        Assert.Equal(Variantes("stock_variant_map_buzos") + Variantes("stock_variant_map_pantalones"), await db.StockPrendaVariants.CountAsync());
        Assert.Equal(Variantes("stock_variant_map_conjuntos"), await db.StockConjuntoVariants.CountAsync());
        Assert.Equal(Documentos("stock_variant_map_meta", id => id.EndsWith("_desacoplado", StringComparison.Ordinal)).Count,
            await db.StockDesacoples.CountAsync());
        Assert.Equal(Documentos("stock_manual_pools").Count, await db.StockManualPools.CountAsync());
        Assert.Equal(Variantes("stock_manual_pools"), await db.StockManualPoolVariants.CountAsync());
        Assert.Equal(Documentos("stock_manual_pools_meta", id => id.EndsWith("_watermark", StringComparison.Ordinal)).Count,
            await db.StockManualPoolWatermarks.CountAsync());
        Assert.Equal(Documentos("stock_remeras_meta", id => id == "sync_watermark").Count
            + Documentos("stock_buzos_pantalones_meta", id => id == "sync_watermark").Count, await db.SyncWatermarks.CountAsync());
        var enviadosRemeras = Documentos("stock_remeras_meta", id => id == "last_pushed")
            .Sum(d => d.GetProperty("values").EnumerateObject().Count());
        var enviadosPrendas = Documentos("stock_buzos_pantalones_meta", id => id == "last_pushed")
            .Sum(d => new[] { "buzo_values", "pantalon_values", "conjunto_values" }
                .Sum(k => d.TryGetProperty(k, out var v) ? v.EnumerateObject().Count() : 0));
        Assert.Equal(enviadosRemeras + enviadosPrendas
            + Documentos("stock_manual_pools_meta", id => id.EndsWith("_last_pushed", StringComparison.Ordinal)).Count,
            await db.LastPushedStocks.CountAsync());
        foreach (var (coleccion, tabla) in new (string, IQueryable<Entidad>)[]
        {
            ("ventas_negro", db.VentasNegro), ("perdida_mercaderia", db.PerdidasMercaderia),
            ("cris_ledger", db.CrisLedger), ("cambios_prendas", db.CambiosPrenda),
            ("stock_cambios", db.StockCambios), ("cambios_stock_carga", db.CambioStockCargas),
            ("cambios_ventas", db.CambioVentas), ("gastos_manuales", db.GastosManuales),
            ("pago_nube_cuotas", db.PagoNubeCuotas), ("monthly_history", db.MonthlyHistories)
        })
        {
            Assert.Equal(Documentos(coleccion).Count, await tabla.CountAsync());
        }

        Assert.Equal(Documentos("ventas_negro").Sum(d => d.GetProperty("items").GetArrayLength()), await db.VentaNegroItems.CountAsync());
        Assert.Equal(Documentos("cambios_prendas").Sum(d => d.GetProperty("items_salida").GetArrayLength()), await db.CambioItemsSalida.CountAsync());
        Assert.Equal(Documentos("cambios_prendas").Sum(d => d.GetProperty("items_recibidos").GetArrayLength()), await db.CambioItemsRecibidos.CountAsync());
        await tx.RollbackAsync();
        Assert.False(await db.StockRemeras.AnyAsync());
    }

    private void Doc(string coleccion, string id, string json)
    {
        Directory.CreateDirectory(Path.Combine(carpeta, coleccion));
        File.WriteAllText(Path.Combine(carpeta, coleccion, id + ".json"), json);
    }

    // xmin es columna de sistema de PostgreSQL; en SQLite hay que darle un valor por defecto.
    private static Task CrearEsquemaAsync(MismadeDbContext db) => db.Database.ExecuteSqlRawAsync(
        db.Database.GenerateCreateScript().Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));

    private static MismadeDbContext Db(SqliteConnection connection) =>
        new(new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection).Options);
}
