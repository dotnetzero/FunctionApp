function Get-AzureRMDeploymentOutputVariables {
    [CmdletBinding()]
    param (
        [string]$ResourceGroupName
    )

    process {

        $azureRmResourceGroupDeployment = Get-AzureRmResourceGroupDeployment -ResourceGroupName "$ResourceGroupName" | `
            Sort-Object Timestamp -Descending | `
            Select-Object -First 1

        $variables = @{}
        $azureRmResourceGroupDeployment.Outputs.GetEnumerator() | ForEach-Object {
            $variables.Add($_.key,$_.value.Value)
        }

        return $variables
    }
}
