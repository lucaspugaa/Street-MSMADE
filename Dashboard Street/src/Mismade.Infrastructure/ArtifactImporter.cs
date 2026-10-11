using System.Globalization;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Mismade.Domain;

namespace Mismade.Infrastructure;

/// <summary>
/// Pasa a PostgreSQL el export JSON de la base del dashboard anterior (un archivo por documento,
/// en <c>&lt;carpeta&gt;/&lt;colección&gt;/&lt;id&gt;.json</c>). Acepta varios exports y reemplazo transaccional de las tablas del artifact.
/// </summary>
public static class ArtifactImporter
{
    public static Task<IReadOnlyDictionary<string, int>> ImportarAsync(
        MismadeDbContext db, string carpeta, CancellationToken ct) =>
        ImportarAsync(db, [carpeta], false, ct);

    public static async Task<IReadOnlyDictionary<string, int>> ImportarAsync(
        MismadeDbContext db, IReadOnlyList<string> carpetas, bool reemplazar, CancellationToken ct)
    {
        if (carpetas.Count == 0)
        {
            throw new ArgumentException("Indicá al menos una carpeta del export.", nameof(carpetas));
        }

        foreach (var carpeta in carpetas)
        {
            if (!Directory.Exists(carpeta))
            {
                throw new DirectoryNotFoundException($"No existe la carpeta del export: {carpeta}");
            }
        }

        await VerificarModoSombraAsync(db, ct);
        await using var tx = db.Database.CurrentTransaction is null
            ? await db.Database.BeginTransactionAsync(ct)
            : null;

        if (reemplazar)
        {
            await BorrarAsync(db, ct);
        }
        else
        {
            var ocupadas = await TablasConDatosAsync(db, ct);
            if (ocupadas.Count > 0)
            {
                throw new InvalidOperationException(
                    "La importación necesita las tablas vacías. Usá --reemplazar. Ya tienen datos: "
                    + string.Join(", ", ocupadas));
            }
        }

        var resumen = new Dictionary<string, int>();
        var lector = new Lector(carpetas);

        var remeras = new Dictionary<string, StockRemera>();
        foreach (var (_, d) in lector.Leer("stock_remeras"))
        {
            var remera = new StockRemera
            {
                Color = d.Texto("color"), Corte = d.Texto("corte"), Talle = d.Texto("talle"), Stock = d.Entero("stock")
            };
            Fechas(remera, d);
            remeras.Add(PoolKeys.Remera(remera.Color, remera.Corte, remera.Talle), remera);
        }
        db.StockRemeras.AddRange(remeras.Values);
        resumen["Stock remeras"] = remeras.Count;

        var variantes = new List<StockVariantMap>();
        foreach (var (id, d) in lector.Leer("stock_variant_map"))
        {
            if (!remeras.TryGetValue(id, out var remera))
            {
                throw new InvalidDataException($"stock_variant_map/{id} no corresponde a ninguna remera de stock_remeras.");
            }

            variantes.AddRange(d.Variantes().Select(v => new StockVariantMap
            {
                StockRemera = remera, TiendanubeProductId = v.Producto, TiendanubeVariantId = v.Variante
            }));
        }
        db.StockVariantMaps.AddRange(variantes);
        resumen["Variantes de remeras"] = variantes.Count;

        var prendas = new Dictionary<string, StockPrenda>();
        foreach (var (coleccion, tipo) in new[] { ("stock_buzos", StockPrenda.Buzo), ("stock_pantalones", StockPrenda.Pantalon) })
        {
            foreach (var (_, d) in lector.Leer(coleccion))
            {
                var prenda = new StockPrenda { Tipo = tipo, Color = d.Texto("color"), Talle = d.Texto("talle"), Stock = d.Entero("stock") };
                Fechas(prenda, d);
                prendas.Add(ClavePrenda(tipo, prenda.Color + "_" + prenda.Talle), prenda);
            }
        }
        db.StockPrendas.AddRange(prendas.Values);
        resumen["Stock buzos y pantalones"] = prendas.Count;

        resumen["Desacoples"] = Agregar(db,
            lector.Leer("stock_variant_map_meta").Where(x => x.Id.EndsWith("_desacoplado", StringComparison.Ordinal)),
            d => new StockDesacople
            {
                PoolKey = d.Texto("pool_key"), StockAtDecouple = d.Entero("stock_at_decouple"),
                AutoCreated = d.Raiz.GetProperty("auto_created").GetBoolean(), Reason = d.Texto("reason")
            });

        var prendasVariantes = new List<StockPrendaVariant>();
        foreach (var (coleccion, tipo) in new[]
            { ("stock_variant_map_buzos", StockPrenda.Buzo), ("stock_variant_map_pantalones", StockPrenda.Pantalon) })
        {
            var cantidad = 0;
            foreach (var (id, d) in lector.Leer(coleccion))
            {
                if (!prendas.TryGetValue(ClavePrenda(tipo, id), out var prenda))
                {
                    throw new InvalidDataException($"{coleccion}/{id} no corresponde a ninguna prenda.");
                }

                var filas = d.Variantes().Select(v => new StockPrendaVariant
                {
                    StockPrenda = prenda, TiendanubeProductId = v.Producto, TiendanubeVariantId = v.Variante
                }).ToList();
                prendasVariantes.AddRange(filas);
                cantidad += filas.Count;
            }

            resumen["Variantes de " + tipo.ToLowerInvariant()] = cantidad;
        }

        db.StockPrendaVariants.AddRange(prendasVariantes);

        var conjuntos = new List<StockConjuntoVariant>();
        foreach (var (id, d) in lector.Leer("stock_variant_map_conjuntos"))
        {
            // El id es "<color>_<talle>"; el color y talle con mayúsculas salen del pool de buzos.
            if (!prendas.TryGetValue(ClavePrenda(StockPrenda.Buzo, d.TextoOpcional("buzo_pool_key") ?? id), out var buzo))
            {
                throw new InvalidDataException($"stock_variant_map_conjuntos/{id} no tiene buzo con ese color y talle.");
            }

            conjuntos.AddRange(d.Variantes().Select(v => new StockConjuntoVariant
            {
                Color = buzo.Color, Talle = buzo.Talle, TiendanubeProductId = v.Producto, TiendanubeVariantId = v.Variante
            }));
        }
        db.StockConjuntoVariants.AddRange(conjuntos);
        resumen["Variantes de conjuntos"] = conjuntos.Count;

        var pools = new Dictionary<string, StockManualPool>();
        foreach (var (id, d) in lector.Leer("stock_manual_pools"))
        {
            var etiqueta = d.TextoOpcional("label") ?? id;
            var nombre = etiqueta.Split(" (")[0].Trim();
            if (PoolKeys.Manual(nombre) != PoolKeys.Manual(id.Replace('_', ' ')))
            {
                throw new InvalidDataException($"stock_manual_pools/{id}: el nombre '{nombre}' no coincide con el id.");
            }

            var pool = new StockManualPool { Nombre = nombre, Stock = d.Entero("stock"), TipoPrenda = nombre.Split(' ')[0] };
            Fechas(pool, d);
            db.StockManualPools.Add(pool);
            db.StockManualPoolVariants.AddRange(d.Variantes().Select(v => new StockManualPoolVariant
            {
                StockManualPool = pool, TiendanubeProductId = v.Producto, TiendanubeVariantId = v.Variante
            }));
            pools.Add(id, pool);
        }
        resumen["Pools manuales"] = pools.Count;

        foreach (var (id, d) in lector.Leer("stock_remeras_meta"))
        {
            if (id == "sync_watermark")
            {
                db.SyncWatermarks.Add(new SyncWatermark
                {
                    Clave = StockSyncStore.RemerasClave, LastOrderNumberSynced = d.Largo("last_order_number_synced")
                });
                resumen["Watermark de pedidos"] = 1;
            }
            else if (id == "last_pushed" && d.Raiz.TryGetProperty("values", out var valores))
            {
                var enviados = valores.EnumerateObject()
                    .Select(p => new LastPushedStock { PoolKey = p.Name, Stock = p.Value.GetInt32() }).ToList();
                db.LastPushedStocks.AddRange(enviados);
                resumen["Último stock enviado"] = enviados.Count;
            }
        }

        resumen["Watermark de prendas"] = 0;
        resumen["Último stock enviado de prendas"] = 0;
        foreach (var (id, d) in lector.Leer("stock_buzos_pantalones_meta"))
        {
            if (id == "sync_watermark")
            {
                db.SyncWatermarks.Add(new SyncWatermark
                {
                    Clave = StockSyncStore.PrendasClave, LastOrderNumberSynced = d.Largo("last_order_number_synced")
                });
                resumen["Watermark de prendas"]++;
            }
            else if (id == "last_pushed")
            {
                foreach (var tipo in new[] { StockPrenda.Buzo, StockPrenda.Pantalon, StockPrenda.Conjunto })
                {
                    if (!d.Raiz.TryGetProperty(tipo.ToLowerInvariant() + "_values", out var valores))
                    {
                        continue;
                    }

                    var filas = valores.EnumerateObject().Select(p => new LastPushedStock
                    {
                        PoolKey = tipo.ToLowerInvariant() + ":" + p.Name,
                        Stock = p.Value.GetProperty("push_value").GetInt32()
                    }).ToList();
                    db.LastPushedStocks.AddRange(filas);
                    resumen["Último stock enviado de prendas"] += filas.Count;
                }
            }
        }

        resumen["Watermarks de pools manuales"] = 0;
        resumen["Último stock enviado de pools manuales"] = 0;
        foreach (var (id, d) in lector.Leer("stock_manual_pools_meta"))
        {
            var watermark = id.EndsWith("_watermark", StringComparison.Ordinal);
            var enviado = id.EndsWith("_last_pushed", StringComparison.Ordinal);
            if (!watermark && !enviado)
            {
                continue;
            }

            var poolId = id[..^(watermark ? "_watermark".Length : "_last_pushed".Length)];
            if (!pools.TryGetValue(poolId, out var pool))
            {
                throw new InvalidDataException($"stock_manual_pools_meta/{id} no corresponde a ningún pool manual.");
            }

            if (watermark)
            {
                db.StockManualPoolWatermarks.Add(new StockManualPoolWatermark
                {
                    StockManualPool = pool, LastOrderNumberSynced = d.Largo("last_order_number_synced")
                });
                resumen["Watermarks de pools manuales"]++;
            }
            else
            {
                db.LastPushedStocks.Add(new LastPushedStock
                {
                    PoolKey = PoolKeys.Manual(pool.Nombre), Stock = d.Entero("stock")
                });
                resumen["Último stock enviado de pools manuales"]++;
            }
        }

        var negro = 0;
        foreach (var (_, d) in lector.Leer("ventas_negro"))
        {
            var venta = new VentaNegro
            {
                Fecha = d.Fecha("date"), Nota = d.TextoOpcional("note"), TotalAmount = d.Decimal("total_amount"),
                Items = d.Lista("items").Select(i => new VentaNegroItem
                {
                    Tipo = i.TextoOpcional("tipo") ?? "remera", Color = i.Texto("color"), Corte = i.Texto("corte"),
                    Talle = i.Texto("talle"), Cantidad = i.Entero("cantidad")
                }).ToList()
            };
            Fechas(venta, d);
            db.VentasNegro.Add(venta);
            negro++;
        }
        resumen["Ventas en negro"] = negro;

        resumen["Pérdidas de mercadería"] = Agregar(db, lector.Leer("perdida_mercaderia"), d => new PerdidaMercaderia
        {
            Fecha = d.Fecha("date"), Cantidad = d.Entero("cantidad"), Color = d.Texto("color"), Corte = d.Texto("corte"),
            Talle = d.Texto("talle"), Motivo = d.Texto("motivo"), Nota = d.TextoOpcional("nota")
        });

        resumen["Movimientos con Cris"] = Agregar(db, lector.Leer("cris_ledger"), d => new CrisLedger
        {
            Fecha = d.Fecha("date"), Tipo = TipoCris(d.Texto("tipo")), Monto = d.Decimal("amount"),
            Nota = d.TextoOpcional("nota"), Color = d.TextoOpcional("color"), Corte = d.TextoOpcional("corte"),
            Talle = d.TextoOpcional("talle"), Cantidad = d.EnteroOpcional("cantidad")
        });

        resumen["Cambios de prendas"] = Agregar(db, lector.Leer("cambios_prendas"), d => new CambioPrenda
        {
            Fecha = d.Fecha("date"), Nota = d.TextoOpcional("nota"),
            ItemsSalida = d.Lista("items_salida").Select(i => new CambioItemSalida
            {
                Color = i.Texto("color"), Corte = i.Texto("corte"), Talle = i.Texto("talle"), Cantidad = i.Entero("cantidad")
            }).ToList(),
            ItemsRecibidos = d.Lista("items_recibidos").Select(i => new CambioItemRecibido
            {
                Color = i.Texto("color"), Corte = i.Texto("corte"), Talle = i.Texto("talle"), Cantidad = i.Entero("cantidad")
            }).ToList()
        });

        resumen["Stock de cambios"] = Agregar(db, lector.Leer("stock_cambios"), d => new StockCambio
        {
            Color = d.Texto("color"), Corte = d.Texto("corte"), Talle = d.Texto("talle"), Disponible = d.Entero("disponible")
        });

        resumen["Cargas al stock de cambios"] = Agregar(db, lector.Leer("cambios_stock_carga"), d => new CambioStockCarga
        {
            Fecha = d.Fecha("date"), Color = d.Texto("color"), Corte = d.Texto("corte"), Talle = d.Texto("talle"),
            Cantidad = d.Entero("cantidad"), Nota = d.TextoOpcional("nota")
        });

        resumen["Ventas de prendas de cambio"] = Agregar(db, lector.Leer("cambios_ventas"), d => new CambioVenta
        {
            Fecha = d.Fecha("date"), Color = d.Texto("color"), Corte = d.Texto("corte"), Talle = d.Texto("talle"),
            Cantidad = d.Entero("cantidad"), Monto = d.Decimal("monto"), Nota = d.TextoOpcional("nota")
        });

        resumen["Gastos manuales"] = Agregar(db, lector.Leer("gastos_manuales"), d => new GastoManual
        {
            Fecha = d.Fecha("date"), Categoria = d.Texto("category"), Descripcion = d.TextoOpcional("description") ?? "",
            Monto = d.Decimal("amount")
        });

        resumen["Pagos Nube en cuotas"] = Agregar(db, lector.Leer("pago_nube_cuotas"), d => new PagoNubeCuota
        {
            OrderNumber = d.Largo("order_number"), Total = d.Decimal("total"), Fecha = d.Fecha("date"),
            Status = Enum.Parse<EstadoPagoNube>(d.Texto("status"), ignoreCase: true),
            MarkedAt = d.FechaHoraOpcional("marked_at")
        });

        resumen["Historial mensual"] = Agregar(db, lector.Leer("monthly_history"), d => new MonthlyHistory
        {
            Mes = d.Texto("month"), PedidosCount = d.Entero("orders"), Facturado = d.Decimal("revenue"),
            MargenReal = d.Decimal("margin"), Comision = d.Decimal("fee"), Envio = d.Decimal("shipping"),
            CostoMercaderia = d.Decimal("cogs"), AdsStreet = d.Decimal("ads_street"), AdsKumo = d.Decimal("ads_kumo"),
            Closed = d.Raiz.TryGetProperty("closed", out var c) && c.GetBoolean(), Nota = d.TextoOpcional("note")
        });

        // SaveChanges ya es atómico; quien llama puede envolverlo en su transacción para probar sin guardar.
        await db.SaveChangesAsync(ct);
        if (tx is not null)
        {
            await tx.CommitAsync(ct);
        }

        return resumen;
    }

