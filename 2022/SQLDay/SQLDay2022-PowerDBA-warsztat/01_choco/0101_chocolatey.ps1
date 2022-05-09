<#

  ____   ___  _     ____              ____   ___ ____  ____  
 / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
 \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
  ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
 |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                |___/                        


 .d8888b.  888                                888          888                     
 d88P  Y88b 888                                888          888                     
 888    888 888                                888          888                     
 888        88888b.   .d88b.   .d8888b .d88b.  888  8888b.  888888 .d88b.  888  888 
 888        888 "88b d88""88b d88P"   d88""88b 888     "88b 888   d8P  Y8b 888  888 
 888    888 888  888 888  888 888     888  888 888 .d888888 888   88888888 888  888 
 Y88b  d88P 888  888 Y88..88P Y88b.   Y88..88P 888 888  888 Y88b. Y8b.     Y88b 888 
  "Y8888P"  888  888  "Y88P"   "Y8888P "Y88P"  888 "Y888888  "Y888 "Y8888   "Y88888 
                                                                                888 
                                                                           Y8b d88P 
                                                                            "Y88P"  


@MikeyBronowski


#> 


Set-Location "C:\Tools\SQLDay2022\01_choco\"

<#
Instrukcja na https://chocolatey.org/install#individual
#>
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco upgrade chocolatey

# szukaj pakietów 
choco find ssms
choco find ssms -exact -allversions -limitoutput

# szukaj pakietów zainstalowanych lokalnie
choco find --localonly

# przełączniki można łączyć
choco find ssms -lar


# instalowanie pakietów
# https://docs.microsoft.com/en-us/sysinternals/
choco install sysinternals -y



# o co chodzi z tym -y ?
# akceptacja domyślna
choco feature enable -n allowGlobalConfirmation

# inne opcje
choco feature list

# instalacja wybranej wersji aplikacji
choco find notepadplusplus -exact -allversions -limitoutput
choco install notepadplusplus --version=7.9.5

# uruchomienie aplikacji
notepad++

# zobacz niekatualne wersje
choco outdated

# aktualizacja do najnowszej dostępnej wersji
choco upgrade notepadplusplus
notepad++

# instalacja wybranej wcześniejszej wersji aplikacji
choco install notepadplusplus --version=7.9.5

# instalacja wybranej wcześniejszej wersji aplikacji - wymagany przełacznik
choco install notepadplusplus --version=7.9.5 --allow-downgrade
notepad++

# usuniecie pakietu
choco uninstall notepadplusplus




# pliki ściągane podczas instalacji
choco install sql-server-management-studio

# ... lub używamy pliku z dysku
choco install sql-server-management-studio --params "'/SSMSExePath:c:\Tools\SSMS-Setup-ENU.exe'"

###### choco install ssms -> stary, wycofany pakiet


# a nawet SQL Server
# https://community.chocolatey.org/packages/sql-server-2019
Set-Location C:\Tools\
Test-Path C:\Tools\en_sql_server_2019_developer_x64_dvd_baea4195.iso
choco install sql-server-2019 --params="/IsoPath:C:\Tools\en_sql_server_2019_developer_x64_dvd_baea4195.iso /INSTANCENAME:choco"




# przykladowa lista aplikacji, które można zainstalować


choco install sql-server-management-studio
choco install sqlsentryplanexplorer
choco install sqltoolbelt

choco install azure-data-studio
choco install azuredatastudio-powershell

choco install powerbi

choco install powershell-core
choco install vscode
choco install vscode-powershell

choco install docker-desktop

choco install treesizefree
choco install slack
choco install bitwarden
choco install bicep
choco install rdcman

choco install spotify
choco install camtasia
choco install snagit






