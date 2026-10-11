using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mismade.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class DesacoplesYVariantesPrendas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "StockDesacoples",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    PoolKey = table.Column<string>(type: "text", nullable: false),
                    StockAtDecouple = table.Column<int>(type: "integer", nullable: false),
                    AutoCreated = table.Column<bool>(type: "boolean", nullable: false),
                    Reason = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockDesacoples", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StockPrendaVariants",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    StockPrendaId = table.Column<Guid>(type: "uuid", nullable: false),
                    TiendanubeProductId = table.Column<long>(type: "bigint", nullable: false),
                    TiendanubeVariantId = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StockPrendaVariants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StockPrendaVariants_StockPrendas_StockPrendaId",
                        column: x => x.StockPrendaId,
                        principalTable: "StockPrendas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_StockDesacoples_PoolKey",
                table: "StockDesacoples",
                column: "PoolKey",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StockPrendaVariants_StockPrendaId",
                table: "StockPrendaVariants",
                column: "StockPrendaId");

            migrationBuilder.CreateIndex(
                name: "IX_StockPrendaVariants_TiendanubeVariantId",
                table: "StockPrendaVariants",
                column: "TiendanubeVariantId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StockDesacoples");

            migrationBuilder.DropTable(
                name: "StockPrendaVariants");
        }
    }
}
