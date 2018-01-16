function Get-EnvironmentalVariables {
    [CmdletBinding()]
    param (
        [string]$EnvironmentalVariablePattern
    )

    process {

        $appSettings = @{}
        $pattern = $EnvironmentalVariablePattern -replace "\*", $null
        Get-ChildItem Env:\ | `
            Where-Object { $_.Name -like "*$($pattern)*" } | `
            ForEach-Object {
            Write-Verbose "Looking for match against $($_.Name)"
            if (-not $appSettings.Contains($_.Name)) {
                $appSettings.Add(($_.Name -replace $pattern, $null), $_.Value)
                Write-Verbose "Environment variable $($_.Name) added without $($pattern)"
            }
        }
        return $appSettings

    }
}
