# Some useful commands

_running locally https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local_

## From the CLI makes sure you have the Azure Functions CLI tools installed

`npm install -g azure-functions-core-tools@core`

To Start the local debugger

`func host start --debug vscode`

To work with your own subsciption

- `func azure subscriptions list`
- `func azure subscriptions set your_subscription_id`
- `func azure storage list`

To work with your own storage account settings

- `func azure storage list`
- `func azure storage fetch-connection-string your_storage_account`
- `func azure storage fetch-connection-string list`

To work with your own app service account app settings

- `func azure functionapp fetch-app-settings dotnetzero`
- `func host start`


local.settings.json

```json

{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=your_storage_account_name;AccountKey=your_account_key",
    "ProductionContainer": "$root",
    "BetaContainer": "beta",
    "AzureWebJobsDashboard": "DefaultEndpointsProtocol=https;AccountName=your_storage_account_name;AccountKey=your_account_key",
    "FUNCTIONS_EXTENSION_VERSION": "~1",
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING": "DefaultEndpointsProtocol=https;AccountName=your_storage_account_name;AccountKey=your_account_key",
    "WEBSITE_CONTENTSHARE": "dotnetzero9a75",
    "WEBSITE_NODE_DEFAULT_VERSION": "6.5.0",
    "AzureWebJobsSecretStorageType": "Blob"
  },
  "ConnectionStrings": {
    "store01dotnetzero_STORAGE": {
      "ConnectionString": "DefaultEndpointsProtocol=https;AccountName=your_storage_account_name;AccountKey=your_account_key",
      "ProviderName": "System.Data.SqlClient"
    }
  }
}

```