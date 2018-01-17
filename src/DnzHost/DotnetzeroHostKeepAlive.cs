using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;

namespace DnzHost
{
    public static class DotnetzeroHostKeepAlive
    {
        [FunctionName("DotnetzeroHostKeepAlive")]
        public static async Task Run([TimerTrigger("0 */4 * * * *")]TimerInfo myTimer, TraceWriter log)
        {
            var statusEndpoint = Environment.GetEnvironmentVariable("StatusEndpoint");
            var client = new HttpClient() { BaseAddress = new Uri(statusEndpoint) };
            var response = await client.SendAsync(new HttpRequestMessage(HttpMethod.Get, client.BaseAddress));
            log.Info($"Keep alive ran at {DateTime.UtcNow} Utc. {HttpMethod.Get} {response.StatusCode} {client.BaseAddress}:");
        }
    }
}
