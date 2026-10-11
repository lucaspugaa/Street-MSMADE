using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Mismade.Application;
using Mismade.Domain;
using Mismade.Infrastructure;
using Xunit;

namespace Mismade.Tests;

public sealed class MovimientosManualesTests
{
    private static readonly DateOnly Fecha = new(2026, 10, 11);
    private static VentaNegro Venta(int cantidad, string tipo = "remera", string color = "Negro", string corte = "Regular", string talle = "XXL") => new()
    {
        Fecha = Fecha, TotalAmount = 5000,
        Items = [new VentaNegroItem { Tipo = tipo, Color = color, Corte = corte, Talle = talle, Cantidad = cantidad }]
    };

    private static async Task<Fixture> CrearAsync(int stock = 3, SaveChangesInterceptor? interceptor = null)
    {
        var connection = new SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        var factory = new Factory(connection, interceptor);
        await using var db = factory.CreateDbContext();
        await db.Database.ExecuteSqlRawAsync(db.Database.GenerateCreateScript()
            .Replace("\"xmin\" INTEGER NOT NULL", "\"xmin\" INTEGER NOT NULL DEFAULT 0"));
        db.StockRemeras.Add(new StockRemera { Color = "Negro", Corte = "Regular", Talle = "XXL", Stock = stock });
        db.StockManualPools.Add(new StockManualPool { Nombre = "Buzo Negro XXL Regular", Stock = stock });
        db.StockPrendas.Add(new StockPrenda { Tipo = StockPrenda.Buzo, Color = "Negro", Talle = "XXL", Stock = 10 });
        await db.SaveChangesAsync();
        return new Fixture(connection, factory);
    }

    [Theory]
    [InlineData("venta", 2)]
    [InlineData("venta", 5)]
    [InlineData("perdida", 2)]
    [InlineData("perdida", 5)]
    [InlineData("cris", 2)]
    [InlineData("cris", 5)]
    public async Task RestasDeRemerasYBorradoRestauranSoloLoDescontado(string tipo, int cantidad)
    {
        await using var f = await CrearAsync();
        var resultado = tipo switch
        {
            "venta" => await f.Servicio.RegistrarVentaNegroAsync(Venta(cantidad)),
            "perdida" => await f.Servicio.RegistrarPerdidaAsync(new PerdidaMercaderia
            {
                Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = cantidad, Motivo = "Rotura"
            }),
            _ => await f.Servicio.RegistrarCrisAsync(new CrisLedger
            {
                Fecha = Fecha, Tipo = TipoMovimientoCris.Devolucion, Color = "Negro", Corte = "Regular",
                Talle = "XXL", Cantidad = cantidad, Monto = 2000
            })
        };
        await using (var db = f.Factory.CreateDbContext())
        {
            Assert.Equal(Math.Max(0, 3 - cantidad), (await db.StockRemeras.SingleAsync()).Stock);
            Assert.Equal(3, (await db.StockManualPools.SingleAsync()).Stock);
        }

        Assert.Equal(cantidad > 3, resultado.Avisos.Count > 0);
        if (cantidad > 3)
        {
            Assert.Contains("piso en 0", Assert.Single(resultado.Avisos));
        }

        _ = tipo switch
        {
            "venta" => await f.Servicio.BorrarVentaNegroAsync(resultado.Id),
            "perdida" => await f.Servicio.BorrarPerdidaAsync(resultado.Id),
            _ => await f.Servicio.BorrarCrisAsync(resultado.Id)
        };
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(3, (await verificacion.StockRemeras.SingleAsync()).Stock);
        Assert.Empty(await verificacion.VentasNegro.ToListAsync());
        Assert.Empty(await verificacion.VentaNegroItems.ToListAsync());
        Assert.Empty(await verificacion.PerdidasMercaderia.ToListAsync());
        Assert.Empty(await verificacion.CrisLedger.ToListAsync());
    }

