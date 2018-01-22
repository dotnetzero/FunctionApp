using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.WindowsAzure.Storage;

namespace DnzHost
{
    public static class DotnetzeroHost
    {
        private static HttpClient client = new HttpClient();

        [FunctionName("DotnetzeroHost")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]HttpRequestMessage req, TraceWriter log)
        {
            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            log.Info($"azureServiceTokenProvider: {azureServiceTokenProvider}");

            var kvClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback), client);
            log.Info($"kvClient: {kvClient}");

            var vaultBaseUrl = Environment.GetEnvironmentVariable("storageAccountKey1Uri");
            log.Info($"vaultBaseUrl: {vaultBaseUrl}");

            var secretBundle = await kvClient.GetSecretAsync(vaultBaseUrl);
            log.Info($"secretBundleValue: {secretBundle.Value}");

            string connectionString = secretBundle.Value;

            bool beta = false;
            string productionContainer = Environment.GetEnvironmentVariable("ProductionContainer");
            string betaContainer = Environment.GetEnvironmentVariable("BetaContainer");

            var response = new HttpResponseMessage(HttpStatusCode.OK);

            var storageAccount = CloudStorageAccount.Parse(connectionString);
            log.Info($"connectionString: {storageAccount}");
            var blobClient = storageAccount.CreateCloudBlobClient();
            var container = blobClient.GetContainerReference(beta ? betaContainer : productionContainer);

            //DISGUISED-HOST
            var uri = GetHeader(req, "DISGUISED-HOST");
            if (!string.IsNullOrWhiteSpace(uri))
            {
                log.Info($"DISGUISED-HOST: {uri}");
                var segments = uri.Split('.');
                var host = segments.FirstOrDefault();
                if (host.Equals("status", StringComparison.OrdinalIgnoreCase))
                {
                    log.Info($"Status Request");
                    return response;
                }
                beta = host.Equals("beta", StringComparison.OrdinalIgnoreCase);
                log.Info($"Beta Request: {beta}");
            }

            if (req.Headers.Accept != null && req.Headers.Accept.Any(x => x.MediaType == "text/html"))
            {
                log.Info("web page leg");
                var blockBlob2 = container.GetBlockBlobReference("index.html");
                string script;
                using (var memoryStream = new MemoryStream())
                {
                    await blockBlob2.DownloadToStreamAsync(memoryStream);
                    script = System.Text.Encoding.UTF8.GetString(memoryStream.ToArray());
                }

                response.Content = new ByteArrayContent(System.Text.Encoding.UTF8.GetBytes(script));
                response.Content.Headers.ContentType = new MediaTypeHeaderValue("text/html");
            }
            else
            {
                log.Info("script leg");

                var isPowerShell = req.Headers.UserAgent.ToString().ToLower().Contains("powershell");

                string file = isPowerShell ? "init.ps1" : "init.sh";

                log.Info($"returning {file}");

                var blockBlob2 = container.GetBlockBlobReference(file);

                string script;
                using (var memoryStream = new MemoryStream())
                {
                    blockBlob2.DownloadToStream(memoryStream);
                    script = System.Text.Encoding.UTF8.GetString(memoryStream.ToArray());
                }

                if (isPowerShell)
                {
                    var queryString = req.GetQueryNameValuePairs();
                    var keyValuePair = queryString.FirstOrDefault(x => x.Key == "clicmd");
                    string cmd = keyValuePair.Key == null ? "New-SourceTree" : keyValuePair.Value;

                    script += $"{System.Environment.NewLine}{cmd}{System.Environment.NewLine}";
                }

                response.Content = new ByteArrayContent(System.Text.Encoding.UTF8.GetBytes(script));
                response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            }

            return response;
        }

        public static string GetHeader(HttpRequestMessage request, string key)
        {
            IEnumerable<string> keys = null;
            if (!request.Headers.TryGetValues(key, out keys))
                return null;

            return keys.First();
        }

    }
}
