#advanced
Clear-Host

# create a new lab(s) in Hyper-V


[int]$Number = 1104
# [switch] $SQL = $true
[switch] $SQL = $false
$labName = "PowerDBA$number"
$labHost = $LabName

$vmPath = "C:\AutomatedLab-VMs"
$labSources = "C:\LabSources"
$newLab = @{
    DefaultVirtualizationEngine = "HyperV"
    VmPath                      = $vmPath
}
New-LabDefinition @newLab -Name $labName 

#Set installation user
Set-LabInstallationCredential -Username MikeyBronowski -Password PowerDBA

# new definition
#Add-LabIsoImageDefinition -Name SQLServer2019 -Path "$labSources\ISOs\en_sql_server_2019_developer_x64_dvd_baea4195.iso"
Add-LabIsoImageDefinition -Name SQLServer2022 -Path "$labSources\ISOs\SQLServer2022-x64-ENU-Dev.iso"
# Get-LabIsoImageDefinition $labSources

# setup network
if (!$(Get-LabVirtualNetworkDefinition -Name "Default Switch")) {

    $newNetwork = @{
    Name = "Default Switch"
    HyperVProperties = @{ SwitchType = "External"; AdapterName = "Wi-Fi" }
    }
    
    Add-LabVirtualNetworkDefinition @newNetwork
}
$(Get-LabDefinition).VirtualNetworks | Format-Table


$role = Get-LabMachineRoleDefinition -Role SQLServer2022 -Properties @{Features = 'SQLEngine'}

# setup vm
$vmName = $labHost
$newVM = @{
    OperatingSystem = $(Get-LabAvailableOperatingSystem | Where-Object {$_.ImageIndex -eq 4}).OperatingSystemName
    Memory          = "6GB"
    Network         = "Default Switch"
    Roles          = $role
    ToolsPath       = "$labSources\Tools"
}

Add-LabMachineDefinition @newVM -Name $vmName
# Remove-LabMachineDefinition -Name $vmName

# 2.5-5 minutes
Install-Lab -NoValidation # -Verbose

# restart after build
Restart-LabVM -ComputerName "$vmName"

# local installers on the guest VM
Install-LabSoftwarePackage -ComputerName $vmName -LocalPath "C:\Tools\PowerShell-7.3.9-win-x64.msi" -CommandLine '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1' -AsJob
Install-LabSoftwarePackage -ComputerName $vmName -LocalPath "C:\Tools\SSMS-Setup-ENU.exe" -CommandLine '/Install /Passive' -AsJob

Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install VSCode' -ScriptBlock { Start-Process -FilePath 'C:\Tools\VSCodeSetup-x64-1.84.0-insider.exe' -Args "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait;  } -PassThru
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install NuGet' -ScriptBlock { Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue } -PassThru
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install choco' -ScriptBlock { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) } -PassThru -AsJob
# Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install oh-my-posh' -ScriptBlock { Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1')) } -PassThru -AsJob

# this step is for chocolatey - to update environmental paths
if ($(Get-Job | where {$_.Location -eq $vmName -and $_.State -eq 'Running'}).Count -eq 0){
    Restart-LabVM -ComputerName $vmName
} else {Write-Host "There are still jobs in progress!!!" -BackgroundColor Magenta -ForegroundColor Yellow}

Invoke-LabCommand -ComputerName $vmName -ActivityName 'Set TLS12' -ScriptBlock { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } -PassThru
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Set-PSRepository' -ScriptBlock { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted } -PassThru
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install PS Modules' -ScriptBlock { pwsh {
    
    Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction SilentlyContinue;
    Install-Module -Name dbatools.library -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name dbatools -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name dbachecks -AllowPrerelease -Force -ErrorAction SilentlyContinue;
    Install-Module -Name importexcel -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name az.sql -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name az -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name PSDesiredStateConfiguration -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name xPSDesiredStateConfiguration -Repository PSGallery -ErrorAction SilentlyContinue;
}
} -PassThru


# Get-Module -Name Pester, dbatools, dbatools.library, dbachecks, importexcel, az, az.sql, PSDesiredStateConfiguration, xPSDesiredStateConfiguration -ListAvailable

Invoke-LabCommand -ComputerName $vmName -ActivityName 'PS script' -ScriptBlock { pwsh {"C:\Tools\ps1.ps1"} } -PassThru

Copy-LabFileItem -Path "C:\LabSources\ISOs\SQLServer2019-x64-ENU-Dev.iso" -ComputerName $vmName -DestinationFolderPath "C:\Tools\"
Copy-LabFileItem -Path "C:\LabSources\ISOs\SQLServer2022-x64-ENU-Dev.iso" -ComputerName $vmName -DestinationFolderPath "C:\Tools\"

Checkpoint-LabVM -ComputerName $vmName -SnapshotName 'FirstSnapshot'

Restart-LabVM -ComputerName $vmName

#### #### 
#### ####


<#
Import-Lab -Name $labName
Start-LabVM -ComputerName $vmName
#>

# install software via chocolatey
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install vscode-powershell' -ScriptBlock { choco install vscode-powershell, vscode-gitlens -y  } -PassThru -AsJob
Invoke-LabCommand -ComputerName $vmName -ActivityName 'Install git' -ScriptBlock { choco install git -y  } -PassThru -AsJob


# Remove-Lab -name moarlionesses