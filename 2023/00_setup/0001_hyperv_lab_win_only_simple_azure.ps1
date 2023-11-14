Build-MBLabAzure -Number 70 -SQL

function Build-MBLabAzure {
Param (
    [int]$Number = 123,
    [switch] $SQL
    )
$labName = "PowerDBA$number"
$labHost = ($LabName)

Clear-LabCache

Add-LabAzureSubscription -DefaultLocationName $azureDefaultLocation

#create an empty lab template and define where the lab XML files and the VMs will be stored
$azureDefaultLocation = 'West Europe' #COMMENT OUT -DefaultLocationName BELOW TO USE THE FASTEST LOCATION
New-LabDefinition -Name $labName -DefaultVirtualizationEngine Azure 
Add-LabAzureSubscription -DefaultLocationName $azureDefaultLocation


#Set installation user
Set-LabInstallationCredential -Username MikeyBronowski -Password PowerDBA2022!

Add-LabMachineDefinition -Name $labHost -Memory 4GB -OperatingSystem 'Windows Server 2016 Datacenter (Desktop Experience)'

Install-Lab

}
