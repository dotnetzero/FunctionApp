function Set-VstsPipelineVariables {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)][HashTable]$Variables
    )

    process {

        $Variables.GetEnumerator() | ForEach-Object {
            $variableName = $_.Name
            $variableValue = $_.Value

            if ($variableValue.GetType().Name -eq "JObject") {
                $json = $variableValue.ToString() | ConvertFrom-Json
                $json.keys | ForEach-Object {
                    $keyName = $_.keyName
                    $variableName = "storageAccount$keyName"
                    $variableValue = $_.value
                    $variableDisplayValue = $variableValue.Substring(0,3) + "..." + $variableValue.Substring($variableValue.Length-5)
                    Write-Verbose "Creating new storageAccount variable: $variableName $variableDisplayValue"
                    Write-Host "##vso[task.setvariable variable=$variableName;]$variableValue"
                }
            }
            else {
                Write-Verbose "Creating new variable: $variableName $variableValue"
                Write-Host "##vso[task.setvariable variable=$variableName;]$variableValue"
            }
        }
    }
}
