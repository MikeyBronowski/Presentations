<#

  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
                                                                                        


     888 888               888                      888          
     888 888               888                      888          
     888 888               888                      888          
 .d88888 88888b.   8888b.  888888  .d88b.   .d88b.  888 .d8888b  
d88" 888 888 "88b     "88b 888    d88""88b d88""88b 888 88K      
888  888 888  888 .d888888 888    888  888 888  888 888 "Y8888b. 
Y88b 888 888 d88P 888  888 Y88b.  Y88..88P Y88..88P 888      X88 
 "Y88888 88888P"  "Y888888  "Y888  "Y88P"   "Y88P"  888  88888P' 
                                                                 
                                                                 
                                                                 

                                                     
                                                     
@MikeyBronowski                                                                                                                                                                                                  
                                                                                               
                                                                                        

#> 

Set-Location "C:\Tools\SQLDay2022\06_dbatools"


# zaimportuj modul dbatools
Get-Module -Name dbatools -ListAvailable | Import-Module
# Install-Module -Name dbatools -Force




# instaluj nowa instancje
# przygotuj obraz serwera SQL
$SqlSetupPath = "C:\SQL2019"
New-Item -Path $SqlSetupPath -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\Tools\en_sql_server_2019_developer_x64_dvd_baea4195.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination $SqlSetupPath -Recurse
Dismount-DiskImage -ImagePath 'C:\Tools\en_sql_server_2019_developer_x64_dvd_baea4195.iso'



# zmiana ustawien domyslnych
Get-DbatoolsConfig -FullName "path.sqlserversetup"
Set-DbatoolsConfig -FullName "path.sqlserversetup" -Value $SqlSetupPath
# 2-3 min
Install-DbaInstance -Version 2019 -Feature Engine -InstanceName dbatools -Confirm:$false -Verbose


# sprawdz status uslug
Get-DbaService -ComputerName localhost -Type Agent, Engine | Format-Table

# wystartuj uslugi status uslug
Get-DbaService -ComputerName localhost -Type Agent, Engine | Start-DbaService


# znajdz instancje
Find-DbaInstance -ComputerName localhost -ScanType Browser
$instances = Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect

# podlacz do instancji serwera SQL
# 1 min
$server = Connect-DbaInstance -SqlInstance $instances
$server[0].Databases | Format-Table

# sprawdzc czy serwer ma aktualna wersje
$instances | Test-DbaBuild -Latest | Format-Table
# Update-DbaBuildReference

$instances | Test-DbaBuild -MaxBehind 3CU | Format-Table
$instances | Test-DbaBuild -MaxBehind 1SP | Format-Table


# informacje o aktualizacjach
$instances | Get-DbaBuild | Format-Table
$kb = Get-DbaBuild -MajorVersion 2019 -CumulativeUpdate CU16
Get-DbaKbUpdate -Name $kb.KBLevel -Simple

# zapisz pliki instalacyjne na dysku
Save-DbaKbUpdate -Name $kb.KBLevel -Path $SqlSetupPath

# aktualizuj sql server 
# 7 minut wszystkie instancje
Update-DbaInstance -ComputerName localhost -Path $SqlSetupPath -WhatIf
Update-DbaInstance -ComputerName localhost -Path $SqlSetupPath -Confirm:$false -Verbose





# zmiana parametrow
$instances | Test-DbaMaxMemory | Format-Table
Set-DbaMaxMemory -SqlInstance $instances -Max 512

$instances | Test-DbaMaxDop | Format-Table
Test-DbaMaxDop -SqlInstance $instances | Format-Table -AutoSize
Set-DbaMaxDop -SqlInstance $instances -MaxDop 1
$instances | Get-DbaSpConfigure | Format-Table -AutoSize -Wrap
$instances | Get-DbaSpConfigure | Out-GridView
Set-DbaSpConfigure -SqlInstance 

$instances.Databases | Format-Table -AutoSize
$instances | Get-DbaDatabase | Format-Table -AutoSize -Wrap