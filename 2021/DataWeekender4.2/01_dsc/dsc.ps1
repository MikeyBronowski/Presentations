<#
https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview/overview

https://github.com/dsccommunity/SqlServerDsc

https://www.powershellgallery.com/packages/PSDesiredStateConfiguration
2.0.5
Minimum PowerShell version
6.1

#>
cls

# navigate to the folder with dsc scripts
Set-Location $env:OneDrive\SQL\Presentation\DataWeekender\2021_4.2\01_dsc

# dot source the config file to load configuration function
Start-Process code -WindowStyle maximized dsc_config.ps1
. .\dsc_config.ps1


# make sure there is no extra folders/files
Get-ChildItem -Path dscDemo | Remove-Item -Force
Get-Item -Path dscDemo | Remove-Item
Get-ChildItem

Get-ChildItem -Path C:\dscDemoDir | Remove-Item -Force
Get-Item -Path C:\dscDemoDir | Remove-Item

# execute the configuration function
dscDemo -ComputerName $Env:computername, localhost, DataWeekender
Get-ChildItem

# review files created
Invoke-Item dscDemo
Start-Process code -WindowStyle maximized dscDemo\localhost.mof

# 
Start-DscConfiguration -Path .\dscDemo -Wait -Verbose

# Wait  ->  The command includes the Wait parameter. 
#           Therefore, you cannot use the console until the command finishes all configuration tasks.

# Force ->  Stops the configuration operation currently running on the target computer 
#           and begins the new Start-Configuration operation.

ii C:\dscDemoDir

################################
# publishing DSC config 


# navigate to the folder with dsc scripts
Set-Location $env:OneDrive\SQL\Presentation\DataWeekender\2021_4.2\dsc

# Uploads a DSC script to Azure blob storage.
# local zip
Publish-AzVMDscConfiguration -ConfigurationPath ".\dsc_config.ps1" -OutputArchivePath ".\dsc_config.ps1.zip"

# Azure storage
Publish-AzVMDscConfiguration -ConfigurationPath ".\dsc_config.ps1" -ResourceGroupName resourcegroup

cls