    private static async Task VerificarModoSombraAsync(MismadeDbContext db, CancellationToken ct)
    {
        if (!await db.JobRuns.AnyAsync(ct))
        {
            return;
        }

        // Ordenar en memoria permite también el proveedor SQLite (DateTimeOffset).
        var runs = await db.JobRuns.AsNoTracking()
            .Where(x => x.Status == EstadoJob.Succeeded && x.Detalle != null)
            .Select(x => new { x.StartedAt, x.Detalle }).ToListAsync(ct);
        var detalle = runs.OrderByDescending(x => x.StartedAt).FirstOrDefault()?.Detalle;
        if (detalle is not null)
        {
            try
            {
                using var json = JsonDocument.Parse(detalle);
                if (json.RootElement.ValueKind == JsonValueKind.Object
                    && json.RootElement.TryGetProperty("ModoSombra", out var modo)
                    && modo.ValueKind == JsonValueKind.True)
                {
                    return;
                }
            }
            catch (JsonException)
            {
                // Un detalle inválido tampoco acredita modo sombra.
            }
        }

        throw new InvalidOperationException("El panel no está en modo sombra; no importo.");
    }

    private static async Task BorrarAsync(MismadeDbContext db, CancellationToken ct)
    {
        await db.StockPrendaVariants.ExecuteDeleteAsync(ct);
        await db.StockVariantMaps.ExecuteDeleteAsync(ct);
        await db.StockManualPoolVariants.ExecuteDeleteAsync(ct);
        await db.StockManualPoolWatermarks.ExecuteDeleteAsync(ct);
        await db.VentaNegroItems.ExecuteDeleteAsync(ct);
        await db.CambioItemsSalida.ExecuteDeleteAsync(ct);
        await db.CambioItemsRecibidos.ExecuteDeleteAsync(ct);
        await db.StockDesacoples.ExecuteDeleteAsync(ct);
        await db.StockConjuntoVariants.ExecuteDeleteAsync(ct);
        await db.StockRemeras.ExecuteDeleteAsync(ct);
        await db.StockPrendas.ExecuteDeleteAsync(ct);
        await db.StockManualPools.ExecuteDeleteAsync(ct);
        await db.SyncWatermarks.ExecuteDeleteAsync(ct);
        await db.LastPushedStocks.ExecuteDeleteAsync(ct);
        await db.VentasNegro.ExecuteDeleteAsync(ct);
        await db.PerdidasMercaderia.ExecuteDeleteAsync(ct);
        await db.CrisLedger.ExecuteDeleteAsync(ct);
        await db.CambiosPrenda.ExecuteDeleteAsync(ct);
        await db.StockCambios.ExecuteDeleteAsync(ct);
        await db.CambioStockCargas.ExecuteDeleteAsync(ct);
        await db.CambioVentas.ExecuteDeleteAsync(ct);
        await db.GastosManuales.ExecuteDeleteAsync(ct);
        await db.PagoNubeCuotas.ExecuteDeleteAsync(ct);
        await db.MonthlyHistories.ExecuteDeleteAsync(ct);
        foreach (var entry in db.ChangeTracker.Entries<Entidad>().ToList())
        {
            if (entry.Entity is StockPrendaVariant or StockVariantMap or StockManualPoolVariant
                or StockManualPoolWatermark or VentaNegroItem or CambioItemSalida or CambioItemRecibido
                or StockDesacople or StockConjuntoVariant or StockRemera or StockPrenda or StockManualPool
                or SyncWatermark or LastPushedStock or VentaNegro or PerdidaMercaderia or CrisLedger
                or CambioPrenda or StockCambio or CambioStockCarga or CambioVenta or GastoManual
                or PagoNubeCuota or MonthlyHistory)
            {
                entry.State = EntityState.Detached;
            }
        }
    }

