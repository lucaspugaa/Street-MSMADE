namespace Mismade.Domain;

public sealed class TiendanubeConexion
{
    public int Id { get; set; } = 1;
    public long StoreId { get; set; }
    public string AccessTokenProtegido { get; set; } = "";
    public string Scope { get; set; } = "";
    public DateTimeOffset ConnectedAt { get; set; }
    public string ConnectedBy { get; set; } = "";
}
