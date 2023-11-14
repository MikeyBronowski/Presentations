<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|      
 

                                                                                        


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


# import dbatools module
Get-Module -Name dbatools -ListAvailable | Import-Module
# Install-Module -Name dbatools -Force




# install new instance

# prepare SQL Server image
$SqlSetupPath = "C:\SQL2022"
New-Item -Path $SqlSetupPath -ItemType Directory
$mountResult = Mount-DiskImage -ImagePath 'C:\Tools\SQLServer2022-x64-ENU-Dev.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination $SqlSetupPath -Recurse
Dismount-DiskImage -ImagePath 'C:\Tools\SQLServer2022-x64-ENU-Dev.iso'



# change default settings
Get-DbatoolsConfig -FullName "path.sqlserversetup"
Set-DbatoolsConfig -FullName "path.sqlserversetup" -Value $SqlSetupPath
# 2-3 min
Install-DbaInstance -Version 2022 -Feature Engine -InstanceName dbatools -Confirm:$false -Verbose


# get services status
Get-DbaService -ComputerName localhost -Type Agent, Engine | Format-Table

# start the services
Get-DbaService -ComputerName localhost -Type Agent, Engine | Start-DbaService


# find instances
Find-DbaInstance -ComputerName localhost -ScanType Browser
$instances = Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect

# connect to SQL Server instance
# 1 min
$server = Connect-DbaInstance -SqlInstance $instances
$server[0].Databases | Format-Table

# check if server is up to date

$instances | Test-DbaBuild -Latest | Format-Table
# Update-DbaBuildReference

$instances | Test-DbaBuild -MaxBehind 0CU | Format-Table
$instances | Test-DbaBuild -MaxBehind 3CU | Format-Table
$instances | Test-DbaBuild -MaxBehind 1SP | Format-Table


# update details
$instances | Get-DbaBuild | Format-Table
$kb = Get-DbaBuild -MajorVersion 2019 -CumulativeUpdate CU23
$kb2 = Get-DbaBuild -MajorVersion 2022 -CumulativeUpdate CU9
Get-DbaKbUpdate -Name $kb.KBLevel -Simple

# save updates to disk

Save-DbaKbUpdate -Name $kb.KBLevel -Path $SqlSetupPath
Save-DbaKbUpdate -Name $kb2.KBLevel -Path $SqlSetupPath


# update sql server
# 7 min all instances
$SqlSetupPath = "C:\SQL2022"
Update-DbaInstance -ComputerName localhost -Path $SqlSetupPath -WhatIf
Update-DbaInstance -ComputerName localhost -Path $SqlSetupPath -Confirm:$false -Verbose

$instances | Update-DbaInstance -Path $SqlSetupPath -WhatIf





# change parameters
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