    private static async Task<List<string>> TablasConDatosAsync(MismadeDbContext db, CancellationToken ct)
    {
        var chequeos = new (string, IQueryable<Entidad>)[]
        {
            ("StockPrendaVariants", db.StockPrendaVariants), ("StockDesacoples", db.StockDesacoples),
            ("StockManualPoolVariants", db.StockManualPoolVariants), ("StockManualPoolWatermarks", db.StockManualPoolWatermarks),
            ("VentaNegroItems", db.VentaNegroItems), ("CambioItemsSalida", db.CambioItemsSalida),
            ("CambioItemsRecibidos", db.CambioItemsRecibidos),
            ("StockRemeras", db.StockRemeras), ("StockVariantMaps", db.StockVariantMaps), ("StockPrendas", db.StockPrendas),
            ("StockConjuntoVariants", db.StockConjuntoVariants), ("StockManualPools", db.StockManualPools),
            ("SyncWatermarks", db.SyncWatermarks), ("LastPushedStocks", db.LastPushedStocks),
            ("VentasNegro", db.VentasNegro), ("PerdidasMercaderia", db.PerdidasMercaderia), ("CrisLedger", db.CrisLedger),
            ("CambiosPrenda", db.CambiosPrenda), ("StockCambios", db.StockCambios),
            ("CambioStockCargas", db.CambioStockCargas), ("CambioVentas", db.CambioVentas),
            ("GastosManuales", db.GastosManuales), ("PagoNubeCuotas", db.PagoNubeCuotas),
            ("MonthlyHistories", db.MonthlyHistories)
        };
        var ocupadas = new List<string>();
        foreach (var (nombre, tabla) in chequeos)
        {
            if (await tabla.AnyAsync(ct))
            {
                ocupadas.Add(nombre);
            }
        }

        return ocupadas;
    }

