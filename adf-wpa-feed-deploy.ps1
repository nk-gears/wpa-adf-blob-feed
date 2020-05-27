# Create Resource Group
$resourceGroupName = "nkwpa-adf-setup-rg"
$resourceGroupLocation = "eastus"
$rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation

$templatePath = "./template.json"

# Deploy Template
$parameters = @{
	storageAccountType = "Standard_LRS";
	storageAccountNamePrefix = "storage";
}


New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $templatePath -TemplateParameterFile ./template-params.json

#New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile $templatePath -TemplateParameterObject $parameters -Verbose
#-TemplateParameterFile ./ADFTutorialARM-Parameters.json

# New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -keyVaultName $keyVaultName -adUserId $adUserId -secretValue $secretValue