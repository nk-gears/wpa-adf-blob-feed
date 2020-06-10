Write-Host "Setting up Workplace Analytics Reader App..."

$reader_app_name = "NK-wpa-jun10"
$reader_app_role_name = "Analyst"
$wpa_app_name = "Workplace Analytics"
$resourceGroupName = "nkwpa-jun10"
$resourceGroupLocation = "eastus"


#====================CONFIG EDIT===========================================
$templatePath = "./template.json"
$templateBaseParamPath = "./template-params.json"
#===============================================================

$json = Get-Content $templateBaseParamPath | Out-String | ConvertFrom-Json
$tplParameters = $json.parameters


Connect-AzureAD

echo "Running Pre-liminary Scripts "
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

    $ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"
	$appSecretIdentifier=$tplParameters.wpaReaderAppSecretName.value
	# Create a Client Secret If not exists
	$app_secretInfo=Get-AzureADApplicationPasswordCredential -ObjectId $ad_app.ObjectId
	#If ($secret_exists -eq $null) {}

	$startDate = Get-Date
	$endDate = $startDate.AddYears(3)

	$appClientSecret = New-AzureADApplicationPasswordCredential -ObjectId $ad_app.ObjectId  -CustomKeyIdentifier $appSecretIdentifier -StartDate $startDate -EndDate $endDate

	echo "Client Secret Created."

	#Stoe the Secret temporarily so that we can pass it to KeyVault creation
	$dataReaderAppClientSecret=$appClientSecret.Value


	$ad_App_sp = Get-AzureADServicePrincipal -Filter "displayName eq '$reader_app_name'"
	$appServicePrincipalId=$ad_App_sp.ObjectId

	# Prepare the necessary parameters for the template
	$parameters = @{}
	foreach ( $Property in $tplParameters.psobject.Properties){
		#$arguments += @{$Property.Name = $Property.value}
		$parameters[$Property.Name]=$Property.value.value
	}

	$parameters["wpaReaderAppId"]=$ad_app.AppId
	$parameters["appServicePrincipalId"]= $appServicePrincipalId
	$parameters["wpaReaderAppSecretValue"]= $dataReaderAppClientSecret


   echo "Preparing for ARM Template Deployment"
   $RGnotExist = 0
   $rg=Get-AzResourceGroup -Name $resourceGroupName -ev RGnotExist -ea 0
   if ($RGnotExist)
   {
	 #create resource group
	 echo "Creating Resource Group"
	 $rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation

   }else{
	   echo "Skipping Resource Group Creation as it already exists."
   }

   echo "Deploying ARM Resources..."
   echo $parameters


   $ARMOutput =New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $templatePath -TemplateParameterObject $parameters #-debug

   echo  $ARMOutput
   echo "Running Post-Install Scripts  (after ARM Deployment) "

   $storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name  $ARMOutput.Outputs.storageAccountName.value


   echo "Assigning Permissions for the App to write to Blob Storage"
   $stg_role=Get-AzRoleAssignment -ObjectId $ad_App_sp.ObjectId -RoleDefinitionName "Storage Blob Data Contributor" -Scope $storageAcc.Id

   If ($stg_role -eq $null) {


	echo " Adding permissions for blob storage"
	$role_for_storage=New-AzRoleAssignment -ObjectId $ad_App_sp.ObjectId -RoleDefinitionName "Storage Blob Data Contributor" -Scope $storageAcc.Id

}

echo "Deployment Completed."