<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|                      



 .d8888b.   .d88888b.  888            8888888b.   .d8888b.  8888888b.                            d8b      888                  
d88P  Y88b d88P" "Y88b 888            888   Y88b d88P  Y88b 888   Y88b                           Y8P      888                  
Y88b.      888     888 888            888    888 Y88b.      888    888                                    888                  
 "Y888b.   888     888 888            888   d88P  "Y888b.   888   d88P 888d888  .d88b.  888  888 888  .d88888  .d88b.  888d888 
    "Y88b. 888     888 888            8888888P"      "Y88b. 8888888P"  888P"   d88""88b 888  888 888 d88" 888 d8P  Y8b 888P"   
      "888 888 Y8b 888 888            888              "888 888        888     888  888 Y88  88P 888 888  888 88888888 888     
Y88b  d88P Y88b.Y8b88P 888            888        Y88b  d88P 888        888     Y88..88P  Y8bd8P  888 Y88b 888 Y8b.     888     
 "Y8888P"   "Y888888"  88888888       888         "Y8888P"  888        888      "Y88P"    Y88P   888  "Y88888  "Y8888  888     
                  Y8b                                                                                                          
                                                                                                                               
                                                                                                                                  

@MikeyBronowski


#> 

# PowerShell SQL Server Provider
# https://docs.microsoft.com/en-us/sql/powershell/sql-server-powershell-provider?view=sql-server-ver15
# https://docs.microsoft.com/en-us/sql/powershell/navigate-sql-server-powershell-paths?view=sql-server-ver15

Get-Module sqlps -ListAvailable | Import-Module

(Get-PSDrive -Name SQLSERVER).Root

# wejdźmy do katalogu serwera SQL
Set-Location (Get-PSDrive -Name SQLSERVER).Root

Get-ChildItem


# zobacz bazy
Get-ChildItem SQLSERVER:\SQL\localhost\default\Databases

# zobacz bazy systemowe
Get-ChildItem SQLSERVER:\SQL\localhost\default\Databases -Force
Pop-Location


# tworzenie nowego dysku 
New-PSDrive -Name powerdba -Root SQLSERVER:\SQL\localhost\default\Databases\sqlday\ -PSProvider sqlserver
Set-Location powerdba:\