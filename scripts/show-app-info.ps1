<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER ADAppRegistrationName
	Optional, AD App Registration Name

#>


param(

 [Parameter(Mandatory=$True)]
 [string]
 $ADAppRegistrationName

)

$reader_app_name = $ADAppRegistrationName

$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

Write-Host "App Id : "
Write-Host $ad_app.AppId
$reader_sp = Get-AzureADServicePrincipal -Filter "displayName eq '$reader_app_name'"

Write-Host "Service Principal Id : "
Write-Host $reader_sp.ObjectId