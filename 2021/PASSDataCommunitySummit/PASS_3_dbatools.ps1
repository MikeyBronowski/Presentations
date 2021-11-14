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
                                                                                                         


 
                                                                   
██████╗ ██████╗  █████╗ ████████╗ ██████╗  ██████╗ ██╗     ███████╗
██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
██║  ██║██████╔╝███████║   ██║   ██║   ██║██║   ██║██║     ███████╗
██║  ██║██╔══██╗██╔══██║   ██║   ██║   ██║██║   ██║██║     ╚════██║
██████╔╝██████╔╝██║  ██║   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                                                   

#> 

# install dbatools
Install-Module -Name dbatools -Force
# choco install dbatools

(Get-Command -Module dbatools).Count



# setup SQL instance names
$s1 = 'localhost\choco'
$s2 = 'localhost\dsc'
$s3 = 'localhost'
$sn = $s1, $s2, $s3

# make sure services are running.
Start-DbaService -ComputerName localhost -Type Agent, Engine


# connect to the instance
$sql = Connect-DbaInstance -SqlInstance $s1
$sql | select *

# navigate through SMO (SQL Server Management Objects)

# examples

$sql.VersionString
$sql.Logins['sa'].IsDisabled
$sql.Databases['msdb'].Tables['backupset'].Columns.Name


# test if your build is the latest
Test-DbaBuild -SqlInstance $sn -Latest | select SqlInstance, BuildLevel, BuildTarget, Compliant | Format-Table

# update your instances
Update-DbaInstance -ComputerName $env:COMPUTERNAME -InstanceName MSSQLSERVER -Download -Path 'C:\SQL2019\' -Confirm:$false -Verbose


# create multiple databases on multiple databases

$maindb = 'PASS'
$databases = 'Mikey',$maindb

$dbParams = @{
    Name = $databases
    Owner = 'sa'
    RecoveryModel = 'Full'
    PrimaryFileGrowth = 111
    LogGrowth = 119
}

$newdbs = New-DbaDatabase @dbParams -SqlInstance $sn


# get the databases
Get-DbaDatabase -SqlInstance $sn -ExcludeSystem | Format-Table

# get the files
Get-DbaDbFile -SqlInstance $s1 -Database $maindb | select SqlInstance, LogicalName, NextGrowthEventSize

# new table
$colParams = @{
    Name      = 'column'
    Type      = 'varchar'
    MaxLength = 128
    Nullable  = $true
}
New-DbaDbTable -SqlInstance $s1 -Database $maindb -Name NewTable -ColumnMap $colParams

# copy data between tables
# new table
$copyParams = @{
    SqlInstance         = $s1
    Database            = 'master'
    View                = 'sys.databases'
    Destination         = $s1
    DestinationDatabase = $maindb
    DestinationTable    = 'NewTable'
    Query               = 'select name from sys.databases'
}
Copy-DbaDbTableData @copyParams
Copy-DbaDbTableData -SqlInstance $s1 -Database master -View 'sys.databases' -DestinationDatabase $maindb -DestinationTable AutoCreate -AutoCreateTable

# run queries against SQL Server
Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "select * from NewTable;" | ft







# dbatools are constantly growing with new functions

# new synonym
$newSynonyms = New-DbaDbSynonym -SqlInstance $s1 -Database $maindb -Synonym synonym01 -BaseDatabase master -BaseSchema sys -BaseObject databases
Get-DbaDbSynonym -SqlInstance $s1 -Database $maindb -Synonym synonym01

Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "select * from synonym01;" | ft

# manage DbMail
$mailAcct = New-DbaDbMailAccount -SqlInstance $s1 -Account MailAccount -EmailAddress mikey@passsummit
$mailProf = New-DbaDbMailProfile -SqlInstance $s1 -Profile MailProfile -MailAccountName MailAccount

Get-DbaDbMailAccount -SqlInstance $s1 -Account MailAccount
Get-DbaDbMailProfile -SqlInstance $s1 -Profile MailProfile

Get-DbaDbMailAccount -SqlInstance $s1 -Account MailAccount | Remove-DbaDbMailAccount -Confirm:$false
Get-DbaDbMailProfile -SqlInstance $s1 -Profile MailProfile | Remove-DbaDbMailProfile -Confirm:$false







# manage logins and users
$securePass = ('<YourStrong@Passw0rd>' | ConvertTo-SecureString -asPlainText -Force)
$credential = New-Object System.Management.Automation.PSCredential ('sa', $securePass)

# add login
New-DbaLogin -SqlInstance $sn -Login "$env:USERDOMAIN\$env:USERNAME"
Add-DbaServerRoleMember -SqlInstance $sn -Login "$env:USERDOMAIN\$env:USERNAME" -ServerRole sysadmin -Confirm:$false

# new login
New-DbaLogin -SqlInstance $s1, $s2 -Login CustomLogin -SecurePassword $securePass -Force
Get-DbaLogin -SqlInstance $s1, $s2 -ExcludeSystemLogin| select * | ogv
Remove-DbaLogin -SqlInstance $s1, $s2 -Login 'BUILTIN\ADMINISTRATORS' -Confirm:$false


# oops...
Get-DbaLogin -SqlInstance $s1, $s2 -ExcludeSystemLogin| select * | ogv


# reset access using SA
Reset-DbaAdmin -SqlInstance $s2 -SecurePassword $securePass -Confirm:$false