    [Theory]
    [InlineData("Negro", "Regular", "XXL", "buzo", true)]
    [InlineData("Negro", "Oversize", "XXL", "buzo", false)]
    [InlineData("Negro", "Regular", "L", "buzo", false)]
    [InlineData("Crema", "Regular", "XXL", "buzo", false)]
    [InlineData("Negro", "Regular", "XXL", "pantalon", false)]
    public async Task SoloBuzoNegroXxlRegularDescuentaPoolManual(string color, string corte, string talle, string tipo, bool descuenta)
    {
        await using var f = await CrearAsync();
        var resultado = await f.Servicio.RegistrarVentaNegroAsync(Venta(5, tipo, color, corte, talle));
        await using (var db = f.Factory.CreateDbContext())
        {
            Assert.Equal(descuenta ? 0 : 3, (await db.StockManualPools.SingleAsync()).Stock);
            Assert.Equal(3, (await db.StockRemeras.SingleAsync()).Stock);
            Assert.Equal(10, (await db.StockPrendas.SingleAsync()).Stock);
            Assert.NotNull((await db.VentasNegro.SingleAsync()).EfectoStock);
        }

        Assert.Equal(descuenta, resultado.Avisos.Count > 0);
        await f.Servicio.BorrarVentaNegroAsync(resultado.Id);
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(3, (await verificacion.StockManualPools.SingleAsync()).Stock);
    }

    [Theory]
    [InlineData(TipoMovimientoCris.Pago)]
    [InlineData(TipoMovimientoCris.Compra)]
    [InlineData(TipoMovimientoCris.SaldoInicial)]
    public async Task CrisSinStockPuedeBorrarseInclusoImportado(TipoMovimientoCris tipo)
    {
        await using var f = await CrearAsync();
        var resultado = await f.Servicio.RegistrarCrisAsync(new CrisLedger { Fecha = Fecha, Tipo = tipo, Monto = 1000 });
        await f.Servicio.BorrarCrisAsync(resultado.Id);
        var importado = new CrisLedger { Fecha = Fecha, Tipo = tipo, Monto = 2000 };
        await using (var db = f.Factory.CreateDbContext())
        {
            db.CrisLedger.Add(importado);
            await db.SaveChangesAsync();
        }

        await f.Servicio.BorrarCrisAsync(importado.Id);
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Empty(await verificacion.CrisLedger.ToListAsync());
        Assert.Equal(3, (await verificacion.StockRemeras.SingleAsync()).Stock);
        Assert.Equal(3, (await verificacion.StockManualPools.SingleAsync()).Stock);
    }

    [Fact]
    public async Task CambioDescuentaSalidasCreaStockRecibidoYRevierteEfectosReales()
    {
        await using var f = await CrearAsync();
        var resultado = await f.Servicio.RegistrarCambioAsync(new CambioPrenda
        {
            Fecha = Fecha,
            ItemsSalida = [new CambioItemSalida { Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = 5 }],
            ItemsRecibidos = [
                new CambioItemRecibido { Color = "Crema", Corte = "Regular", Talle = "L", Cantidad = 2 },
                new CambioItemRecibido { Color = "Crema", Corte = "Regular", Talle = "L", Cantidad = 1 }
            ]
        });
        Assert.Single(resultado.Avisos);
        await using (var db = f.Factory.CreateDbContext())
        {
            Assert.Equal(0, (await db.StockRemeras.SingleAsync()).Stock);
            Assert.Equal(3, (await db.StockCambios.SingleAsync()).Disponible);
        }

        await f.Servicio.BorrarCambioAsync(resultado.Id);
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(3, (await verificacion.StockRemeras.SingleAsync()).Stock);
        Assert.Equal(0, (await verificacion.StockCambios.SingleAsync()).Disponible);
        Assert.Empty(await verificacion.CambiosPrenda.ToListAsync());
        Assert.Empty(await verificacion.CambioItemsSalida.ToListAsync());
        Assert.Empty(await verificacion.CambioItemsRecibidos.ToListAsync());
    }

