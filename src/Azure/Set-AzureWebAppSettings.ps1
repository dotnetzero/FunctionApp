function Set-AzureWebAppSettings {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][HashTable]$Appsettings,
        [string]$ResourceGroupName,
        [string]$WebAppName
    )

    process {

        if ($Appsettings.Count -gt 0) {
            Write-Verbose "Set $($Appsettings.Count) app settings for $($ResourceGroupName) / $($WebAppName)"
            Set-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $Appsettings
        }

    }
}
