using Mismade.Domain;

namespace Mismade.Application;

public enum PeriodoClientes { EsteMes, Ultimos90Dias, EsteAnio, Todo }

public sealed record ClienteRanking(string? Nombre, string? Email, int Pedidos,
    decimal Total, decimal TicketPromedio, DateOnly UltimaCompra);

public interface IClientesConsulta
{
    Task<IReadOnlyList<ClienteRanking>> ConsultarAsync(PeriodoClientes periodo, CancellationToken ct = default);
}

public sealed record TotalesAnuales(int Pedidos, decimal Facturado, decimal Comision,
    decimal Envio, decimal Costo, decimal AdsStreet, decimal AdsKumo, decimal Margen);

public sealed record HistorialFinanzas(IReadOnlyList<MonthlyHistory> Meses,
    PeriodoFinanzas Parcial, TotalesAnuales Anual);

public interface IFinanzasHistorialConsulta
{
    Task<HistorialFinanzas> ConsultarAsync(int anio, PeriodoFinanzas parcial, CancellationToken ct = default);
}
