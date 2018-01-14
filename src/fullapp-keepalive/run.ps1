$uri = $env:StatusEndpoint

if($uri -ne $null){
    Write-Output "PowerShell Timer trigger function executed at:$(get-date). Pinging $uri";
    $response = Invoke-RestMethod -Uri $uri
} else {
    Write-Output "PowerShell Timer trigger function executed at:$(get-date). Nothing to ping";   
}
