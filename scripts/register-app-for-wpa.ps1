<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

  .PARAMETER subscriptionId
	The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER ADAppRegistrationName
	Optional, AD App Registration Name

#>

param(

 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,


 [Parameter(Mandatory=$True)]
 [string]
 $ADAppRegistrationName

)

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzSubscription -SubscriptionID $subscriptionId;

Write-Host "Setting up Workplace Analytics Reader App..."

# App Registration
#========================================================
$reader_app_name = $ADAppRegistrationName
$reader_app_role_name = "Analyst"
$wpa_app_name = "Workplace Analytics"


# Create a Azure App by Registering One. Skip If Exists
$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

echo "Checking App Registration..."

If ($ad_app -eq $null) {

	$app = New-AzureADApplication -DisplayName $reader_app_name -ReplyUrls https://nourl
	$appSp = New-AzureADServicePrincipal -appid $app.AppId
	echo "App Registraton done for $reader_app_name"

	echo $appSp;

	$sp = Get-AzureADServicePrincipal -Filter "displayName eq '$wpa_app_name'"
	$sp.AppRoles | Where-Object { $_.DisplayName -eq 'User.Read'}

	#Assign AppRole
	$reader_appRole = $sp.AppRoles | Where-Object { $_.DisplayName -eq $reader_app_role_name }
	$reader_sp = Get-AzureADServicePrincipal -Filter "displayName eq '$reader_app_name'"
	New-AzureADServiceAppRoleAssignment -ObjectId $reader_sp.ObjectId -PrincipalId $reader_sp.ObjectId -ResourceId $sp.ObjectId -Id $reader_appRole.Id
}

	echo "Deployment is in Progress.."
	Start-Sleep -s 20
	$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

    echo "App Registration  Completed. Please use ./show-app-info.ps1 to view the AppId after few minutes."
