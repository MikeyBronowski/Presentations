#----------------------------------------
# Author: 	Craig Porteous
# Date:		16/10/2017
# This creates a domain with 2 SQL Servers
# & restores Sample DBs using the dbatools 
# module
#----------------------------------------
# Prerequisites
#-----------------------------------
# Install dbatools module locally
# > Install-Module dbatools
#-----------------------------------
# Clear-LabCache
# Remove-Lab -Name $labName -Confirm:$false
#Define the Lab name
$labName = 'PowerDBA'
$labSources = 'C:\LabSources'
 
#Domain based on Lab name
$domainName = "$labName.com"
 
#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV 
 
#Define the network range
Add-LabVirtualNetworkDefinition -Name $labName
#Define an External, Internet connection
Add-LabVirtualNetworkDefinition -Name External -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }
 
#Set installation user
Set-LabInstallationCredential -Username PowerDBA -Password SQLDay2022
#Create domain definition with the domain admin account
Add-LabDomainDefinition -Name $domainName -AdminUser PowerDBA -AdminPassword SQLDay2022
 
#Read all ISOs in the LabSources folder and add the SQL 2019 ISO
Add-LabIsoImageDefinition -Name SQLServer2019 -Path "$labSources\ISOs\en_sql_server_2019_developer_x64_dvd_baea4195.iso"
# Add-LabIsoImageDefinition -Name winserver2022mar -Path "$labSources\ISOs\en-us_windows_server_2022_updated_march_2022_x64_dvd_8c24bdba.iso"

 
 
#defining default parameter values, as these ones are the same for all the machines
$PSDefaultParameterValues = @{
	'Add-LabMachineDefinition:Network' = $labName
	'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
	'Add-LabMachineDefinition:DomainName' = $domainName
	#'Add-LabMachineDefinition:OperatingSystem' = $(Get-LabAvailableOperatingSystem | select -first 1).OperatingSystemName
    'Add-LabMachineDefinition:OperatingSystem' = $(Get-LabAvailableOperatingSystem | where{ $_.ImageIndex -eq 2 } |  select -first 1).OperatingSystemName
}
 
#the first machine is the root domain controller. Everything in $labSources\Tools gets copied to the machine's Windows folder
$dc1 = ($LabName + "DC1")
Add-LabMachineDefinition -Name $dc1 -Memory 2GB -Roles RootDC, ADDS
### Get-LabMachineDefinition  | Remove-LabMachineDefinition
 
#Define Network adapter
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch External -UseDhcp


$role = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{Features = 'SQLEngine'}

#Create VM
$sql1 = ($LabName + "SQL1")
Add-LabMachineDefinition -Name $sql1 -Memory 4GB -NetworkAdapter $netAdapter -Roles $role
 
#Create VM
$sql2 = ($LabName + "SQL2")
Add-LabMachineDefinition -Name $sql2 -Memory 2GB -Roles $role

#Create VM
$sql3 = ($LabName + "SQL3")
Add-LabMachineDefinition -Name $sql3 -Memory 2GB -Roles $role


Install-Lab 
Install-LabSoftwarePackage -LocalPath "C:\Tools\SSMS-Setup-ENU.exe" -CommandLine '/Install /Passive' -ComputerName $dc1 #-AsJob

 <#
 
 WARNING: Cannot run post-deployment Pester test as there is no Pester version 5.0+ installed. 
 Please run 'Install-Module -Name Pester -Force' if you want the post-deployment script to work. 
 You can start the post-deployment tests separately with the command 'Install-Lab -PostDeploymentTests'
 
 
 #>
Show-LabDeploymentSummary -Detailed
 
#Copy DBs to SQL1 VM
### Copy-LabFileItem -Path 'D:\LabSources\Sample DBs\' -ComputerName $sql1 -DestinationFolderPath C:\
### Copy-LabFileItem -Path 'D:\LabSources\Sample DWs\' -ComputerName $sql1 -DestinationFolderPath C:\
 
 
#Install dbaTools module on SQL1
Invoke-LabCommand -ActivityName 'Install dbatools' -ScriptBlock { Install-Module -Name dbatools -ErrorAction SilentlyContinue } -ComputerName $sql1 -PassThru
 
#Restore Database on SQL1
### Invoke-LabCommand -ActivityName 'Restore DBs' -ScriptBlock { Restore-DbaDatabase -SqlServer $env:COMPUTERNAME -Path 'C:\Sample DBs' } -ComputerName $sql1 -PassThru
#Restore Data Warehouse DB on SQL2 from SQL1
### Invoke-LabCommand -ActivityName 'Restore DWs' -ScriptBlock { Restore-DbaDatabase -SqlServer $sql2 -Path 'C:\Sample DWs' } -Variable (Get-Variable -Name sql2) -ComputerName $sql1 -PassThru





Add-LabMachineDefinition -Name $sql1 -Roles $role
Add-LabMachineDefinition -Name $sql2 -Roles $role
Add-LabMachineDefinition -Name $sql3 -Roles $role



# install SSMS silently
Install-LabSoftwarePackage -LocalPath "C:\Tools\SSMS-Setup-ENU.exe" -CommandLine '/Install /Passive' -ComputerName $sql1 #-AsJob
