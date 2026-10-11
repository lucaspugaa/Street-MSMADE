using Mismade.Domain;

namespace Mismade.Application;

/// <summary>Un grupo de pools con su propio watermark: "remeras" o cada pool manual.</summary>
public sealed record FamiliaStock(string Clave, EstadoSync Estado, bool TieneWatermark);

public interface IStockSyncStore
{
    Task<IReadOnlyList<FamiliaStock>> CargarAsync(CancellationToken ct);

    /// <summary>
    /// En una transacción: relee el estado de la familia, aplica <paramref name="planificar"/> y guarda
    /// stock y watermark. Si alguien modificó el stock en el medio, reintenta una vez con el estado nuevo.
    /// </summary>
    Task<PlanSync> AplicarAsync(string clave, Func<EstadoSync, PlanSync> planificar, CancellationToken ct);

    Task MarcarEnviadoAsync(string poolKey, int stock, CancellationToken ct);

    Task InicializarWatermarkAsync(string clave, long orderNumber, CancellationToken ct);
}

public interface IStockConfiguration
{
    /// <summary>
    /// false = modo sombra: el job calcula y guarda el stock y avanza el watermark, pero no escribe en Tiendanube.
    /// Sirve para correr en paralelo con otro sistema que todavía es el dueño del stock de la tienda.
    /// </summary>
    bool EnviarATiendanube { get; }
}

public sealed record AlertaDetalle(string Pool, string Tipo, int Faltante);

/// <summary>Lo que queda registrado de una corrida (JobRun.Detalle, en JSON).</summary>
public sealed class SyncDetalle
{
    public List<MetaSyncDetalle> Meta { get; init; } = [];
    public List<AlertaDetalle> Alertas { get; init; } = [];
    public int LineasSinPool { get; set; }
    public List<string> PoolsEnviados { get; init; } = [];
    public List<string> PoolsFallidos { get; init; } = [];
    /// <summary>Pools que se habrían enviado a Tiendanube si no estuviera el modo sombra.</summary>
    public List<string> PoolsSimulados { get; init; } = [];
    public bool ModoSombra { get; set; }
    public List<string> Notas { get; init; } = [];
    public int VentasNuevas { get; set; }
    public int VentasActualizadas { get; set; }
    public string? ErrorVentas { get; set; }
    public int PedidosProcesados { get; set; }
}

public interface IStockSyncStep
{
    /// <summary>Sincroniza stock. Devuelve el error del primer envío fallido, si hubo.</summary>
    Task<Exception?> RunAsync(SyncDetalle detalle, CancellationToken ct);
}

/// <summary>Pasos 1, 4 y 5 del job: pedidos desde el watermark y sync de remeras y pools manuales.</summary>
public sealed class StockSyncStep(
    IStockSyncStore store, ITiendanubeClient tiendanube, ITiendanubeCredenciales credenciales,
    IStockConfiguration configuracion) : IStockSyncStep
{
    public async Task<Exception?> RunAsync(SyncDetalle detalle, CancellationToken ct)
    {
        if (await credenciales.GetAsync(ct) is null)
        {
            detalle.Notas.Add("Tiendanube sin conectar: no se sincronizó stock.");
            return null;
        }

        var familias = await store.CargarAsync(ct);
        if (familias.Count == 0)
        {
            return null;
        }

        // Seguridad: sin watermark no se procesan pedidos viejos (descontaría ventas históricas).
        var sinWatermark = familias.Where(f => !f.TieneWatermark).ToList();
        if (sinWatermark.Count > 0)
        {
            var ultimo = await tiendanube.GetLatestOrderNumberAsync(ct);
            foreach (var familia in sinWatermark)
            {
                await store.InicializarWatermarkAsync(familia.Clave, ultimo, ct);
                detalle.Notas.Add($"Punto de partida de {PoolKeys.Legible(familia.Clave)} fijado en el pedido #{ultimo}.");
            }
        }

        var activas = familias.Where(f => f.TieneWatermark).ToList();
        if (activas.Count == 0)
        {
            return null;
        }

        var desde = activas.Min(f => f.Estado.Watermark);
        var pedidos = (await tiendanube.GetOrdersAsync(desde, ct))
            .Select(p => new PedidoPagado(p.Number,
                p.Productos.Select(l => new LineaVendida(l.ProductId, l.VariantId, l.Quantity)).ToList()))
            .ToList();
        detalle.PedidosProcesados = pedidos.Select(p => p.Number).Distinct().Count();

        detalle.ModoSombra = !configuracion.EnviarATiendanube;
        Exception? primerError = null;
        foreach (var familia in activas)
        {
            var plan = await store.AplicarAsync(familia.Clave, estado => StockSync.Planificar(estado, pedidos), ct);
            detalle.LineasSinPool += plan.LineasSinPool;
            detalle.Alertas.AddRange(plan.Alertas.Select(a => new AlertaDetalle(a.PoolKey, a.Tipo.ToString(), a.Faltante)));
            detalle.Notas.AddRange(plan.CambiosDesacople.Select(c => c.Tipo == TipoCambioDesacople.Desacoplado
                ? $"{PoolKeys.Legible(c.PoolKey)}: desacoplado con {c.StockReal} unidad(es) reales; en Tiendanube queda en 0."
                : $"{PoolKeys.Legible(c.PoolKey)}: reactivado por carga de mercadería, se publica {c.StockReal}."));

            foreach (var pool in plan.PoolsAEnviar)
            {
                if (detalle.ModoSombra)
                {
                    // Sin MarcarEnviado: al activar el envío, la diferencia contra lo último enviado se manda sola.
                    detalle.PoolsSimulados.Add(pool);
                    continue;
                }

                var envios = plan.Envios.Where(e => e.PoolKey == pool)
                    .Select(e => new VarianteTiendanube(e.ProductId, e.VariantId, e.Stock))
                    .ToList();
                try
                {
                    await tiendanube.UpdateStockAsync(envios, ct);
                    await store.MarcarEnviadoAsync(pool, plan.Publicado[pool], ct);
                    detalle.PoolsEnviados.Add(pool);
                }
                catch (Exception error) when (error is not OperationCanceledException)
                {
                    // No se marca como enviado: la próxima corrida lo reenvía por diferencia.
                    detalle.PoolsFallidos.Add(pool);
                    primerError ??= error;
                }
            }
        }

        if (detalle.ModoSombra)
        {
            detalle.Notas.Add(detalle.PoolsSimulados.Count == 0
                ? "Modo sombra: el stock se calculó pero no se envía a Tiendanube."
                : $"Modo sombra: {detalle.PoolsSimulados.Count} combinación(es) cambiaron y no se enviaron a Tiendanube.");
        }

        // Kumo y otros productos fuera de los pools también vienen en los pedidos: no es error.
        // Lo mismo para variantes excluidas a propósito.
        return primerError;
    }
}
