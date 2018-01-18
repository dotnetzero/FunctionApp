#Invoke-pester -OutputFile .\results.xml -Script @{ Path= ".\Test-HttpEndpoint.ps1"; Parameters = @{ TestUri = "https://example.com"  } }
[CmdletBinding()]
param(
    [string][Parameter(Mandatory = $true, ValueFromPipeline = $true)]$TestUri
)

describe 'Test Http Endpoint' {

    $result = Invoke-WebRequest -Uri $TestUri -MaximumRedirection 0 -ErrorAction Ignore
    
    it 'should return StatusCode 200' {
        $result.StatusCode | should be 200
    }

}