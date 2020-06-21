$reader_app_name = "NKJUn21"
$resourceGroupName = "NKJUn21"

Connect-AzureAD
$ad_app=Get-AzureADApplication -Filter "displayName eq '$reader_app_name'"

If ($ad_app -ne $null) {
Remove-AzureADApplication -ObjectId $ad_app.ObjectId
}

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Mode Complete  -TemplateFile .\ResourceGroupCleanup.template.json -Force -Verbose
