[CmdletBinding()]
param (
    [string]$sourcePath = "src",
    [string]$artifactsPath = "artifacts"
)

process {

    $gitversionFile = ".git\gitversion_cache\*.yml"

    if ((Test-Path -Path $artifactsPath) -eq $false) {
        New-Item -Type Directory -Path $artifactsPath -Force | Out-Null
    }
    else {
        Write-Verbose "Cleaning $artifactsPath"
        Remove-Item -Force -Recurse -Path "$artifactsPath\*"
    }

    if (Test-Path -Path $gitversionFile) {
        Write-Verbose "Copying $gitversionFile to $artifactsPath\version.txt"
        Copy-Item $gitversionFile -Destination "$artifactsPath\version.txt"
    }
    else {
        Write-Verbose "No $gitversionFile found"
    }

    Copy-Item -Force -Path "$sourcePath\*" -Recurse -Destination $artifactsPath -Exclude local.settings.json

    if (Test-Path -Path "$artifactsPath\_proxies.json") {
        Write-Verbose "Copy $artifactsPath\_proxies.json to $artifactsPath\proxies.json"
        Move-Item -Force "$artifactsPath\_proxies.json" "$artifactsPath\proxies.json"
    }

}