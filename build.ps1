[CmdletBinding()]
param (
    [string]$sourcePath = "src",
    [string]$artifactsPath = "artifacts"
)

process {

    $gitversionFile = ".git\gitversion_cache\*.yml"
    
    $azureArtifactsDirectory = "$artifactsPath\Azure"
    $azureSourceDirectory = "$sourcePath\Azure"
    $azureToolsModule = "$azureArtifactsDirectory\Azure-Tools.psm1"

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

    Copy-Item -Force -Path "$sourcePath\*" -Recurse -Destination $artifactsPath -Exclude local.settings.json, Azure

    if (Test-Path -Path "$artifactsPath\_proxies.json") {
        Write-Verbose "Copy $artifactsPath\_proxies.json to $artifactsPath\proxies.json"
        Move-Item -Force "$artifactsPath\_proxies.json" "$artifactsPath\proxies.json"
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