#Invoke-Pester -OutputFile .\results.xml -Script @{ Path= ".\This-Script.ps1"; Parameters = @{ MyFirstParameter = MyFirstParameterValue; MySecondParameter = MySecondParameterValue; } }
[CmdletBinding()]
param (
    [parameter(ValueFromPipeline)][HashTable]$ConnectionStrings,
    [string]$ResourceGroupName,
    [string]$WebAppName
)

process {

    Write-Verbose "Checking $($ConnectionStrings.Count) connection strings"

    Describe 'Configuration Value' {

        $expected = @()
        $ConnectionStrings.GetEnumerator() | ForEach-Object { $expected += @{ ConnectionStringName = $_.Name; ConnectionStringValue = $_.Value } }

        Context "for Azure Web Apps" {

            Write-Verbose "Get-AzureRmWebApp for $WebAppName in $ResourceGroupName"
            $webApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName

            It "Given connection string key <ConnectionStringName>, it should be <ConnectionStringValue>" -TestCases $expected {
                param($ConnectionStringName, $ConnectionStringValue)

                $result = $webApp.SiteConfig.ConnectionStrings.Find( { param($s) $s.Name -eq $ConnectionStringName }).ConnectionString
                $result | Should -Be $ConnectionStringValue
            }

        }

    }

}
