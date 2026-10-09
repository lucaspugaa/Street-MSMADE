namespace Mismade.Domain;

public sealed class MetaInsightEntity
{
    public string Cuenta { get; set; } = "";
    public DateOnly Fecha { get; set; }
    public string CampaignId { get; set; } = "";
    public string CampaignName { get; set; } = "";
    public decimal Gasto { get; set; }
    public long Impresiones { get; set; }
    public long Clicks { get; set; }
    public decimal Compras { get; set; }
    public decimal ValorCompras { get; set; }
    public DateTimeOffset ActualizadoEn { get; set; }
}
