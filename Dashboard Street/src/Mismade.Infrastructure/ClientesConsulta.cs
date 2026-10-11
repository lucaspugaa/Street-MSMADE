using Microsoft.EntityFrameworkCore;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class ClientesConsulta(IDbContextFactory<MismadeDbContext> factory, TimeProvider clock)
    : IClientesConsulta
{
    public async Task<IReadOnlyList<ClienteRanking>> ConsultarAsync(
        PeriodoClientes periodo, CancellationToken ct = default)
    {
        var hoy = FechaArgentina.Dia(clock.GetUtcNow());
        DateOnly? desde = periodo switch
        {
            PeriodoClientes.EsteMes => new(hoy.Year, hoy.Month, 1),
            PeriodoClientes.Ultimos90Dias => hoy.AddDays(-89),
            PeriodoClientes.EsteAnio => new(hoy.Year, 1, 1),
            PeriodoClientes.Todo => null,
            _ => throw new ArgumentOutOfRangeException(nameof(periodo))
        };

        await using var db = await factory.CreateDbContextAsync(ct);
        var query = db.Ventas.AsNoTracking().Where(v => v.PaymentStatus == "paid"
            && v.CancelledAt == null && v.Status != "cancelled" && v.Status != "refunded");
        if (desde is { } inicio)
        {
            var inicioUtc = FechaArgentina.InicioUtc(inicio);
            var hastaUtc = FechaArgentina.InicioUtc(hoy.AddDays(1));
            query = query.Where(v => (v.CompletedAt ?? v.PaidAt ?? v.CreatedAt) >= inicioUtc
                && (v.CompletedAt ?? v.PaidAt ?? v.CreatedAt) < hastaUtc);
        }

        var ventas = await query.Select(v => new
        {
            v.CustomerId, v.CustomerEmail, v.CustomerName, v.Total, v.TiendanubeOrderId,
            Fecha = v.CompletedAt ?? v.PaidAt ?? v.CreatedAt
        }).ToListAsync(ct);

        return ventas.Where(v => v.CustomerId != null || !string.IsNullOrWhiteSpace(v.CustomerEmail))
            .GroupBy(v => v.CustomerId is { } id ? $"id:{id}"
                : $"email:{v.CustomerEmail!.Trim().ToUpperInvariant()}")
            .Select(grupo =>
            {
                var ultima = grupo.OrderByDescending(v => v.Fecha)
                    .ThenByDescending(v => v.TiendanubeOrderId).First();
                var total = grupo.Sum(v => v.Total);
                return new ClienteRanking(ultima.CustomerName, ultima.CustomerEmail,
                    grupo.Count(), total, total / grupo.Count(), FechaArgentina.Dia(ultima.Fecha));
            })
            .OrderByDescending(c => c.Total).ThenByDescending(c => c.Pedidos)
            .ThenBy(c => c.Email, StringComparer.Ordinal).ThenBy(c => c.Nombre, StringComparer.Ordinal)
            .Take(50).ToList();
    }
}
