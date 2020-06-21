<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER ADAppRegistrationName
	Optional, AD App Registration Name

#>


param(


 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,


 [Parameter(Mandatory=$True)]
 [string]
 $ADAppRegistrationName

)


$reader_app_name = $ADAppRegistrationName
$resourceGroupName =  $resourceGroupName


$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

If ($ad_app -ne $null) {
Remove-AzureADApplication -ObjectId $ad_app.ObjectId
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Mode Complete  -TemplateFile .\ResourceGroupCleanup.template.json -Force -Verbose
