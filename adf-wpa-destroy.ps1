$reader_app_name = "NK WPA Data Reader App final"
$resourceGroupName = "nkwpa-adf-setup-rg1"

Connect-AzureAD
$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

If ($ad_app -ne $null) {
Remove-AzureADApplication -ObjectId $ad_app.ObjectId
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Mode Complete  -TemplateFile .\ResourceGroupCleanup.template.json -Force -Verbose
