function Set-AzureWebAppSettings {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][HashTable]$Appsettings,
        [string]$ResourceGroupName,
        [string]$WebAppName,
        [switch]$Replace = $false
    )

    process {

        if ($Appsettings.Count -eq 0) {
            Write-Verbose "No appsettings passed!"
            return
        }

        if ($Replace) {
            Write-Verbose "Replacing app settings for $($ResourceGroupName) / $($WebAppName)"
            Set-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $Appsettings
            return;
        }

        Write-Verbose "Getting app settings for $($ResourceGroupName) / $($WebAppName)"
        $webApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName

        $newAppSettings = @{}

        $webApp.SiteConfig.AppSettings | ForEach-Object {
        
            Write-Verbose "Searching incoming app settings for key $($_.Name)"            
            $result = $Appsettings[$_.Name]

            if ($result -eq $null) {
                Write-Verbose "Ignore: Key $($_.Name) does not existing in the incoming app settings"
                $newAppSettings.Add($_.Name, $_.Value)
            }
            else {
                Write-Verbose "Update: Key $($_.Name) exists in the incoming app settings as $result"
                $newAppSettings.Add($_.Name, $result)
            }

        }
    
        $Appsettings.GetEnumerator() |`
            Where-Object { -Not $newAppSettings.Contains($_.Key) } |`
            ForEach-Object { 
            Write-Verbose "Create: Key $($_.Name) does not exists in the remote app settings"
            $newAppSettings.Add($_.Key, $_.Value)  
        }
    
        Set-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $newAppSettings
        
    }
}
