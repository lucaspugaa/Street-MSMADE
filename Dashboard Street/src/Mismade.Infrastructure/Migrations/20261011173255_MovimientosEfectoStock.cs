using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mismade.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MovimientosEfectoStock : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "VentasNegro",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<uint>(
                name: "xmin",
                table: "StockCambios",
                type: "xid",
                rowVersion: true,
                nullable: false,
                defaultValue: 0u);

            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "PerdidasMercaderia",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "CrisLedger",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "CambioVentas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "CambioStockCargas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EfectoStock",
                table: "CambiosPrenda",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "VentasNegro");

            migrationBuilder.DropColumn(
                name: "xmin",
                table: "StockCambios");

            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "PerdidasMercaderia");

            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "CrisLedger");

            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "CambioVentas");

            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "CambioStockCargas");

            migrationBuilder.DropColumn(
                name: "EfectoStock",
                table: "CambiosPrenda");
        }
    }
}