    private static int Agregar<T>(MismadeDbContext db, IEnumerable<(string Id, Doc Doc)> docs, Func<Doc, T> crear)
        where T : Entidad
    {
        var filas = docs.Select(x =>
        {
            var fila = crear(x.Doc);
            Fechas(fila, x.Doc);
            return fila;
        }).ToList();
        db.Set<T>().AddRange(filas);
        return filas.Count;
    }

    private static void Fechas(Entidad fila, Doc d)
    {
        var creado = d.FechaHoraOpcional("created_at") ?? d.FechaHoraOpcional("updated_at");
        if (creado is not null)
        {
            fila.CreatedAt = creado.Value;
        }

        fila.UpdatedAt = d.FechaHoraOpcional("updated_at") ?? fila.CreatedAt;
    }

    private static string ClavePrenda(string tipo, string colorTalle) =>
        tipo + ":" + colorTalle.Trim().ToLowerInvariant().Replace(' ', '_');

    private static TipoMovimientoCris TipoCris(string tipo) => tipo switch
    {
        "pago" => TipoMovimientoCris.Pago,
        "devolucion" => TipoMovimientoCris.Devolucion,
        "compra" => TipoMovimientoCris.Compra,
        "saldo_inicial" => TipoMovimientoCris.SaldoInicial,
        _ => throw new InvalidDataException($"Tipo de movimiento con Cris desconocido: {tipo}")
    };

