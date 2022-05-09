<#
  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
           


8888888b.                    d8b                       888  .d8888b.  888             888             
888  "Y88b                   Y8P                       888 d88P  Y88b 888             888             
888    888                                             888 Y88b.      888             888             
888    888  .d88b.  .d8888b  888 888d888  .d88b.   .d88888  "Y888b.   888888  8888b.  888888  .d88b.  
888    888 d8P  Y8b 88K      888 888P"   d8P  Y8b d88" 888     "Y88b. 888        "88b 888    d8P  Y8b 
888    888 88888888 "Y8888b. 888 888     88888888 888  888       "888 888    .d888888 888    88888888 
888  .d88P Y8b.          X88 888 888     Y8b.     Y88b 888 Y88b  d88P Y88b.  888  888 Y88b.  Y8b.     
8888888P"   "Y8888   88888P' 888 888      "Y8888   "Y88888  "Y8888P"   "Y888 "Y888888  "Y888  "Y8888  

 .d8888b.                     .d888 d8b                                    888    d8b                   
d88P  Y88b                   d88P"  Y8P                                    888    Y8P                   
888    888                   888                                           888                          
888         .d88b.  88888b.  888888 888  .d88b.  888  888 888d888  8888b.  888888 888  .d88b.  88888b.  
888        d88""88b 888 "88b 888    888 d88P"88b 888  888 888P"       "88b 888    888 d88""88b 888 "88b 
888    888 888  888 888  888 888    888 888  888 888  888 888     .d888888 888    888 888  888 888  888 
Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 Y88b 888 888     888  888 Y88b.  888 Y88..88P 888  888 
 "Y8888P"   "Y88P"  888  888 888    888  "Y88888  "Y88888 888     "Y888888  "Y888 888  "Y88P"  888  888 
                                             888                                                        
                                        Y8b d88P                                                        
                                         "Y88P"                                                         

                                                                                                      
                                                                                                      
#>

### DSC w wersji dla PowerShell 7.2.x
### domyslna instancja
### dodatkowa instancja - DSC
### dodatkowa instancja - DSCPS7
$PSVersionTable
pwsh

Set-Location c:\tools\SQLDay2022\05_dsc\0501_dsc_dir\

<# to juz zrobione
        # instaluj zasoby SqlServer dla DSC
        Install-Module -Name SqlServerDsc -Force
        Get-Module -Name SqlServerDsc -ListAvailable
        Import-Module -Name SqlServerDsc -Force

        # instaluj zasoby DSC
        Install-Module -Name 'PSDesiredStateConfiguration'
        Install-Module -Name 'xPSDesiredStateConfiguration'
        Install-Module -Name 'StorageDsc'
#>

# instaluj zasoby Storage dla DSC
Install-Module -Name StorageDsc
Import-Module -Name StorageDsc

Import-Module xPSDesiredStateConfiguration
Get-Module xPSDesiredStateConfiguration


# wczytaj funkcje konfiguracji
Set-Location c:\tools\SQLDay2022\05_dsc\0503_dsc_sql_download
. .\0503_dsc_sql_download.config.ps1


# kompiluj konfiguracje by stowrzyc plik MOF
SQLInstall -ComputerName localhost



# wdroz konfiguracje
Start-DscConfiguration -Path .\SQLInstall -Wait -Force -Verbose
<#
    InvalidOperation: The PowerShell DSC resource DSC_xRemoteFile from module <xPSDesiredStateConfiguration,9.1.0> does not exist at the PowerShell module path 
    nor is it registered as a WMI DSC resource.

    # zmienne srodowiskowe
    [Environment]::GetEnvironmentVariable("PSModulePath", "Machine").Split(";") | ogv
    (Get-Module -Name xPSDesiredStateConfiguration).Path
    C:\Users\MikeyBronowski\Documents\PowerShell\Modules
    $env:PSModulePath += ';C:\Users\MikeyBronowski\Documents\PowerShell\Modules'
#>




# sprawdz efekty
Get-Service -Name *MSSQL*

# testuj stan konfiguracji
Test-DscConfiguration -Path .\SQLInstall | Select-Object -Property *
(Test-DscConfiguration -Path .\SQLInstall | Select-Object -Property *).resourcesindesiredstate | Format-Table
cls


