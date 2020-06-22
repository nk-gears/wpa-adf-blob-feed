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

$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

echo "App Id : $ad_app.AppId "
$reader_sp = Get-AzureADServicePrincipal -Filter "displayName eq '$reader_app_name'"

echo "Service Principal Id : $reader_sp.ObjectId"