    private sealed class Lector(IReadOnlyList<string> carpetas)
    {
        public IEnumerable<(string Id, Doc Doc)> Leer(string coleccion)
        {
            var carpeta = carpetas.LastOrDefault(c => Directory.Exists(Path.Combine(c, coleccion)));
            if (carpeta is null)
            {
                yield break;
            }

            var dir = Path.Combine(carpeta, coleccion);
            var anidado = Path.Combine(dir, coleccion);
            if (Directory.Exists(anidado))
            {
                dir = anidado;
            }

            foreach (var archivo in Directory.EnumerateFiles(dir, "*.json").Order(StringComparer.Ordinal))
            {
                using var json = JsonDocument.Parse(File.ReadAllBytes(archivo));
                yield return (Path.GetFileNameWithoutExtension(archivo), new Doc(json.RootElement.Clone(), $"{coleccion}/{Path.GetFileName(archivo)}"));
            }
        }
    }

    private sealed record Doc(JsonElement Raiz, string Origen)
    {
        private JsonElement Campo(string nombre) => Raiz.TryGetProperty(nombre, out var v) && v.ValueKind != JsonValueKind.Null
            ? v
            : throw new InvalidDataException($"{Origen}: falta el campo '{nombre}'.");

        public string Texto(string nombre) => Campo(nombre).GetString()!.Trim();

