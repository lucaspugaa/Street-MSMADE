using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mismade.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SyncDetalle : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Detalle",
                table: "JobRuns",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Detalle",
                table: "JobRuns");
        }
    }
}
