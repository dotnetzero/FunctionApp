#Invoke-Pester -OutputFile .\results.xml -Script @{ Path= ".\This-Script.ps1"; Parameters = @{ MyFirstParameter = MyFirstParameterValue; MySecondParameter = MySecondParameterValue; } }
[CmdletBinding()]
param (
    [parameter(ValueFromPipeline)][HashTable]$Appsettings,
    [string]$ResourceGroupName,
    [string]$WebAppName
)

process {

    Write-Verbose "Checking $($Appsettings.Count) app settings"

    Describe 'Configuration Value' {

        $expected = @()
        $appSettings.GetEnumerator() | ForEach-Object { $expected += @{ ExpectedKey = $_.Name; ExpectedValue = $_.Value } }

        Context "for Azure Web Apps" {

            $webApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName

            It "Given appSettings key <ExpectedKey>, it should be <ExpectedValue>" -TestCases $expected {
                param($ExpectedKey, $ExpectedValue)

                $result = $webApp.SiteConfig.AppSettings.Find( { param($s) $s.Name -eq $ExpectedKey }).Value
                $result | Should -Be $ExpectedValue
            }

        }

    }

}