        public string? TextoOpcional(string nombre) =>
            Raiz.TryGetProperty(nombre, out var v) && v.ValueKind == JsonValueKind.String && v.GetString()!.Trim().Length > 0
                ? v.GetString()!.Trim()
                : null;

        public int Entero(string nombre) => (int)Campo(nombre).GetDecimal();

        public int? EnteroOpcional(string nombre) =>
            Raiz.TryGetProperty(nombre, out var v) && v.ValueKind == JsonValueKind.Number ? (int)v.GetDecimal() : null;

        public long Largo(string nombre) => (long)Campo(nombre).GetDecimal();

        public decimal Decimal(string nombre) => Campo(nombre).GetDecimal();

        public DateOnly Fecha(string nombre) => DateOnly.ParseExact(Texto(nombre), "yyyy-MM-dd", CultureInfo.InvariantCulture);

        public DateTimeOffset? FechaHoraOpcional(string nombre) => TextoOpcional(nombre) is { } texto
            ? DateTimeOffset.Parse(texto, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal)
            : null;

        public IEnumerable<Doc> Lista(string nombre) =>
            Raiz.TryGetProperty(nombre, out var v) && v.ValueKind == JsonValueKind.Array
                ? v.EnumerateArray().Select((x, i) => new Doc(x, $"{Origen}#{nombre}[{i}]"))
                : [];

        public IEnumerable<(long Producto, long Variante)> Variantes() =>
            Lista("variants").Select(v => (v.Largo("product_id"), v.Largo("variant_id")));
    }
}
