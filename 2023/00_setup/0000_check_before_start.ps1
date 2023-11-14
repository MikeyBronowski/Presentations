# update AutomatedLab
Update-Module automatedlab -AllowPrerelease
Get-Module automatedlab  -ListAvailable
# https://www.powershellgallery.com/packages/AutomatedLab

# install VS Code
Start-Process -FilePath 'C:\Tools\VSCodeUserSetup-x64-1.66.2.exe' -Args "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait; 

# install VS Code PowerShell extension
choco install vscode-powershell -y

# install power bi desktop
choco install powerbi -y --ignore-checksums


# install Oh-My-Posh
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))


# install fonts 
Invoke-Item "C:\Tools\_font\Caskaydia Cove Nerd Font Complete Mono Windows Compatible.ttf"


# setup $profile file
New-Item -Path C:\Users\MikeyBronowski\Documents\PowerShell\ -ItemType Directory
notepad $profile
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/montys.omp.json' | Invoke-Expression
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cert.omp.json' | Invoke-Expression


restart VS Code !!!!


Preferences: Open Settings (UI)
Consolas, 'Courier New', monospace, CaskaydiaCove NF


<# 
    CTRL+K, CTRL+T
    Preferences: Color Theme
#>


# reload profile
. $profile

