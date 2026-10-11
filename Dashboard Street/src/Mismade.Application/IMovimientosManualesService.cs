using Mismade.Domain;

namespace Mismade.Application;

public sealed record ResultadoMovimiento(Guid Id, IReadOnlyList<string> Avisos);

public interface IMovimientosManualesService
{
    Task<ResultadoMovimiento> RegistrarVentaNegroAsync(VentaNegro movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> RegistrarPerdidaAsync(PerdidaMercaderia movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> RegistrarCrisAsync(CrisLedger movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> RegistrarCambioAsync(CambioPrenda movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> RegistrarCargaAsync(CambioStockCarga movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> RegistrarVentaCambioAsync(CambioVenta movimiento, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarVentaNegroAsync(Guid id, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarPerdidaAsync(Guid id, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarCrisAsync(Guid id, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarCambioAsync(Guid id, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarCargaAsync(Guid id, CancellationToken ct = default);
    Task<ResultadoMovimiento> BorrarVentaCambioAsync(Guid id, CancellationToken ct = default);
}
