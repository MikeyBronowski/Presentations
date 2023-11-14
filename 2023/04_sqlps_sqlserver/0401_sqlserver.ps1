<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|        




 .d8888b.   .d88888b.  888      8888888b.   .d8888b.  
d88P  Y88b d88P" "Y88b 888      888   Y88b d88P  Y88b 
Y88b.      888     888 888      888    888 Y88b.      
 "Y888b.   888     888 888      888   d88P  "Y888b.   
    "Y88b. 888     888 888      8888888P"      "Y88b. 
      "888 888 Y8b 888 888      888              "888 
Y88b  d88P Y88b.Y8b88P 888      888        Y88b  d88P 
 "Y8888P"   "Y888888"  88888888 888         "Y8888P"  
                  Y8b                                 
                                                      

                  888                                                     
                  888                                                     
                  888                                                     
.d8888b   .d88888 888 .d8888b   .d88b.  888d888 888  888  .d88b.  888d888 
88K      d88" 888 888 88K      d8P  Y8b 888P"   888  888 d8P  Y8b 888P"   
"Y8888b. 888  888 888 "Y8888b. 88888888 888     Y88  88P 88888888 888     
     X88 Y88b 888 888      X88 Y8b.     888      Y8bd8P  Y8b.     888     
 88888P'  "Y88888 888  88888P'  "Y8888  888       Y88P    "Y8888  888     
              888                                                         
              888                                                         
              888                                                         
                            
                                    
   

@MikeyBronowski


#> 

Set-Location C:\Tools\SQLDay2022\04_sqlps_sqlserver

# SQLPS
Get-module SQLPS -ListAvailable
(Get-Command -Module SQLPS).Count #  49
Get-Command -Module SQLPS | Format-Table




# sqlserver
Install-Module sqlserver
<#
    PackageManagement\Install-Package : The following commands are already available on this system:'Decode-SqlName,Encode-SqlName,
    SQLSERVER:,Add-SqlAvailabilityDatabase.......
#>

Install-Module sqlserver -AllowClobber

(Get-Command -Module sqlserver).Count #  65
Get-Command -Module sqlserver | Format-Table


# kilka przykladow
# podlaczenie sie do serwera SQL
$sqlinstance = Get-SqlInstance -ServerInstance localhost
$sqlinstance | Select-Object *

# tworz kopii zapasowych
Get-ChildItem SQLSERVER:\SQL\localhost\default\Databases -Force | Where-Object {$_.Name -ne 'Tempdb'} | Backup-SqlDatabase -verbose

# odtworz kopie zapasowa$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("MSDBData", "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\msdb_copy_Data.mdf")
$RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("MSDBLog", "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\msdb_copy_Log.ldf")
Restore-SqlDatabase -ServerInstance localhost -Database msdb_copy -BackupFile "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\msdb.bak" -RelocateFile @($RelocateData,$RelocateLog)
Get-SqlDatabase  -ServerInstance localhost | Format-Table

# pobierz informacje o agencie SQL
Get-SqlAgent -ServerInstance localhost\choco
Get-SqlAgentJob -ServerInstance localhost\choco

# pobierz loginy
Get-SqlLogin -ServerInstance localhost

# przegladaj dziennik bledow
Get-SqlErrorlog  -ServerInstance localhost | Format-Table

# czytaj dane z tabel/widokow
Read-SqlTableData -ServerInstance localhost -DatabaseName msdb -SchemaName dbo -TableName sysjobs -TopN 3 | Format-Table
Read-SqlViewData -ServerInstance localhost -DatabaseName master -SchemaName sys -ViewName databases -TopN 3 | Format-Table

# uruchom notatnik azure data studio 
Invoke-SqlNotebook -ServerInstance localhost -Database msdb -InputFile .\0402_notebook.ipynb








