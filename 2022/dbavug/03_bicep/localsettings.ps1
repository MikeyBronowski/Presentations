# change directory
cls
Set-Location ..\03_bicep

# fix TLS
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

# restart PowerShell session


# Install PowerShellGet
Install-PackageProvider -Name NuGet -Force
Install-Module PowershellGet -Force
Install-Module AZ -Force
Install-Module dbatools -Force

# install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


# install Azure CLI
choco install azure-cli -y
choco install microsoft-edge -y

# restart PowerShell session

$cert_url = "http://cacerts.digicert.com/DigiCertHighAssuranceTLSHybridECCSHA2562020CA1.crt"
$cert_file = New-TemporaryFile
Invoke-WebRequest -Uri $cert_url -UseBasicParsing -OutFile $cert_file.FullName
Import-Certificate -FilePath $cert_file.FullName -CertStoreLocation Cert:\LocalMachine\Root

# install Bicep
az bicep install
az bicep version

az bicep decompile --file ..\02_arm\arm2bicep.json

# deploy bicep with DSC
az group create -n dataweekender -l uksouth
az deployment group create --resource-group dataweekender --template-file main.bicep

cls