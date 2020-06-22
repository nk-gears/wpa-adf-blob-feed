
# Change Log


## 2020.6.22
- Added Incremental Support to deploy Multiple ADF or PipelineJobs
- Added Dynamic Grouping of Data based on JobName. wpaexports/2020/mettinginfo/2342342342.csv
- Refactored the Powershell with user friendly Prompts. No need to edit the powershell files
- Created a New script show-parameters.ps1 to get the AppId and Service Principal Id. This way they don't need to search for the AppId and Service PrincipalId for subsequent deployments.


## 2020.6.10

### Dynamic Schema
- Added support to parse schema dynamically without need for fixed mapping
- Added support to have custom entityName. This means we no more need to have a fixed Entity Name.
- Added support for OData query like "$select=fieldName&$top=10" like this by introducing 2 additional template variables



## 2020.6.1

Refactored with KeyVault Support


## 2020.5.24

* Initial version with linked templates to deploy the scripts
