<#


  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|  
                                                                                                
                                                                                                



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


Set-Location "C:\Tools\PowerDBA\01_choco\"

<#
Guide https://chocolatey.org/install#individual
#>
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco upgrade chocolatey
# C:\ProgramData\chocolatey\logs\chocolatey.log)

# find package
choco find notepadplusplus
choco find notepadplusplus -exact
choco find notepadplusplus -exact -allversions -limitoutput


# install package
choco install 7zip.install -y



# what's with "-y" ?
# allow by default
choco feature get --name=allowGlobalConfirmation
choco feature enable --name=allowGlobalConfirmation
choco feature get --name=allowGlobalConfirmation
# choco feature disable --name=allowGlobalConfirmation





# other options
choco feature list

# install specific version
choco find notepadplusplus -exact -allversions -limitoutput
choco install notepadplusplus --version=8.1.0

# run the app
notepad++

# see outdated packages
choco outdated


# upgrade all outdated packages
choco upgrade notepadplusplus
notepad++




# installing older version
choco install notepadplusplus --version=8.1.0

# installing older version - requred switch
choco install notepadplusplus --version=8.1.0 --allow-downgrade
notepad++

# removing package
choco uninstall notepadplusplus




# files downloaded by choco
choco install sql-server-management-studio

# ... or stored locally
choco install sql-server-management-studio --params "'/SSMSExePath:c:\Tools\SSMS-Setup-ENU.exe'"



###### choco find ssms -> old and deprecated package
###### choco find ssms -exact
###### choco find ssms -exact -allversions -limitoutput

# and even SQL Server
# https://community.chocolatey.org/packages/sql-server-2019
Set-Location C:\Tools\
Test-Path C:\Tools\SQLServer2022-x64-ENU-Dev.iso

choco install sql-server-2022 --params="/IsoPath:C:\Tools\SQLServer2022-x64-ENU-Dev.iso /INSTANCENAME:choco22" -y
choco install sql-server-2019 --params="/IsoPath:C:\Tools\SQLServer2019-x64-ENU-Dev.iso /INSTANCENAME:choco19" -y




# sample list you can install 

choco install sql-server-management-studio
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






