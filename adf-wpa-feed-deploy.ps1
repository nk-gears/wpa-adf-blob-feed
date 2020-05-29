Write-Host "Setting up Workplace Analytics Reader App..."

#Get-AzureRmSubscription –SubscriptionName $subscriptionName | Select-AzureRmSubscription


#====================CONFIG EDIT===========================================
$templatePath = "./template.json"
$templateBaseParamPath = "./template-params.json"
$reader_app_name = "NK WPA Data Reader App"
$reader_app_role_name = "Analyst"
$wpa_app_name = "Workplace Analytics"
$resourceGroupName = "nkwpa-adf-setup-rg"
$resourceGroupLocation = "eastus"

#===============================================================

# Create a Azure App by Registering One. Skip If Exists
$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"
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

#Creating Client Secret
$appClientSecret=""


$startDate = Get-Date
$endDate = $startDate.AddYears(3)
$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"
$appClientSecret = New-AzureADApplicationPasswordCredential -ObjectId $ad_app.ObjectId  -CustomKeyIdentifier "DataReaderClientSecret" -StartDate $startDate -EndDate $endDate

echo "Client Secret Created."
$appClientSecretText=$appClientSecret.Value

$json = Get-Content $templateBaseParamPath | Out-String | ConvertFrom-Json
$parameters = $json.parameters

$parameters = @{
	 wpaReaderAppSecret= $appClientSecretText
	 wpaAppStorageAccType=$parameters.wpaAppStorageAccType.value
	 wpaAppStorageAccNamePrefix=$parameters.wpaAppStorageAccNamePrefix.value
	 wpaAppDataFactoryName =$parameters.wpaAppDataFactoryName.value
	 wpaSourceODataFeedUrl =$parameters.wpaSourceODataFeedUrl.value
	 wpaSourceODataFeedQuery =$parameters.wpaSourceODataFeedQuery.value
	 copyToBlobStorageMode =$parameters.copyToBlobStorageMode.value
}


echo "Preparing for ARM Template Deployment"
$RGnotExist = 0
$rg=Get-AzResourceGroup -Name $resourceGroupName -ev RGnotExist -ea 0
if ($RGnotExist)
{
	 #create resource group
    $rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}

# Create Resource Group


echo $parameters
$ARMOutput =New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $templatePath -TemplateParameterObject $parameters


#New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $templatePath -TemplateParameterObject $parameters -Verbose
#-TemplateParameterFile ./ADFTutorialARM-Parameters.json
#-TemplateParameterFile ./template-params.json
# New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -keyVaultName $keyVaultName -adUserId $adUserId -secretValue $secretValue