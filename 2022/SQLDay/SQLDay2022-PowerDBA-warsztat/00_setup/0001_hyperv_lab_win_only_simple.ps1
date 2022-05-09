Build-MBLab -Number 51618 -SQL

function Build-MBLab {
Param (
    [int]$Number = 123,
    [switch] $SQL
    )
$labName = "PowerDBA$number"
$labHost = ($LabName)

Clear-LabCache
<#
try {
    Remove-Lab -Name $labName -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
    Write-Host -Message ""
    continue
}
#>


#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV 


#Define the network range
Add-LabVirtualNetworkDefinition -Name 'Default Switch' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Wi-Fi' }

#Set installation user
Set-LabInstallationCredential -Username MikeyBronowski -Password PowerDBA

#Read all ISOs in the LabSources folder and add the SQL 2019 ISO
Add-LabIsoImageDefinition -Name SQLServer2019 -Path "$labSources\ISOs\en_sql_server_2019_developer_x64_dvd_baea4195.iso"

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:OperatingSystem' 	= $(Get-LabAvailableOperatingSystem | Where-Object { $_.ImageIndex -eq 2 } |  Select-Object -first 1).OperatingSystemName
    'Add-LabMachineDefinition:ToolsPath'		= "$labSources\Tools"
}

if ($SQL) {
    $labHost = "s"+$labHost
    $role = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{Features = 'SQLEngine'}
    Add-LabMachineDefinition -Name $labHost -Memory 6GB -Network 'Default Switch' -Roles $role
}
else {
    Add-LabMachineDefinition -Name $labHost -Memory 6GB -Network 'Default Switch'
}




# Add-LabMachineDefinition -Name Win10 -Memory 4GB -OperatingSystem $(Get-LabAvailableOperatingSystem | where{ $_.ImageIndex -eq 2 } |  select -first 1).OperatingSystemName -Network 'Default Switch'

# install lab
Install-Lab

Install-LabSoftwarePackage -ComputerName $labHost -LocalPath "C:\Tools\PowerShell-7.2.3-win-x64.msi" -CommandLine '/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1' -AsJob
Install-LabSoftwarePackage -ComputerName $labHost -LocalPath "C:\Tools\SSMS-Setup-ENU.exe" -CommandLine '/Install /Passive' -AsJob
# Install-LabSoftwarePackage -ComputerName $labHost -LocalPath "C:\Tools\VSCodeUserSetup-x64-1.66.2.exe" -CommandLine '/VERYSILENT /MERGETASKS=!runcode'

Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install VSCode' -ScriptBlock { Start-Process -FilePath 'C:\Tools\VSCodeUserSetup-x64-1.66.2.exe' -Args "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait;  } -PassThru
Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install NuGet' -ScriptBlock { Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue } -PassThru
Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install choco' -ScriptBlock { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) } -PassThru -AsJob
Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install oh-my-posh' -ScriptBlock { Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1')) } -PassThru -AsJob

Invoke-LabCommand -ComputerName $labHost -ActivityName 'Set TLS12' -ScriptBlock { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } -PassThru
Invoke-LabCommand -ComputerName $labHost -ActivityName 'Set-PSRepository' -ScriptBlock { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted } -PassThru
Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install PS Modules' -ScriptBlock { 
    Install-Module -Name Pester -RequiredVersion 4.10.1 -Force -SkipPublisherCheck -ErrorAction SilentlyContinue; 
    Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction SilentlyContinue;
    Install-Module -Name dbatools -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name dbachecks -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name importexcel -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name az.sql -Repository PSGallery -ErrorAction SilentlyContinue;
    Install-Module -Name az -Repository PSGallery -ErrorAction SilentlyContinue;
} -PassThru

Invoke-LabCommand -ComputerName $labHost -ActivityName 'PS script' -ScriptBlock { "C:\Tools\ps1.ps1" } -PassThru

# Invoke-LabCommand -ComputerName $labHost -ActivityName 'Install choco: vscode-powershell' -ScriptBlock { choco install vscode-powershell -y} -Retries 3 -RetryIntervalInSeconds 5 -AsJob

# create snapshot
Checkpoint-LabVM  -ComputerName $labHost -SnapshotName 'FirstSnapshot'

# restart VM to have a clean run before installing SQL
Restart-LabVM -ComputerName $labHost

# Get-Module -Name Pester, dbatools, dbachecks, importexcel -ListAvailable
# AutomatedLab
}
