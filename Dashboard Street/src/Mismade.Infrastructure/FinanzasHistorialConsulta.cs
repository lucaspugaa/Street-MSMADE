using Microsoft.EntityFrameworkCore;
using Mismade.Application;

namespace Mismade.Infrastructure;

public sealed class FinanzasHistorialConsulta(IDbContextFactory<MismadeDbContext> factory)
    : IFinanzasHistorialConsulta
{
    public async Task<HistorialFinanzas> ConsultarAsync(
        int anio, PeriodoFinanzas parcial, CancellationToken ct = default)
    {
        await using var db = await factory.CreateDbContextAsync(ct);
        var meses = await db.MonthlyHistories.AsNoTracking().OrderBy(m => m.Mes).ToListAsync(ct);
        var cerrados = meses.Where(m => m.Closed && m.Mes.StartsWith($"{anio:D4}-", StringComparison.Ordinal)).ToList();
        var incluyeParcial = parcial.Desde.Year == anio;
        var margen = parcial.Margen;
        var gastosKumo = incluyeParcial
            ? await db.MetaInsights.AsNoTracking().Where(m => m.Cuenta == "Kumo"
                && m.Fecha >= parcial.Desde && m.Fecha < parcial.Hasta)
                .Select(m => m.Gasto).ToListAsync(ct)
            : [];

        var anual = new TotalesAnuales(
            cerrados.Sum(m => m.PedidosCount) + (incluyeParcial ? margen.Pedidos : 0),
            cerrados.Sum(m => m.Facturado) + (incluyeParcial ? margen.Ingresos : 0),
            cerrados.Sum(m => m.Comision) + (incluyeParcial ? margen.Comision : 0),
            cerrados.Sum(m => m.Envio) + (incluyeParcial ? margen.Envio : 0),
            cerrados.Sum(m => m.CostoMercaderia) + (incluyeParcial ? margen.Costo : 0),
            cerrados.Sum(m => m.AdsStreet) + (incluyeParcial ? margen.AdsStreet : 0),
            cerrados.Sum(m => m.AdsKumo) + gastosKumo.Sum(),
            cerrados.Sum(m => m.MargenReal) + (incluyeParcial ? margen.Margen : 0));
        return new HistorialFinanzas(meses, parcial, anual);
    }
}
