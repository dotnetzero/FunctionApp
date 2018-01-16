[CmdletBinding()]
param (
    [string]$sourcePath = "src",
    [string]$artifactsPath = "artifacts"
)

process {

    $azureSourceDirectory = "$sourcePath\Azure"

    $gitversionFile = ".git\gitversion_cache\*.yml"
    
    $azureArtifactsDirectory = "$artifactsPath\Azure"
    $azureToolsModule = "$azureArtifactsDirectory\Azure-Tools.psm1"
    $azureFunctionsArtfiactsPath = "$artifactsPath\Functions"

    $artifactsPath, $azureFunctionsArtfiactsPath | Foreach-Object {
        if (-Not (Test-Path -Path $_)) {
            New-Item -Type Directory -Path $_ -Force | Out-Null
        }
        else {
            Write-Verbose "Cleaning $artifactsPath"
            Remove-Item -Force -Recurse -Path "$artifactsPath\*"
        }
    }

    if (Test-Path -Path $gitversionFile) {
        Write-Verbose "Copying $gitversionFile to $artifactsPath\version.txt"
        Copy-Item $gitversionFile -Destination "$artifactsPath\version.txt"
    }
    else {
        Write-Verbose "No $gitversionFile found"
    }

    Copy-Item -Force -Path "$sourcePath\*" -Recurse -Destination $azureFunctionsArtfiactsPath -Exclude local.settings.json, Azure

    if (Test-Path -Path "$azureFunctionsArtfiactsPath\_proxies.json") {
        Write-Verbose "Copy $azureFunctionsArtfiactsPath\_proxies.json to $azureFunctionsArtfiactsPath\proxies.json"
        Move-Item -Force "$azureFunctionsArtfiactsPath\_proxies.json" "$azureFunctionsArtfiactsPath\proxies.json"
    }

    # Build Azure PowerShell Tooling
    # if (((Test-Path -Path "$azureArtifactsDirectory") -eq $false) -and (Test-Path -Path $azureSourceDirectory) ) {
    if (Test-Path -Path $azureSourceDirectory) {
        Write-Verbose "Build Azure Tools for Release Management"

        New-Item -ItemType Directory -Path $azureArtifactsDirectory -Force -ErrorAction Ignore | Out-Null

        $modules = @()
        Get-ChildItem $azureSourceDirectory -Filter "*.ps1" | ForEach-Object {
            Add-Content -Encoding Ascii -Path $azureToolsModule -Value (Get-Content -Raw $_.FullName)
            $modules += $_.BaseName
            Write-Verbose " - added $($_.BaseName) to the module collection"
        }
        
        Add-Content -Encoding Ascii -Path $azureToolsModule -Value "Export-ModuleMember -Function $($modules -join `",`")"
    }

}