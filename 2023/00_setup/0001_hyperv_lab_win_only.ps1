$number = 18
$labName = "PowerDBA$number"
$labSources = 'C:\LabSources'

Clear-LabCache
Remove-Lab -Name $labName -Confirm:$false
 
#Domain based on Lab name
$domainName = "$labName.com"
 
#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV 
 
#Define the network range
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace "192.168.$number.0/24"

#Define an External, Internet connection
Add-LabVirtualNetworkDefinition -Name 'Default Switch' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }


#Set installation user
Set-LabInstallationCredential -Username PowerDBA -Password SQLDay2022
#Create domain definition with the domain admin account
Add-LabDomainDefinition -Name $domainName -AdminUser PowerDBA -AdminPassword SQLDay2022
  
#defining default parameter values, as these ones are the same for all the machines
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
$PSDefaultParameterValues = @{
	'Add-LabMachineDefinition:NetworkAdapter' 	= $netAdapter
	'Add-LabMachineDefinition:ToolsPath'		= "$labSources\Tools"
	'Add-LabMachineDefinition:DomainName' 		= $domainName
	'Add-LabMachineDefinition:DnsServer1' 		=  "192.168.$number.10"
    'Add-LabMachineDefinition:OperatingSystem' 	= $(Get-LabAvailableOperatingSystem | where{ $_.ImageIndex -eq 2 } |  select -first 1).OperatingSystemName
}
 
#the first machine is the root domain controller. Everything in $labSources\Tools gets copied to the machine's Windows folder
$dc1 = ("doc"+$LabName)
Add-LabMachineDefinition -Name $dc1 -Memory 4GB -Roles RootDC -IpAddress "192.168.$number.10"


Install-Lab 
Show-LabDeploymentSummary -Detailed
Install-Lab -PostDeploymentTests
Checkpoint-LabVM -All -SnapshotName 'FirstSnapshot'
Import-Module -Name pester



Invoke-LabCommand -ActivityName 'Set TLS12' -ScriptBlock { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install NuGet' -ScriptBlock { Install-PackageProvider -Name NuGet -Force } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install pester' -ScriptBlock { Install-Module -Name Pester -RequiredVersion 4.10.1 -Force -SkipPublisherCheck  -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install pester' -ScriptBlock { Install-Module -Name Pester -Force -SkipPublisherCheck  -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install dbatools' -ScriptBlock { Install-Module -Name dbatools -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru
#Invoke-LabCommand -ActivityName 'Install dbachecks' -ScriptBlock { Install-Module -Name dbachecks -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install dbachecks' -ScriptBlock { Install-Module -Name dbachecks -AllowPrerelease -Force -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru
Invoke-LabCommand -ActivityName 'Install importexcel' -ScriptBlock { Install-Module -Name importexcel -ErrorAction SilentlyContinue } -ComputerName $dc1 -PassThru

Invoke-LabCommand -ActivityName 'Install dbatools' -ScriptBlock { Install-Module -Name dbatools -ErrorAction SilentlyContinue } -ComputerName PowerDBA03DC1 -PassThru
Import-Lab -Name PowerDBA03

Install-LabSoftwarePackage -LocalPath "C:\Tools\SSMS-Setup-ENU.exe" -CommandLine '/Install /Passive' -ComputerName $dc1 #-AsJob