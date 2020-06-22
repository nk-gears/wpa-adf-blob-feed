<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

  .PARAMETER subscriptionId
	The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER ADAppRegistrationName
	Optional, AD App Registration Name

#>


param(

 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,

 [string]
 $resourceGroupLocation = "eastus",

 [Parameter(Mandatory=$True)]
 [string]
 $ADAppRegistrationName

)

#====================CONFIG EDIT===========================================
$templatePath = "./template.json"
$templateBaseParamPath = "./template-params.json"
#===============================================================



# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzSubscription -SubscriptionID $subscriptionId;

Write-Host "Setting up Workplace Analytics Reader App..."
#bc85080a-0c4a-41ba-8b88-add5d6714c4b

# App Registration
#========================================================
$reader_app_name = $ADAppRegistrationName
$reader_app_role_name = "Analyst"
$wpa_app_name = "Workplace Analytics"

$json = Get-Content $templateBaseParamPath | Out-String | ConvertFrom-Json
$tplParameters = $json.parameters


echo "Running Pre-liminary Scripts "

#Connect-AzureAD

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

	$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"


#======RESOURCE GROUP CREATION==============================================

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    $resourceGroup=New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

#=====ADD SECRET TO APP===================================================
$dataReaderAppClientSecret=""
$appSecretIdentifier=$tplParameters.wpaReaderAppSecretName.value
# Create a Client Secret If not exists
$app_secretInfo=Get-AzureADApplicationPasswordCredential -ObjectId $ad_app.ObjectId
If ($app_secretInfo -eq $null) {

$startDate = Get-Date
$endDate = $startDate.AddYears(3)

$appClientSecret = New-AzureADApplicationPasswordCredential -ObjectId $ad_app.ObjectId  -CustomKeyIdentifier $appSecretIdentifier -StartDate $startDate -EndDate $endDate
echo "Client Secret Created."

#Store the Secret temporarily so that we can pass it to KeyVault creation
$dataReaderAppClientSecret=$appClientSecret.Value

}



#----------PREPARE TEMPLATE Parameters--------------------------------------------------------------
$createVaultSkip="No"
$vault=Get-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $tplParameters.wpaKeyVaultName.value
If($vault){
	$createVaultSkip="Yes"
}

echo "Skip Vault Creation $createVaultSkip"


$ad_App_sp = Get-AzureADServicePrincipal -Filter "displayName eq '$reader_app_name'"
$appServicePrincipalId=$ad_App_sp.ObjectId

	# Prepare the necessary parameters for the template
	$parameters = @{}
	foreach ( $Property in $tplParameters.psobject.Properties){
		#$arguments += @{$Property.Name = $Property.value}
		$parameters[$Property.Name]=$Property.value.value
	}

	$parameters["wpaReaderAppId"]=$ad_app.AppId
	$parameters["skipVaultCreation"]=$createVaultSkip
	$parameters["appServicePrincipalId"]= $appServicePrincipalId
	$parameters["wpaReaderAppSecretValue"]= $dataReaderAppClientSecret

   echo "Preparing for ARM Template Deployment"


   echo "Deploying ARM Resources..."
   echo $parameters
   $ARMOutput =New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile $templatePath -TemplateParameterObject $parameters
   echo  $ARMOutput


echo "Deployment Completed."