# add DBA login to sysadmin using SA credentials
New-DbaLogin -SqlInstance $s2 "$env:USERDOMAIN\$env:USERNAME" -SqlCredential $credential
Add-DbaServerRoleMember -SqlInstance $s2 -Login "$env:USERDOMAIN\$env:USERNAME" -ServerRole sysadmin -Confirm:$false -SqlCredential $credential

# disable SA again
Set-DbaLogin -SqlInstance $s2 -Login sa -Disable

# test connection
Connect-DbaInstance -SqlInstance $s2






# new user
New-DbaDbUser -SqlInstance $s1, $s2 -Database $maindb -Username CustomUser -Login CustomLogin

# new app user
New-DbaLogin -SqlInstance $s1 -Login App01 -SecurePassword $securePass -Force
New-DbaDbUser -SqlInstance $s1 -Database $maindb -Username App01 -Login App01

# new role
New-DbaDbRole -SqlInstance $s1 -Database $maindb -Role CustomRole
Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "GRANT EXECUTE TO CustomRole"

# add user to the role
Add-DbaDbRoleMember -SqlInstance $s1 -Database $maindb -Role CustomRole, db_datareader -User CustomUser -Confirm:$false

# get permission
Get-DbaUserPermission -SqlInstance $s1 -Database $maindb -ExcludeSystemDatabase | Where {$_.Member -eq 'CustomUser'} | FT

# export permission
$permissionExport = Export-DbaUser -SqlInstance $s1 -Database $maindb -User CustomUser -FilePath CustomUser.txt
ii $permissionExport



# new database owner
New-DbaLogin -SqlInstance $s1, $s2 -Login CustomDbOwner -SecurePassword $securePass -Force
Set-DbaDbOwner -SqlInstance $s1 -Database $maindb -TargetLogin CustomDbOwner

Get-DbaDatabase -SqlInstance $s1, $s2 -Database $maindb -ExcludeSystem |select SqlInstance, Name, Owner | ft







# install sp_WhoIsActive by Adam Machanic
Install-DbaWhoIsActive -SqlInstance $s1 -Database $maindb
Invoke-DbaWhoIsActive -SqlInstance $s1 -Database $maindb -ShowSystemSpids | Format-Table

# or FRK by Brent Ozar
Install-DbaFirstResponderKit -SqlInstance $s1 -Database $maindb -OnlyScript sp_BlitzFirst.sql
Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "EXEC sp_BlitzFirst" | Format-Table


# or diagnostic queries by Glenn Berry
Invoke-DbaDiagnosticQuery -SqlInstance $s1, $s3 -UseSelectionHelper


# or monitoring by Marcin Gmiński
#Install-DbaSqlWatch -SqlInstance $s1 -WhatIf
start http://sqlwatch.io



# or maintenance solution by Ola Hallengren
Install-DbaMaintenanceSolution -SqlInstance $s1 -Database $maindb -InstallJobs


# let's start the job
Get-DbaAgentJob -SqlInstance $s1 | ft
$jobsStarted = Get-DbaAgentJob -SqlInstance $s1 | Start-DbaAgentJob


# get the job history
Get-DbaAgentJobHistory -SqlInstance $s1 | FT


# get the backup history
Get-DbaDbBackupHistory -SqlInstance $s1







# database backup
Backup-DbaDatabase -SqlInstance $s1 -Database $maindb -FilePath DB.BAK -Type Full

docker cp sql1:/var/opt/mssql/data/DB.BAK c:\temp
docker cp c:\temp\DB.BAK sql2:/var/opt/mssql/data/

# database restore 
Restore-DbaDatabase -SqlInstance $s2 -DatabaseName $maindb  -WithReplace -Path  "/var/opt/mssql/data/DB.BAK" -DestinationFilePrefix pre # -OutputScriptOnly

Copy-DbaDatabase -Source $s1 -Destination $s2 -Database $maindb -BackupRestore -WithReplace -SharedPath C:\SQL2019

# orphaned users
# report
Get-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft

# attempt to repair that
Repair-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft

# fixing by adding login
New-DbaLogin -SqlInstance $s2 -Login App01 -SecurePassword $securePass -Force
Repair-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft


# copy the login with the SID from the source server
Copy-DbaLogin -Source $s1 -Destination $s2 -Login CustomLogin

# copy the login - force
Copy-DbaLogin -Source $s1 -Destination $s2 -Login CustomLogin -Force

# report
Get-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft





# SQL Server config

# get
Get-DbaSpConfigure -SqlInstance  $s1 | ft

# export
Export-DbaSpConfigure -SqlInstance $s1 -FilePath SQLConfig.txt | ii

# set
Set-DbaSpConfigure -SqlInstance $s1 -Name 'backup checksum default' -Value 1
Get-DbaSpConfigure -SqlInstance  $sn -Name 'backup checksum default' | ft

# import from the server
Import-DbaSpConfigure -Source $s1 -Destination $s2

# import from the file
Import-DbaSpConfigure -SqlInstance $s1 -Path .\SQLConfig.txt







# testing SQL server
Test-DbaBuild -SqlInstance $sn -Latest | ft

Test-DbaDbOwner -SqlInstance $sn -TargetLogin CustomDbOwner| ft

Test-DbaMaxDop -SqlInstance $sn | ft
Set-DbaMaxDop -SqlInstance $s1 -MaxDop 1
Test-DbaMaxMemory -SqlInstance $sn| ft
Set-DbaMaxMemory -SqlInstance $s1, $s2 -Max 683

# clear screen
Set-Location C:\PASS2021
cls