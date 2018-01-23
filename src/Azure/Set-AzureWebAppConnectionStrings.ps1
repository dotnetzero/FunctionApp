function Set-AzureWebAppConnectionStrings {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][HashTable]$ConnectionStrings,
        [string]$ResourceGroupName,
        [string]$WebAppName,
        [string]$ConnectionStringType = "SqlAzure"
    )

    process {

        if ($ConnectionStrings.Count -gt 0) {
            Write-Verbose "Setting $($ConnectionStrings.Count) connection strings for $($ResourceGroupName) / $($WebAppName)"

            $connectionStringHash = @{}
            $ConnectionStrings.GetEnumerator() | ForEach-Object{
                $connectionStringHash.Add($_.Name, @{ Type = $ConnectionStringType; Value = $_.Value })
            }

            Set-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ConnectionStrings $connectionStringHash
        }

    }
}
