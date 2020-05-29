
# Setup Azure Data Factory to Extract OData Feed from Workplace Analytics to Blob Storage




[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnk-gears%2Fwpa-adf-blob-feed%2Fmaster%2Ftemplate.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https://raw.githubusercontent.com/nk-gears/wpa-adf-blob-feed/master/template.json)



This document explains on how to Setup the Azure Data Factory and Access Data from Workplace Analytics Enterprise App and Copy them to a Blob Storage using  Azure Resource Manager Template with Powershell Script.

**Prerequisites**

- Microsoft Azure subscription
  - If you do not have one, you can obtain one (for free) here: [https://azure.microsoft.com/free](https://azure.microsoft.com/free/)
  - The account used to signin must have the **global administrator** role granted to it.

- Powershell 7.0 to Execute the Scripts.
- Alternatively you can also use Azure Shell in Azure to Exceute these Scripts



### Setup your environment

1. Install AzureRM powershell module (If you already have it installed, skip to the next step.)
   - Documentation: https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps
   - Open up PowerShell ISE or PowerShell and run the following:
     - `Install-Module -Name Az -AllowClobber -Scope CurrentUser`
2. Login to your Azure Subscription
   - If you don't have an Azure account, sign up for free here: https://azure.microsoft.com/en-us/free/
   - And then from PowerShell run: `Connect-AzureAzAccount`
   - If you you have multiple subcriptions, you will need to select the one you want to use:
     - `Select-AzureAzSubscription`

The following sections explains how this will be achieved.


### Configuration Variables

```
# Common Variables inside Powershell
$resourceGroupName = "<rg name>"
$resourceGroupRegion = "<rg location>"
$templatePath = "<path>"

```

### Template Parameters

```

wpaAppStorageAccType
wpaAppStorageAccNamePrefix
wpaAppDataFactoryName
wpaSourceODataFeedUrl
wpaSourceODataFeedQuery
copyToBlobStorageMode



```


## Folder Structure
```
-- template.json
-- template-params.json
-- adf-wpa-feed-deploy.ps1

```

### Deploy the template

Deploy the template using the PowerShell ISE (Hit F5) or with PowerShell: `.\adf-wpa-feed-deploy.ps1`




