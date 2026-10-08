namespace Mismade.Domain;

/// <summary>Una variante de Tiendanube que comparte el stock de un pool (ej. "crema_oversize_s").</summary>
public sealed record VariantePool(string PoolKey, long ProductId, long VariantId);

public sealed record LineaVendida(long ProductId, long VariantId, int Cantidad);

public sealed record PedidoPagado(long Number, IReadOnlyList<LineaVendida> Lineas);

public sealed record EstadoSync(
    IReadOnlyDictionary<string, int> Stock,
    IReadOnlyList<VariantePool> Variantes,
    IReadOnlySet<long> VariantesExcluidas,
    IReadOnlyDictionary<string, int> UltimoEnviado,
    long Watermark);

public sealed record EnvioStock(string PoolKey, long ProductId, long VariantId, int Stock);

public enum TipoAlertaStock { SinStock, Sobreventa }

public sealed record AlertaStock(string PoolKey, TipoAlertaStock Tipo, int Faltante = 0);

public sealed record PlanSync(
    IReadOnlyDictionary<string, int> StockNuevo,
    long WatermarkNuevo,
    int PedidosProcesados,
    /// <summary>Pools cuyo valor difiere del último enviado a Tiendanube.</summary>
    IReadOnlyList<string> PoolsAEnviar,
    /// <summary>Todas las variantes de esos pools, ya sin las excluidas.</summary>
    IReadOnlyList<EnvioStock> Envios,
    IReadOnlyList<AlertaStock> Alertas,
    int LineasSinPool);

/// <summary>
/// Algoritmo de sincronización de stock (sección 3.5 del plan), sin IO.
/// Para cada pedido pago posterior al watermark descuenta lo vendido del pool de su variante
/// y arma el envío a Tiendanube solo de los pools que cambiaron respecto del último envío.
/// Los movimientos manuales (ventas en negro, cargas) NO pasan por acá: impactan el stock al cargarse.
/// </summary>
public static class StockSync
{
    public static PlanSync Planificar(EstadoSync estado, IEnumerable<PedidoPagado> pedidos)
    {
        var stock = new Dictionary<string, int>(estado.Stock);
        var poolPorVariante = new Dictionary<long, string>();
        foreach (var v in estado.Variantes)
        {
            if (!estado.VariantesExcluidas.Contains(v.VariantId))
            {
                poolPorVariante[v.VariantId] = v.PoolKey;
            }
        }

        var nuevos = pedidos
            .Where(p => p.Number > estado.Watermark)
            .GroupBy(p => p.Number).Select(g => g.First()) // un pedido repetido en la paginación cuenta una vez
            .OrderBy(p => p.Number)
            .ToList();

        var vendido = new Dictionary<string, int>();
        var lineasSinPool = 0;
        foreach (var linea in nuevos.SelectMany(p => p.Lineas))
        {
            if (linea.Cantidad <= 0)
            {
                continue;
            }

            // Una variante excluida (stock concentrado a mano) no descuenta del pool.
            if (!poolPorVariante.TryGetValue(linea.VariantId, out var pool) || !stock.ContainsKey(pool))
            {
                lineasSinPool++;
                continue;
            }

            vendido[pool] = vendido.GetValueOrDefault(pool) + linea.Cantidad;
        }

        var alertas = new List<AlertaStock>();
        foreach (var (pool, cantidad) in vendido)
        {
            var antes = stock[pool];
            var despues = antes - cantidad;
            if (despues < 0)
            {
                alertas.Add(new AlertaStock(pool, TipoAlertaStock.Sobreventa, -despues));
                despues = 0;
            }
            else if (despues == 0 && antes > 0)
            {
                alertas.Add(new AlertaStock(pool, TipoAlertaStock.SinStock));
            }

            stock[pool] = despues;
        }

        // Diff contra el último envío: también reenvía pools que cambiaron por carga manual
        // o cuyo envío anterior falló (el último enviado quedó viejo).
        var aEnviar = stock
            .Where(kv => !estado.UltimoEnviado.TryGetValue(kv.Key, out var previo) || previo != kv.Value)
            .Select(kv => kv.Key)
            .Where(pool => poolPorVariante.ContainsValue(pool))
            .OrderBy(pool => pool, StringComparer.Ordinal)
            .ToList();

        var envios = estado.Variantes
            .Where(v => !estado.VariantesExcluidas.Contains(v.VariantId) && aEnviar.Contains(v.PoolKey))
            .DistinctBy(v => v.VariantId)
            .Select(v => new EnvioStock(v.PoolKey, v.ProductId, v.VariantId, stock[v.PoolKey]))
            .ToList();

        var watermark = nuevos.Count == 0 ? estado.Watermark : Math.Max(estado.Watermark, nuevos[^1].Number);

        return new PlanSync(stock, watermark, nuevos.Count, aEnviar, envios,
            alertas.OrderBy(a => a.PoolKey, StringComparer.Ordinal).ToList(), lineasSinPool);
    }
}
