<# 



  ____   _    ____ ____    ____        _           ____                                      _ _         
 |  _ \ / \  / ___/ ___|  |  _ \  __ _| |_ __ _   / ___|___  _ __ ___  _ __ ___  _   _ _ __ (_) |_ _   _ 
 | |_) / _ \ \___ \___ \  | | | |/ _` | __/ _` | | |   / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | |
 |  __/ ___ \ ___) |__) | | |_| | (_| | || (_| | | |__| (_) | | | | | | | | | | | |_| | | | | | |_| |_| |
 |_| /_/   \_\____/____/  |____/ \__,_|\__\__,_|  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, |
  ____                            _ _     ____   ___ ____  _                                       |___/ 
 / ___| _   _ _ __ ___  _ __ ___ (_) |_  |___ \ / _ \___ \/ |                                            
 \___ \| | | | '_ ` _ \| '_ ` _ \| | __|   __) | | | |__) | |                                            
  ___) | |_| | | | | | | | | | | | | |_   / __/| |_| / __/| |                                            
 |____/ \__,_|_| |_| |_|_| |_| |_|_|\__| |_____|\___/_____|_|                                            
                                                                                                         

 
                                                                   


███████╗ ██████╗ ██╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ ██████╗ ███████╗ ██████╗
██╔════╝██╔═══██╗██║     ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
███████╗██║   ██║██║     ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝██║  ██║███████╗██║     
╚════██║██║▄▄ ██║██║     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗██║  ██║╚════██║██║     
███████║╚██████╔╝███████╗███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║██████╔╝███████║╚██████╗
╚══════╝ ╚══▀▀═╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝
                                                                                                  
  
                                                                                    

                                                                   

#> 

# install module
Install-Module -Name SqlServerDsc -Force


# Quickstart
https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-with-powershell-desired-state-configuration


# prepare installation media
New-Item -Path C:\SQL2019 -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\PASS2021\SQLServer2019-x64-ENU-Dev.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination C:\SQL2019\ -Recurse
Dismount-DiskImage -ImagePath 'C:\PASS2021\SQLServer2019-x64-ENU-Dev.iso'


# Import the modules into the current session.


# Compile the configuration
Set-Location C:\PASS2021
notepad .\PASS_2_sqlserverdsc_config.ps1
. .\PASS_2_sqlserverdsc_config.ps1
SQLInstall

# check out the MOF file
notepad C:\PASS2021\SQLInstall\localhost.mof


# Deploy the configuration
Start-DscConfiguration -Path C:\PASS2021\SQLInstall -Wait -Force -Verbose


# Validate installation
Test-DscConfiguration


# Confirm the SQL server instances are installed
Get-Service -Name *SQL*


# clear screen
Set-Location C:\PASS2021
cls