using System.Globalization;
using System.Net;

namespace Mismade.Infrastructure;

public static class TiendanubeRateLimit
{
    public static TimeSpan? GetDelay(HttpResponseMessage? response)
    {
        if (response is null)
        {
            return null;
        }

        var retry = response.Headers.RetryAfter;
        var delay = retry?.Delta ?? (retry?.Date is { } date ? date - DateTimeOffset.UtcNow : TimeSpan.Zero);
        if (response.StatusCode == HttpStatusCode.TooManyRequests
            && response.Headers.TryGetValues("x-rate-limit-reset", out var values)
            && double.TryParse(values.FirstOrDefault(), CultureInfo.InvariantCulture, out var milliseconds))
        {
            delay = TimeSpan.FromMilliseconds(Math.Max(delay.TotalMilliseconds, milliseconds));
        }

        if (delay > TimeSpan.Zero)
        {
            return delay;
        }

        return response.StatusCode == HttpStatusCode.TooManyRequests ? TimeSpan.FromSeconds(1) : null;
    }
}
