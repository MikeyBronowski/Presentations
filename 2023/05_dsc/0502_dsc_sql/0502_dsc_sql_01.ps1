<#
  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|        
 
                           
           


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

@MikeyBronowski                                                                                                                                                                                                         
                                                                                                      
#>

### DSC w wersji dla PowerShell 5.1.x
### dsc for PS 5.1.x
$PSVersionTable


# install SqlServer resources for DSC
Install-Module -Name SqlServerDsc -Force
Get-Module -Name SqlServerDsc -ListAvailable
Import-Module -Name SqlServerDsc -Force

# create image of SQL Server
New-Item -Path C:\SQL2022 -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\Tools\SQLServer2022-x64-ENU-Dev.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination C:\SQL2022\ -Recurse
Dismount-DiskImage -ImagePath 'C:\Tools\SQLServer2022-x64-ENU-Dev.iso'



# load configuration functions
Set-Location c:\tools\PowerDBA\05_dsc\0502_dsc_sql\
. .\0502_dsc_sql_01.config


# compile configuration to create MOF file
SQLInstall -ComputerName localhost


# deploy config
Start-DscConfiguration -Path .\SQLInstall -Wait -Force -Verbose


# check results
Get-Service -Name *MSSQL*


# test config
Test-DscConfiguration -Path .\SQLInstall | Select-Object -Property *
cls





# Check if the SqlServerDsc module is installed
if (!(Get-Module -ListAvailable -Name SqlServerDsc)) {
  # If the module is not installed, install it
  Install-Module -Name SqlServerDsc -Force
}

# Import the SqlServerDsc module
Import-Module -Name SqlServerDsc -Force

import-module PSDesiredStateConfiguration