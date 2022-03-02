<#

https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview

#>

# change directory
cls
Set-Location ..\03_bicep

Install-Module AZ -Force
Install-Module dbatools -Force

# install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


# install Azure CLI
choco install azure-cli -y

# restart PowerShell session

# install Bicep
az bicep install
az bicep upgrade
az bicep version

az bicep decompile --file ..\02_arm\arm2bicep.json

# deploy bicep with DSC3
<#
az group create -n dscarmbicep-backup -l uksouth
az deployment group create --resource-group dscarmbicep-backup --template-file main.bicep
#>


# deploy bicep with DSC
az group create -n dscarmbicep -l uksouth
az deployment group create --resource-group dscarmbicep --template-file main.bicep


# https://bicepdemo.z22.web.core.windows.net/


cls