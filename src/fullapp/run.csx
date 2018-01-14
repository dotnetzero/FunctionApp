using System.Net;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.IO;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Blob;
using System.Configuration;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    bool beta = false;
    string productionContainer = Environment.GetEnvironmentVariable("ProductionContainer");
    string betaContainer = Environment.GetEnvironmentVariable("BetaContainer");

    var response = new HttpResponseMessage(HttpStatusCode.OK);

    var connectionString = ConfigurationManager.ConnectionStrings["store01dotnetzero_STORAGE"].ConnectionString;
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