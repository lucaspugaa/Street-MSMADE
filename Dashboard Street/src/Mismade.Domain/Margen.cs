namespace Mismade.Domain;

public sealed record ItemPedido(string Nombre, int Cantidad);

/// <summary>Pedido pago de Tiendanube, con la fecha de pago en hora argentina.</summary>
public sealed record PedidoMargen(
    long Number, DateOnly Fecha, decimal Total, string? Gateway, string? ShippingOption, IReadOnlyList<ItemPedido> Items);

public sealed record MargenPedido(
    long Number, decimal Ingreso, decimal Comision, decimal Envio, decimal Costo,
    bool MedioDesconocido, IReadOnlyList<string> ItemsSinCosto, bool PagoNubeSinConfirmar)
{
    public decimal Margen => Ingreso - Comision - Envio - Costo;
}

public sealed record MargenPeriodo(
    int Pedidos,
    decimal IngresosTiendanube,
    decimal Comision,
    decimal Envio,
    decimal Costo,
    decimal AdsStreet,
    /// <summary>Aporte neto de ventas en negro: total cobrado − costo de prenda (paso 3.9.a).</summary>
    decimal VentasNegroNeto,
    /// <summary>Costo de prenda perdido (paso 3.9.b), en positivo.</summary>
    decimal Perdidas,
    /// <summary>Ventas de prendas de cambio, monto completo sin costo (paso 3.10.b).</summary>
    decimal VentasCambio,
    IReadOnlyList<string> Avisos)
{
    /// <summary>Ingresos como los muestra el artifact: Tiendanube + neto de ventas en negro + ventas de cambio.</summary>
    public decimal Ingresos => IngresosTiendanube + VentasNegroNeto + VentasCambio;

    public decimal Margen =>
        IngresosTiendanube - Comision - Envio - Costo - AdsStreet + VentasNegroNeto - Perdidas + VentasCambio;
}

/// <summary>
/// Margen real de Street (pasos 2, 2.5, 3, 3.9 y 3.10 de reglas-artifact.md), sin IO.
/// El gasto de Kumo nunca entra acá.
/// </summary>
public static class MargenCalculo
{
    /// <param name="estadoPagoNube">Marca de pago_nube_cuotas del pedido, si existe.</param>
    public static MargenPedido Pedido(PedidoMargen pedido, EstadoPagoNube? estadoPagoNube = null,
        Func<DateOnly, decimal>? umbralCuotas = null)
    {
        var comision = ComisionMedioPago.Calcular(pedido.Gateway, pedido.Total, pedido.Fecha, estadoPagoNube, umbralCuotas);
        var envio = EnvioAbsorbido.Aplica(pedido.Fecha, pedido.Total, trackingNumber: null, pedido.ShippingOption)
            ? EnvioAbsorbido.CostoEstimado
            : 0m;

        var costo = 0m;
        var sinCosto = new List<string>();
        foreach (var item in pedido.Items.Where(i => i.Cantidad > 0))
        {
            if (CostoMercaderiaTiendanube.PorProducto(item.Nombre) is { } unitario)
            {
                costo += unitario * item.Cantidad;
            }
            else
            {
                sinCosto.Add(item.Nombre);
            }
        }

        return new MargenPedido(pedido.Number, pedido.Total, comision.Monto, envio, costo,
            !comision.MedioConocido, sinCosto, EsPagoNubeSinConfirmar(pedido, estadoPagoNube, umbralCuotas));
    }

    /// <summary>Pago Nube por encima del umbral de cuotas sin marcar "cuotas" o "simple": hay que pedirle a Lucas que lo marque.</summary>
    public static bool EsPagoNubeSinConfirmar(PedidoMargen pedido, EstadoPagoNube? estado,
        Func<DateOnly, decimal>? umbralCuotas = null)
    {
        var umbral = (umbralCuotas ?? ComisionMedioPago.UmbralCuotas)(pedido.Fecha);
        return ComisionMedioPago.EsPagoNube(pedido.Gateway) && pedido.Total > umbral
            && estado is null or EstadoPagoNube.Pending;
    }

    public static MargenPeriodo Periodo(
        IEnumerable<MargenPedido> pedidos, decimal adsStreet,
        IEnumerable<VentaNegro> ventasNegro, IEnumerable<PerdidaMercaderia> perdidas, IEnumerable<CambioVenta> ventasCambio)
    {
        var lista = pedidos.ToList();
        var avisos = new List<string>();
        foreach (var p in lista)
        {
            if (p.MedioDesconocido)
            {
                avisos.Add($"Pedido #{p.Number}: medio de pago desconocido, no se restó comisión.");
            }

            if (p.ItemsSinCosto.Count > 0)
            {
                avisos.Add($"Pedido #{p.Number}: sin costo de mercadería para {string.Join(", ", p.ItemsSinCosto)}.");
            }

            if (p.PagoNubeSinConfirmar)
            {
                avisos.Add($"Pedido #{p.Number}: Pago Nube sin confirmar si fue en cuotas; se usó 5,48%.");
            }
        }

        var negroNeto = 0m;
        foreach (var venta in ventasNegro)
        {
            negroNeto += venta.TotalAmount - venta.Items.Sum(i => CostoItemNegro(i, avisos));
        }

        var perdido = 0m;
        foreach (var perdida in perdidas)
        {
            perdido += CostoRemera(perdida.Color, perdida.Corte, avisos) * perdida.Cantidad;
        }

        return new MargenPeriodo(
            lista.Count,
            lista.Sum(p => p.Ingreso),
            lista.Sum(p => p.Comision),
            lista.Sum(p => p.Envio),
            lista.Sum(p => p.Costo),
            adsStreet,
            negroNeto,
            perdido,
            ventasCambio.Sum(v => v.Monto),
            avisos);
    }

    private static decimal CostoItemNegro(VentaNegroItem item, List<string> avisos) =>
        item.Tipo.Trim().ToLowerInvariant() switch
        {
            "buzo" => CostoPrenda.Calcular("buzo") * item.Cantidad,
            "pantalon" or "pantalón" => CostoPrenda.Calcular("pantalon") * item.Cantidad,
            // Los documentos viejos sin tipo son remeras.
            _ => CostoRemera(item.Color, item.Corte, avisos) * item.Cantidad
        };

    private static decimal CostoRemera(string? color, string? corte, List<string> avisos)
    {
        if (string.IsNullOrWhiteSpace(color) || string.IsNullOrWhiteSpace(corte))
        {
            avisos.Add($"Remera sin color o corte cargado: se usó el aproximado de ${CostoPrenda.RemeraSinCorte:N0}.");
            return CostoPrenda.RemeraSinCorte;
        }

        return CostoPrenda.Calcular("remera", color, corte);
    }
}
