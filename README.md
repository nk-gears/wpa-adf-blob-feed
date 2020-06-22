# Setup Azure Data Factory to Extract OData Feed from Workplace Analytics to Blob Storage

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnk-gears%2Fwpa-adf-blob-feed%2Fmaster%2Ftemplate.json)


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
   - And then from PowerShell run: `Connect-AzAccount`
   - If you you have multiple subcriptions, you will need to select the one you want to use:
     - `Select-AzureAzSubscription`

The following sections explains how this will be achieved.


### Configuration Variables

```
# Powershell Input Prompts
- Subscription Id   : Use this for WPA : bc85080a-0c4a-41ba-8b88-add5d6714c4b
- Resource Group Name
- AD App Registration Name

### Deafult Values
- Resource Group Location defauled to eastus. Please update Powershell if you want to change

```

### Template Parameters

App Specific
- wpaReaderAppSecretName

Vault Specific
- wpaKeyVaultName
- skipVaultCreation (to resuse existing in the same RG)

Storage & ADF Specific
- wpaAppStorageAccType
- wpaAppStorageAccNamePrefix
- wpaAppDataFactoryName
- wpaADFJobName   e.g PersonEmailStats
- wpaEntityName   e.g : Persons or Meetings
- wpaSourceODataFeedUrl

**FAQs**

> 1. **Can't we Just use the ARM Template (DeployTemplate via UI) Option to run the entrire steps.?. Do we really need the Powershell ?**

- *Currently, Microsoft doesn't provide an Option to Register a Active Directory Application. The Powershell is used only for the ActiveDirectory Creation with Service Principal and to Create Secrets Automatically.*
- *So, Without Powershell we can't setup this*. We can skip the Powershell for the Subsequent Incremental Deployments. But for the Initial Setup, they MUST use the Powershell to bootstrap the environment


>2. Is it Possible to deploy the Multiple ADF's or Multiple Pipeline Under the same ADF and Resource Group ?

- *We have added a new Parameter called "wpaADFJobName". This can be used to control this behaviour*


## Folder Structure
```
-- template.json
-- template-params.json
-- adf-wpa-feed-deploy.ps1
-- adf-wpa-destroy.ps1
-- show-parameters.ps1

```

### Deploy the template

Please edit the variables before deploying

Deploy the template using the PowerShell ISE (Hit F5) or with PowerShell: `.\adf-wpa-feed-deploy.ps1`

### Destroy the resources

`.\adf-wpa-destroy.ps1`

### Note

```
The  current OData WPA Service seems to work like a limited dataset. No dynamic query supported at this time. This is confirmed by thr WPA DEv Team.

Example :
This is a example odata public service, I can use $select. $top etc.
https://services.odata.org/v4/(S(34wtn2c0hkuk5ekg0pjr513b))/TripPinServiceRW/People?$top=1

```

