using Microsoft.EntityFrameworkCore;
using Mismade.Application;
using Mismade.Domain;

namespace Mismade.Infrastructure;

public sealed class VentasStore(IDbContextFactory<MismadeDbContext> factory) : IVentasStore
{
    public async Task<VentasUpsertResultado> UpsertAsync(IReadOnlyList<VentaTiendanube> ventas, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        // Una misma orden puede aparecer más de una vez: conservar su versión más reciente.
        var unicas = ventas.GroupBy(x => x.TiendanubeOrderId)
            .Select(g => g.OrderByDescending(x => x.UpdatedAtTiendanube).First()).ToList();
        var ids = unicas.Select(x => x.TiendanubeOrderId).ToArray();
        var existentes = await db.Ventas.Include(x => x.Items)
            .Where(x => ids.Contains(x.TiendanubeOrderId)).ToDictionaryAsync(x => x.TiendanubeOrderId, ct);
        var nuevas = 0;
        var actualizadas = 0;
        foreach (var orden in unicas)
        {
            if (!existentes.TryGetValue(orden.TiendanubeOrderId, out var venta))
            {
                venta = new Venta { TiendanubeOrderId = orden.TiendanubeOrderId };
                db.Ventas.Add(venta);
                nuevas++;
            }
            else
            {
                // El solapamiento no debe sobrescribir una versión más reciente con una vieja.
                if (orden.UpdatedAtTiendanube < venta.UpdatedAtTiendanube)
                {
                    continue;
                }

                actualizadas++;
                db.VentaItems.RemoveRange(venta.Items);
                venta.Items.Clear();
            }

            venta.Number = orden.Number;
            venta.CreatedAt = orden.CreatedAt.ToUniversalTime();
            venta.UpdatedAtTiendanube = orden.UpdatedAtTiendanube.ToUniversalTime();
            venta.CompletedAt = orden.CompletedAt?.ToUniversalTime();
            venta.PaidAt = orden.PaidAt?.ToUniversalTime();
            venta.CancelledAt = orden.CancelledAt?.ToUniversalTime();
            venta.Status = orden.Status;
            venta.PaymentStatus = orden.PaymentStatus;
            venta.Total = orden.Total;
            venta.Subtotal = orden.Subtotal;
            venta.Discount = orden.Discount;
            venta.ShippingCostCustomer = orden.ShippingCostCustomer;
            venta.ShippingCostOwner = orden.ShippingCostOwner;
            venta.Gateway = orden.Gateway;
            venta.ShippingOption = orden.ShippingOption;
            venta.Currency = orden.Currency;
            venta.CustomerId = orden.CustomerId;
            venta.CustomerName = orden.CustomerName;
            venta.CustomerEmail = orden.CustomerEmail;
            venta.Items = orden.Items.Select(x => new VentaItem
            {
                ProductId = x.ProductId, VariantId = x.VariantId, Quantity = x.Quantity,
                Price = x.Price, Name = x.Name, Sku = x.Sku
            }).ToList();
            db.VentaItems.AddRange(venta.Items);
        }

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);
        return new VentasUpsertResultado(nuevas, actualizadas);
    }

    public async Task<VentasSyncEstado?> GetEstadoAsync(CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        return await db.VentasSyncEstados.AsNoTracking().SingleOrDefaultAsync(x => x.Clave == "ventas", ct);
    }

    public async Task SetEstadoAsync(VentasSyncEstado estado, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var actual = await db.VentasSyncEstados.SingleOrDefaultAsync(x => x.Clave == "ventas", ct);
        if (actual is null)
        {
            actual = new VentasSyncEstado();
            db.VentasSyncEstados.Add(actual);
        }

        if (estado.UltimoUpdatedAt > actual.UltimoUpdatedAt)
        {
            actual.UltimoUpdatedAt = estado.UltimoUpdatedAt.ToUniversalTime();
        }

        actual.HistorialDesde ??= estado.HistorialDesde?.ToUniversalTime();
        actual.CompletedAtBackfillDone |= estado.CompletedAtBackfillDone;
        await db.SaveChangesAsync(ct);
    }

    public async Task<bool> TieneVentasAsync(CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        return await db.Ventas.AnyAsync(ct);
    }

    public async Task<FacturacionPeriodo> FacturacionAsync(
        DateTimeOffset desde, DateTimeOffset hasta, CancellationToken ct)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        return await db.Ventas.AsNoTracking()
            .Where(x => x.PaymentStatus == "paid" && x.CancelledAt == null && x.Status != "cancelled")
            .Where(FinanzasConsulta.EnPeriodo(desde, hasta))
            .GroupBy(x => 1)
            .Select(g => new FacturacionPeriodo(g.Sum(x => x.Total), g.Count()))
            .SingleOrDefaultAsync(ct) ?? new FacturacionPeriodo(0, 0);
    }
}
