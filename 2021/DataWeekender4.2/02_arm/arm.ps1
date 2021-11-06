<#
https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview
#>

# change directory
cls
Set-Location ..\02_arm

# export ResourceGroupName JSON
$armRG = 'dataweekender-backup'
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
$template = Get-AzResourceGroupDeployment -ResourceGroupName $armRG | sort |  select -last 1 | Save-AzResourceGroupDeploymentTemplate -Force -Path "C:\Users\micha\OneDrive\SQL\Presentation\Dataweekender\2021_4.2\02_arm\arm2bicep.json"

cls