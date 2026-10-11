using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mismade.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class ImportacionArtifact : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "AdsKumo",
                table: "MonthlyHistories",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "AdsStreet",
                table: "MonthlyHistories",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Comision",
                table: "MonthlyHistories",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "CostoMercaderia",
                table: "MonthlyHistories",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "Envio",
                table: "MonthlyHistories",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "Nota",
                table: "MonthlyHistories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Cantidad",
                table: "CrisLedger",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "CrisLedger",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Corte",
                table: "CrisLedger",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Talle",
                table: "CrisLedger",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "StockConjuntoVariants",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Color = table.Column<string>(type: "text", nullable: false),
                    Talle = table.Column<string>(type: "text", nullable: false),
                    TiendanubeProductId = table.Column<long>(type: "bigint", nullable: false),
                    TiendanubeVariantId = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockConjuntoVariants", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StockPrendas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Tipo = table.Column<string>(type: "text", nullable: false),
                    Color = table.Column<string>(type: "text", nullable: false),
                    Talle = table.Column<string>(type: "text", nullable: false),
                    Stock = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockPrendas", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_StockConjuntoVariants_TiendanubeVariantId",
                table: "StockConjuntoVariants",
                column: "TiendanubeVariantId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StockPrendas_Tipo_Color_Talle",
                table: "StockPrendas",
                columns: new[] { "Tipo", "Color", "Talle" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StockConjuntoVariants");

            migrationBuilder.DropTable(
                name: "StockPrendas");

            migrationBuilder.DropColumn(
                name: "AdsKumo",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "AdsStreet",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "Comision",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "CostoMercaderia",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "Envio",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "Nota",
                table: "MonthlyHistories");

            migrationBuilder.DropColumn(
                name: "Cantidad",
                table: "CrisLedger");

            migrationBuilder.DropColumn(
                name: "Color",
                table: "CrisLedger");

            migrationBuilder.DropColumn(
                name: "Corte",
                table: "CrisLedger");

            migrationBuilder.DropColumn(
                name: "Talle",
                table: "CrisLedger");
        }
    }
}
