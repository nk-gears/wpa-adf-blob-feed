- Incremental Template
- ResourceGroup Name and Secret Keys Need not be Created again and again
-


ssh -R 80:localhost:8000 serveo.net

Enable-AzureRmContextAutosave

Import-Module Az

Connect-AzAccount




=>Virtual AppRegistration => WPA oDAta
                            => Storage
                            => KeyVault

Portal
CLI - Az
Powershell


Workflow
Powershell => AD App => Service Principal => Secret => ARM => KeyVault => ADF => PIPEline => Datasets => BlobStorage => Permissions KeyVault => AppRegistration can Talk to this


Resource Group : NK22
KeyVault : WPAKEyVAULt

Resource Group : NK23
KeyVault : WPAKEyVAULtRS => Global Reosurce But you can tie to a Resource Group


Multiple ADF Incrementally :
Resource Group : NK22
wpaADFName : ADF1

1ST DEPLOYING : ADF1

Resource Group : NK22
wpaADFName : ADF2

2ND DEPLOYING : ADF2


Portal : ADF1 and ADF2

Multiple Pipeline Job Incrementally :

ADFJobName : MeetingTimeSpentADF

Pipeline : Dataset => LinkedServices => Connection to the Source

PipelineName : CopyData_MeetingTimeSpentADF
Dataset : Dataset_MeetingTimeSpentADF
LinkedServices : LS_EntityName

