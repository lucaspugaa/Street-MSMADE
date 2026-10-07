using Mismade.Infrastructure;
using Npgsql;
using Xunit;

namespace Mismade.Tests;

public sealed class PostgresConnectionStringTests
{
    [Fact]
    public void UrlDeNeonSeConvierteAFormatoNpgsql()
    {
        var result = new NpgsqlConnectionStringBuilder(PostgresConnectionString.Normalize(
            "postgresql://usr:p%40ss@ep-x.us-east-2.aws.neon.tech/Mismade?sslmode=require&channel_binding=require"));

        Assert.Equal("ep-x.us-east-2.aws.neon.tech", result.Host);
        Assert.Equal(5432, result.Port);
        Assert.Equal("Mismade", result.Database);
        Assert.Equal("usr", result.Username);
        Assert.Equal("p@ss", result.Password);
        Assert.Equal(SslMode.Require, result.SslMode);
        Assert.Equal(ChannelBinding.Require, result.ChannelBinding);
    }

    [Fact]
    public void UrlConPuertoYSslVerifyFull()
    {
        var result = new NpgsqlConnectionStringBuilder(PostgresConnectionString.Normalize(
            "postgres://u:p@db.local:6543/app?sslmode=verify-full"));

        Assert.Equal(6543, result.Port);
        Assert.Equal(SslMode.VerifyFull, result.SslMode);
    }

    [Fact]
    public void FormatoNpgsqlPasaIgual()
    {
        var result = new NpgsqlConnectionStringBuilder(PostgresConnectionString.Normalize(
            "Host=h;Database=d;Username=u;Password=p;SSL Mode=Require"));

        Assert.Equal("h", result.Host);
        Assert.Equal(SslMode.Require, result.SslMode);
    }

    [Theory]
    [InlineData("Host=h;Clave Rara=secreto123")]
    [InlineData("postgresql://u:secreto123@h/d?sslmode=cualquiera")]
    public void ErrorNoMuestraLaCadena(string value)
    {
        var ex = Assert.Throws<InvalidOperationException>(() => PostgresConnectionString.Normalize(value));
        Assert.DoesNotContain("secreto123", ex.Message);
        Assert.Null(ex.InnerException);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("  ")]
    public void VaciaFalla(string? value) =>
        Assert.Throws<InvalidOperationException>(() => PostgresConnectionString.Normalize(value));
}
