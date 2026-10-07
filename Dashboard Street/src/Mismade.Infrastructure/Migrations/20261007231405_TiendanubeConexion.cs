using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mismade.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class TiendanubeConexion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TiendanubeConexiones",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false),
                    StoreId = table.Column<long>(type: "bigint", nullable: false),
                    AccessTokenProtegido = table.Column<string>(type: "text", nullable: false),
                    Scope = table.Column<string>(type: "text", nullable: false),
                    ConnectedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ConnectedBy = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TiendanubeConexiones", x => x.Id);
                    table.CheckConstraint("CK_TiendanubeConexion_Unica", "\"Id\" = 1");
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TiendanubeConexiones");
        }
    }
}
