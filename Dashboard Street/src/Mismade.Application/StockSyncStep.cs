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

public sealed record AlertaDetalle(string Pool, string Tipo, int Faltante);

/// <summary>Lo que queda registrado de una corrida (JobRun.Detalle, en JSON).</summary>
public sealed class SyncDetalle
{
    public List<MetaSyncDetalle> Meta { get; init; } = [];
    public List<AlertaDetalle> Alertas { get; init; } = [];
    public int LineasSinPool { get; set; }
    public List<string> PoolsEnviados { get; init; } = [];
    public List<string> PoolsFallidos { get; init; } = [];
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
    IStockSyncStore store, ITiendanubeClient tiendanube, ITiendanubeCredenciales credenciales) : IStockSyncStep
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

        Exception? primerError = null;
        foreach (var familia in activas)
        {
            var plan = await store.AplicarAsync(familia.Clave, estado => StockSync.Planificar(estado, pedidos), ct);
            detalle.LineasSinPool += plan.LineasSinPool;
            detalle.Alertas.AddRange(plan.Alertas.Select(a => new AlertaDetalle(a.PoolKey, a.Tipo.ToString(), a.Faltante)));

            foreach (var pool in plan.PoolsAEnviar)
            {
                var envios = plan.Envios.Where(e => e.PoolKey == pool)
                    .Select(e => new VarianteTiendanube(e.ProductId, e.VariantId, e.Stock))
                    .ToList();
                try
                {
                    await tiendanube.UpdateStockAsync(envios, ct);
                    await store.MarcarEnviadoAsync(pool, plan.StockNuevo[pool], ct);
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

        // Kumo y otros productos fuera de los pools también vienen en los pedidos: no es error.
        // Lo mismo para variantes excluidas a propósito.
        return primerError;
    }
}
