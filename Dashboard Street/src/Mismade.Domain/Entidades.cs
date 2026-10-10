namespace Mismade.Domain;

public abstract class Entidad
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
}

public class StockRemera : Entidad
{
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Stock { get; set; }
}

public class StockVariantMap : Entidad
{
    public Guid StockRemeraId { get; set; }
    public StockRemera StockRemera { get; set; } = null!;
    public long TiendanubeProductId { get; set; }
    public long TiendanubeVariantId { get; set; }
}

public class StockVariantMapExclusion : Entidad
{
    public long ProductId { get; set; }
    public long VariantId { get; set; }
    public string PoolKey { get; set; } = "";
    public string Reason { get; set; } = "";
    public bool Active { get; set; } = true;
}

public class StockManualPool : Entidad
{
    public string Nombre { get; set; } = "";
    public int Stock { get; set; }
    public string TipoPrenda { get; set; } = "";
}

public class StockManualPoolVariant : Entidad
{
    public Guid StockManualPoolId { get; set; }
    public StockManualPool StockManualPool { get; set; } = null!;
    public long TiendanubeProductId { get; set; }
    public long TiendanubeVariantId { get; set; }
}

public class StockManualPoolWatermark : Entidad
{
    public Guid StockManualPoolId { get; set; }
    public StockManualPool StockManualPool { get; set; } = null!;
    public long LastOrderNumberSynced { get; set; }
}

public class VentaNegro : Entidad
{
    public DateOnly Fecha { get; set; }
    public string? Nota { get; set; }
    public decimal TotalAmount { get; set; }
    public ICollection<VentaNegroItem> Items { get; set; } = [];
}

public class VentaNegroItem : Entidad
{
    public Guid VentaNegroId { get; set; }
    public VentaNegro VentaNegro { get; set; } = null!;
    public string Tipo { get; set; } = "";
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Cantidad { get; set; }
}

public class PerdidaMercaderia : Entidad
{
    public DateOnly Fecha { get; set; }
    public int Cantidad { get; set; }
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public string Motivo { get; set; } = "";
    public string? Nota { get; set; }
}

public enum TipoMovimientoCris { Pago, Devolucion, Compra, SaldoInicial }

public class CrisLedger : Entidad
{
    public DateOnly Fecha { get; set; }
    public TipoMovimientoCris Tipo { get; set; }
    public decimal Monto { get; set; }
    public string? Nota { get; set; }
}

public class CambioPrenda : Entidad
{
    public DateOnly Fecha { get; set; }
    public string? Nota { get; set; }
    public ICollection<CambioItemSalida> ItemsSalida { get; set; } = [];
    public ICollection<CambioItemRecibido> ItemsRecibidos { get; set; } = [];
}

public class CambioItemSalida : Entidad
{
    public Guid CambioPrendaId { get; set; }
    public CambioPrenda CambioPrenda { get; set; } = null!;
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Cantidad { get; set; }
}

public class CambioItemRecibido : Entidad
{
    public Guid CambioPrendaId { get; set; }
    public CambioPrenda CambioPrenda { get; set; } = null!;
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Cantidad { get; set; }
}

public class StockCambio : Entidad
{
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Disponible { get; set; }
}

public class CambioStockCarga : Entidad
{
    public DateOnly Fecha { get; set; }
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Cantidad { get; set; }
    public string? Nota { get; set; }
}

public class CambioVenta : Entidad
{
    public DateOnly Fecha { get; set; }
    public string Color { get; set; } = "";
    public string Corte { get; set; } = "";
    public string Talle { get; set; } = "";
    public int Cantidad { get; set; }
    public decimal Monto { get; set; }
    public string? Nota { get; set; }
}

public class GastoManual : Entidad
{
    public DateOnly Fecha { get; set; }
    public string Categoria { get; set; } = "";
    public string Descripcion { get; set; } = "";
    public decimal Monto { get; set; }
}

public enum EstadoPagoNube { Pending, Cuotas, Simple }

public class PagoNubeCuota : Entidad
{
    public long OrderNumber { get; set; }
    public decimal Total { get; set; }
    public DateOnly Fecha { get; set; }
    public EstadoPagoNube Status { get; set; }
    public DateTimeOffset? MarkedAt { get; set; }
}

public class MonthlyHistory : Entidad
{
    public string Mes { get; set; } = ""; // yyyy-MM
    public int PedidosCount { get; set; }
    public decimal Facturado { get; set; }
    public decimal MargenReal { get; set; }
    public bool Closed { get; set; }
}

public class SyncWatermark : Entidad
{
    public string Clave { get; set; } = "";
    public long LastOrderNumberSynced { get; set; }
}

public class LastPushedStock : Entidad
{
    public string PoolKey { get; set; } = "";
    public int Stock { get; set; }
}

public class ConfigHistorica : Entidad
{
    public string Clave { get; set; } = "";
    public string Valor { get; set; } = "";
    public DateOnly VigenteDesde { get; set; }
}

public enum EstadoJob { Running, Skipped, Succeeded, Failed }

public class JobRun : Entidad
{
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? FinishedAt { get; set; }
    public EstadoJob Status { get; set; }
    public string Trigger { get; set; } = "";
    public int OrdersProcessed { get; set; }
    public int CombinationsPushed { get; set; }
    public string? Error { get; set; }
    /// <summary>SyncDetalle serializado en JSON.</summary>
    public string? Detalle { get; set; }
}

public class Venta : Entidad
{
    public long TiendanubeOrderId { get; set; }
    public long Number { get; set; }
    public DateTimeOffset UpdatedAtTiendanube { get; set; }
    public DateTimeOffset? PaidAt { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public string Status { get; set; } = "";
    public string PaymentStatus { get; set; } = "";
    public decimal Total { get; set; }
    public decimal Subtotal { get; set; }
    public decimal Discount { get; set; }
    public decimal ShippingCostCustomer { get; set; }
    public decimal ShippingCostOwner { get; set; }
    public string? Gateway { get; set; }
    public string? ShippingOption { get; set; }
    public string? Currency { get; set; }
    public long? CustomerId { get; set; }
    public string? CustomerName { get; set; }
    public string? CustomerEmail { get; set; }
    public ICollection<VentaItem> Items { get; set; } = [];
}

public class VentaItem : Entidad
{
    public Guid VentaId { get; set; }
    public Venta Venta { get; set; } = null!;
    public long ProductId { get; set; }
    public long VariantId { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public string Name { get; set; } = "";
    public string? Sku { get; set; }
}

public class VentasSyncEstado : Entidad
{
    public string Clave { get; set; } = "ventas";
    public DateTimeOffset UltimoUpdatedAt { get; set; }
    public DateTimeOffset? HistorialDesde { get; set; }
}
