using System.Security.Cryptography;
using System.Text;
using Mismade.Web;
using Xunit;

namespace Mismade.Tests;

public sealed class TiendanubeWebhooksTests
{
    private const string Secret = "secreto-de-prueba";
    private const string Body = """{"store_id":123456}""";

    private static string Firmar(string body, string secret) => Convert.ToHexString(
        HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), Encoding.UTF8.GetBytes(body))).ToLowerInvariant();

    [Fact]
    public void FirmaCorrectaEsValida() =>
        Assert.True(TiendanubeWebhooks.IsValid(Body, Firmar(Body, Secret), Secret));

    [Fact]
    public void FirmaEnMayusculasTambienEsValida() =>
        Assert.True(TiendanubeWebhooks.IsValid(Body, Firmar(Body, Secret).ToUpperInvariant(), Secret));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("no-es-hex")]
    [InlineData("00ff")]
    public void FirmaInvalidaSeRechaza(string? firma) =>
        Assert.False(TiendanubeWebhooks.IsValid(Body, firma, Secret));

    [Fact]
    public void CuerpoAlteradoSeRechaza() =>
        Assert.False(TiendanubeWebhooks.IsValid("""{"store_id":999}""", Firmar(Body, Secret), Secret));

    [Fact]
    public void SinSecretConfiguradoSeRechaza() =>
        Assert.False(TiendanubeWebhooks.IsValid(Body, Firmar(Body, ""), ""));
}
