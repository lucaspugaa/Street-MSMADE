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
    long Watermark,
    /// <summary>Pools desacoplados y su stock_at_decouple. Null = la familia no usa desacople (solo remeras lo usan).</summary>
    IReadOnlyDictionary<string, int>? Desacoples = null);

public sealed record EnvioStock(string PoolKey, long ProductId, long VariantId, int Stock);

public enum TipoAlertaStock { SinStock, Sobreventa }

public sealed record AlertaStock(string PoolKey, TipoAlertaStock Tipo, int Faltante = 0);

public enum TipoCambioDesacople { Desacoplado, Reactivado }

/// <summary>Desacople creado (con StockReal como stock_at_decouple) o borrado por carga de mercadería.</summary>
public sealed record CambioDesacople(string PoolKey, TipoCambioDesacople Tipo, int StockReal);

public sealed record PlanSync(
    IReadOnlyDictionary<string, int> StockNuevo,
    long WatermarkNuevo,
    int PedidosProcesados,
    /// <summary>Pools cuyo valor difiere del último enviado a Tiendanube.</summary>
    IReadOnlyList<string> PoolsAEnviar,
    /// <summary>Todas las variantes de esos pools, ya sin las excluidas.</summary>
    IReadOnlyList<EnvioStock> Envios,
    IReadOnlyList<AlertaStock> Alertas,
    int LineasSinPool,
    /// <summary>Valor que corresponde mostrar en Tiendanube por pool: el real, o 0 si está desacoplado.</summary>
    IReadOnlyDictionary<string, int> Publicado,
    IReadOnlyList<CambioDesacople> CambiosDesacople);

/// <summary>
/// Algoritmo de sincronización de stock (sección 3.5 del plan), sin IO.
/// Para cada pedido pago posterior al watermark descuenta lo vendido del pool de su variante
/// y arma el envío a Tiendanube solo de los pools que cambiaron respecto del último envío.
/// Los movimientos manuales (ventas en negro, cargas) NO pasan por acá: impactan el stock al cargarse.
/// </summary>
public static class StockSync
{
    /// <summary>Remeras con 1 a 3 unidades reales se bajan de la tienda (sección 3.7 de reglas-artifact.md).</summary>
    public const int UmbralDesacople = 3;

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

        var (publicado, cambios) = Desacoplar(stock, estado.Desacoples);

        // Diff contra el último envío: también reenvía pools que cambiaron por carga manual
        // o cuyo envío anterior falló (el último enviado quedó viejo). Un pool desacoplado publica 0,
        // así que no se envía mientras Tiendanube ya tenga 0.
        var aEnviar = publicado
            .Where(kv => !estado.UltimoEnviado.TryGetValue(kv.Key, out var previo) || previo != kv.Value)
            .Select(kv => kv.Key)
            .Where(pool => poolPorVariante.ContainsValue(pool))
            .OrderBy(pool => pool, StringComparer.Ordinal)
            .ToList();

        var envios = estado.Variantes
            .Where(v => !estado.VariantesExcluidas.Contains(v.VariantId) && aEnviar.Contains(v.PoolKey))
            .DistinctBy(v => v.VariantId)
            .Select(v => new EnvioStock(v.PoolKey, v.ProductId, v.VariantId, publicado[v.PoolKey]))
            .ToList();

        var watermark = nuevos.Count == 0 ? estado.Watermark : Math.Max(estado.Watermark, nuevos[^1].Number);

        return new PlanSync(stock, watermark, nuevos.Count, aEnviar, envios,
            alertas.OrderBy(a => a.PoolKey, StringComparer.Ordinal).ToList(), lineasSinPool, publicado, cambios);
    }

    /// <summary>
    /// Desacople de remeras sobre el stock ya descontado, para todos los pools (también los que cambiaron
    /// por movimientos manuales): un pool acoplado con 1 a 3 unidades se desacopla y publica 0; uno
    /// desacoplado publica 0 hasta que su stock real supere estrictamente el stock_at_decouple.
    /// </summary>
    private static (Dictionary<string, int> Publicado, List<CambioDesacople> Cambios) Desacoplar(
        Dictionary<string, int> stock, IReadOnlyDictionary<string, int>? desacoples)
    {
        var publicado = new Dictionary<string, int>(stock);
        var cambios = new List<CambioDesacople>();
        if (desacoples is null)
        {
            return (publicado, cambios);
        }

        foreach (var (pool, real) in stock.OrderBy(kv => kv.Key, StringComparer.Ordinal))
        {
            var desacoplado = desacoples.TryGetValue(pool, out var stockAlDesacoplar);
            if (desacoplado && real <= stockAlDesacoplar)
            {
                publicado[pool] = 0;
            }
            else if (real is > 0 and <= UmbralDesacople)
            {
                // Nuevo, o reactivado por una carga que lo deja todavía en 1 a 3: queda (o sigue)
                // desacoplado con el stock de ahora como nuevo stock_at_decouple, igual que el artifact.
                cambios.Add(new CambioDesacople(pool, TipoCambioDesacople.Desacoplado, real));
                publicado[pool] = 0;
            }
            else if (desacoplado)
            {
                cambios.Add(new CambioDesacople(pool, TipoCambioDesacople.Reactivado, real));
            }
        }

        return (publicado, cambios);
    }
}
