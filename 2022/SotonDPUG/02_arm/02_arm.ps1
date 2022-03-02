<#
https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview
#>

# connect to Azure
Connect-AzAccount

# change directory
cls
Set-Location ..\02_arm

# export ResourceGroupName JSON
$armRG = 'dscarmbicep-backup'
$armVM = 'bicepvm'
Get-AzResourceGroup -ResourceGroupName $armRG | Export-AzResourceGroup

# export single resources JSON
$resourceId = $(Get-AzResource -ResourceGroupName $armRG -Name $armVM).ResourceId
Export-AzResourceGroup -ResourceGroupName $armRG -Resource $ResourceId


Get-AzResourceGroupDeployment -ResourceGroupName $armRG | ogv
# Save-AzResourceGroupDeploymentTemplate 


Get-AzDeployment | ogv 
# Save-AzDeploymentTemplate


# Get-AzResourceGroupDeployment
$template = Get-AzResourceGroupDeployment -ResourceGroupName $armRG | sort |  select -last 1 | Save-AzResourceGroupDeploymentTemplate -Force -Path "$env:OneDrive\SQL\Presentation\DSCArmBicep\SotonDPUG\02_arm\arm2bicep.json"

cls