    [Theory]
    [InlineData(2)]
    [InlineData(5)]
    public async Task CargaYVentaCambioSeReviertenExactamenteConPiso(int cantidad)
    {
        await using var f = await CrearAsync();
        var carga = await f.Servicio.RegistrarCargaAsync(new CambioStockCarga
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = 3
        });
        var venta = await f.Servicio.RegistrarVentaCambioAsync(new CambioVenta
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = cantidad, Monto = 1000
        });
        Assert.Equal(cantidad > 3, venta.Avisos.Count > 0);
        await using (var db = f.Factory.CreateDbContext())
        {
            Assert.Equal(Math.Max(0, 3 - cantidad), (await db.StockCambios.SingleAsync()).Disponible);
        }

        await f.Servicio.BorrarVentaCambioAsync(venta.Id);
        await using (var db = f.Factory.CreateDbContext())
        {
            Assert.Equal(3, (await db.StockCambios.SingleAsync()).Disponible);
        }

        await f.Servicio.BorrarCargaAsync(carga.Id);
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.Equal(0, (await verificacion.StockCambios.SingleAsync()).Disponible);
        Assert.Empty(await verificacion.CambioStockCargas.ToListAsync());
        Assert.Empty(await verificacion.CambioVentas.ToListAsync());
    }

    [Fact]
    public async Task ReversaDeUnaSumaTienePisoSiElStockYaSeVendio()
    {
        await using var f = await CrearAsync();
        var carga = await f.Servicio.RegistrarCargaAsync(new CambioStockCarga
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = 3
        });
        await f.Servicio.RegistrarVentaCambioAsync(new CambioVenta
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = 2, Monto = 1000
        });
        var resultado = await f.Servicio.BorrarCargaAsync(carga.Id);
        Assert.Contains("piso en 0", Assert.Single(resultado.Avisos));
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(0, (await db.StockCambios.SingleAsync()).Disponible);
    }

    [Theory]
    [InlineData("venta")]
    [InlineData("perdida")]
    [InlineData("cris")]
    [InlineData("cambio")]
    [InlineData("carga")]
    [InlineData("ventaCambio")]
    public async Task NoBorraMovimientosImportadosConEfectoDesconocido(string tipo)
    {
        await using var f = await CrearAsync();
        Entidad importado = tipo switch
        {
            "venta" => Venta(1),
            "perdida" => new PerdidaMercaderia { Fecha = Fecha },
            "cris" => new CrisLedger { Fecha = Fecha, Tipo = TipoMovimientoCris.Devolucion },
            "cambio" => new CambioPrenda { Fecha = Fecha },
            "carga" => new CambioStockCarga { Fecha = Fecha },
            _ => new CambioVenta { Fecha = Fecha }
        };
        await using (var db = f.Factory.CreateDbContext())
        {
            db.Add(importado);
            await db.SaveChangesAsync();
        }

        Task<ResultadoMovimiento> Borrar() => tipo switch
        {
            "venta" => f.Servicio.BorrarVentaNegroAsync(importado.Id),
            "perdida" => f.Servicio.BorrarPerdidaAsync(importado.Id),
            "cris" => f.Servicio.BorrarCrisAsync(importado.Id),
            "cambio" => f.Servicio.BorrarCambioAsync(importado.Id),
            "carga" => f.Servicio.BorrarCargaAsync(importado.Id),
            _ => f.Servicio.BorrarVentaCambioAsync(importado.Id)
        };
        var error = await Assert.ThrowsAsync<InvalidOperationException>(Borrar);
        Assert.Equal(MovimientosManualesService.MensajeImportado, error.Message);
        await using var verificacion = f.Factory.CreateDbContext();
        Assert.NotNull(await verificacion.FindAsync(importado.GetType(), importado.Id));
        Assert.Equal(3, (await verificacion.StockRemeras.SingleAsync()).Stock);
    }

    [Fact]
    public async Task SiFallaUnItemSeRevierteElStockYNoSeGuardaLaVenta()
    {
        await using var f = await CrearAsync();
        var venta = Venta(2);
        venta.Items.Add(new VentaNegroItem { Tipo = "remera", Color = "Inexistente", Corte = "Regular", Talle = "L", Cantidad = 1 });
        await Assert.ThrowsAsync<InvalidOperationException>(() => f.Servicio.RegistrarVentaNegroAsync(venta));
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(3, (await db.StockRemeras.SingleAsync()).Stock);
        Assert.Empty(await db.VentasNegro.ToListAsync());
        Assert.Empty(await db.VentaNegroItems.ToListAsync());
    }

    [Fact]
    public async Task SiFallaDespuesDeGuardarSeRevierteTodaLaTransaccion()
    {
        var interceptor = new FalloGuardado();
        await using var f = await CrearAsync(interceptor: interceptor);
        interceptor.Activo = true;
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Servicio.RegistrarVentaNegroAsync(Venta(2)));
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(3, (await db.StockRemeras.SingleAsync()).Stock);
        Assert.Empty(await db.VentasNegro.ToListAsync());
        Assert.Empty(await db.VentaNegroItems.ToListAsync());
    }

    [Theory]
    [InlineData(1)]
    [InlineData(2)]
    public async Task ConcurrenciaReintentaUnaVezSinDuplicarEfectos(int fallos)
    {
        var interceptor = new FalloGuardado { Concurrencia = true, FallosRestantes = fallos };
        await using var f = await CrearAsync(interceptor: interceptor);
        interceptor.Activo = true;
        if (fallos == 1)
        {
            await f.Servicio.RegistrarVentaNegroAsync(Venta(2));
        }
        else
        {
            await Assert.ThrowsAsync<DbUpdateConcurrencyException>(() => f.Servicio.RegistrarVentaNegroAsync(Venta(2)));
        }

        Assert.Equal(2, interceptor.Intentos);
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(fallos == 1 ? 1 : 3, (await db.StockRemeras.SingleAsync()).Stock);
        Assert.Equal(fallos == 1 ? 1 : 0, await db.VentasNegro.CountAsync());
    }

    [Fact]
    public async Task BorradoFallidoTambienRevierteStockYConservaMovimiento()
    {
        var interceptor = new FalloGuardado();
        await using var f = await CrearAsync(interceptor: interceptor);
        var venta = await f.Servicio.RegistrarVentaNegroAsync(Venta(2));
        interceptor.Activo = true;
        await Assert.ThrowsAsync<DbUpdateException>(() => f.Servicio.BorrarVentaNegroAsync(venta.Id));
        await using var db = f.Factory.CreateDbContext();
        Assert.Equal(1, (await db.StockRemeras.SingleAsync()).Stock);
        Assert.Single(await db.VentasNegro.ToListAsync());
        Assert.Single(await db.VentaNegroItems.ToListAsync());
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(0)]
    public async Task CargaYVentaRechazanCantidadesNoPositivas(int cantidad)
    {
        await using var f = await CrearAsync();
        await Assert.ThrowsAsync<ArgumentException>(() => f.Servicio.RegistrarCargaAsync(new CambioStockCarga
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = cantidad
        }));
        await Assert.ThrowsAsync<ArgumentException>(() => f.Servicio.RegistrarVentaCambioAsync(new CambioVenta
        {
            Fecha = Fecha, Color = "Negro", Corte = "Regular", Talle = "XXL", Cantidad = cantidad
        }));
        await using var db = f.Factory.CreateDbContext();
        Assert.Empty(await db.StockCambios.ToListAsync());
        Assert.Empty(await db.CambioStockCargas.ToListAsync());
        Assert.Empty(await db.CambioVentas.ToListAsync());
    }

    private sealed class FalloGuardado : SaveChangesInterceptor
    {
        public bool Activo { get; set; }
        public bool Concurrencia { get; set; }
        public int FallosRestantes { get; set; } = 1;
        public int Intentos { get; private set; }
        public override ValueTask<int> SavedChangesAsync(SaveChangesCompletedEventData eventData, int result,
            CancellationToken cancellationToken = default)
        {
            if (Activo)
            {
                Intentos++;
                if (FallosRestantes-- > 0)
                {
                    if (Concurrencia)
                    {
                        throw new DbUpdateConcurrencyException("Conflicto simulado después de guardar.");
                    }

                    throw new DbUpdateException("Fallo simulado después de guardar.");
                }
            }

            return ValueTask.FromResult(result);
        }
    }

    private sealed class Factory(SqliteConnection connection, SaveChangesInterceptor? interceptor) : IDbContextFactory<MismadeDbContext>
    {
        public MismadeDbContext CreateDbContext()
        {
            var options = new DbContextOptionsBuilder<MismadeDbContext>().UseSqlite(connection);
            if (interceptor is not null)
            {
                options.AddInterceptors(interceptor);
            }

            return new MismadeDbContext(options.Options);
        }
    }

    private sealed class Fixture(SqliteConnection connection, Factory factory) : IAsyncDisposable
    {
        public Factory Factory { get; } = factory;
        public MovimientosManualesService Servicio { get; } = new(factory);
        public ValueTask DisposeAsync() => connection.DisposeAsync();
    }
}
