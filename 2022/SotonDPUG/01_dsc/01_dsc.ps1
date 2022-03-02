<#
https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/overview

https://github.com/dsccommunity/SqlServerDsc
Install-Module SqlServerDsc

https://www.powershellgallery.com/packages/PSDesiredStateConfiguration
Install-Module PSDesiredStateConfiguration
Get-Module SqlServerDsc, PSDesiredStateConfiguration -listavailable
2.0.5
Minimum PowerShell version
6.1

#>
cls



# navigate to the folder with dsc scripts
Set-Location $env:OneDrive\SQL\Presentation\DSCArmBicep\SotonDPUG\01_dsc



# see content of the configuration file/function
Start-Process code -WindowStyle maximized dsc_config.ps1



# dot source the config file to load configuration function
. .\dsc_config.ps1


# make sure there is no extra folders/files
## subfolder dscDemo with MOF files
### Managed Object Format (MOF) files are used to describe Common Information Model (CIM) classes
Get-ChildItem -Path dscDemo -ErrorAction SilentlyContinue | Remove-Item -Force
Get-Item -Path dscDemo -ErrorAction SilentlyContinue | Remove-Item
Get-ChildItem

## target demo folder with file
Get-ChildItem -Path C:\dscDemoDir -ErrorAction SilentlyContinue | Remove-Item -Force
Get-Item -Path C:\dscDemoDir -ErrorAction SilentlyContinue | Remove-Item

# execute the configuration function to create MOF files 
dscDemo -ComputerName $Env:computername, localhost, DSCArmBicep
Get-ChildItem

# review files created
Invoke-Item dscDemo
Start-Process code -WindowStyle maximized dscDemo\localhost.mof

# apply the configuration to the nodes
Start-DscConfiguration -Path .\dscDemo -Wait -Verbose

# Wait  ->  The command includes the Wait parameter. 
#           Therefore, you cannot use the console until the command finishes all configuration tasks.

# Force ->  Stops the configuration operation currently running on the target computer 
#           and begins the new Start-Configuration operation.

# check the newly created folder with file
Invoke-Item C:\dscDemoDir




################################
# publishing DSC config 


# navigate to the folder with dsc scripts
Set-Location $env:OneDrive\SQL\Presentation\DSCArmBicep\SQLFriday2022\01_dsc

# Uploads a DSC script to Azure blob storage.
# local zip
Publish-AzVMDscConfiguration -ConfigurationPath ".\dsc_config.ps1" -OutputArchivePath ".\dsc_config.ps1.zip"

# Azure storage
Publish-AzVMDscConfiguration -ConfigurationPath ".\dsc_config.ps1" -ResourceGroupName resourcegroup

cls