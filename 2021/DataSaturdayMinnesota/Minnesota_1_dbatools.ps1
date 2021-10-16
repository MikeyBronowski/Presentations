<# 


   _____            _              _____           _                        _                   
 |  __ \          | |            / ____|         | |                      | |                  
 | |  | |   __ _  | |_    __ _  | (___     __ _  | |_   _   _   _ __    __| |   __ _   _   _   
 | |  | |  / _` | | __|  / _` |  \___ \   / _` | | __| | | | | | '__|  / _` |  / _` | | | | |  
 | |__| | | (_| | | |_  | (_| |  ____) | | (_| | | |_  | |_| | | |    | (_| | | (_| | | |_| |  
 |_____/   \__,_|  \__|  \__,_| |_____/   \__,_|  \__|  \__,_| |_|     \__,_|  \__,_|  \__, |  
 |  \/  | (_)                                      | |                                  __/ |  
 | \  / |  _   _ __    _ __     ___   ___    ___   | |_    __ _                        |___/   
 | |\/| | | | | '_ \  | '_ \   / _ \ / __|  / _ \  | __|  / _` |                               
 | |  | | | | | | | | | | | | |  __/ \__ \ | (_) | | |_  | (_| |                               
 |_|  |_| |_| |_| |_| |_| |_|  \___| |___/  \___/   \__|  \__,_| 

 
                                                                   
██████╗ ██████╗  █████╗ ████████╗ ██████╗  ██████╗ ██╗     ███████╗
██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
██║  ██║██████╔╝███████║   ██║   ██║   ██║██║   ██║██║     ███████╗
██║  ██║██╔══██╗██╔══██║   ██║   ██║   ██║██║   ██║██║     ╚════██║
██████╔╝██████╔╝██║  ██║   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                                                   

#> 

# Install-Module -Name dbatools
# choco install dbatools


# connect to the instance
$sql = Connect-DbaInstance -SqlInstance $s1
$sql | select *


# create multiple databases on multiple databases

$maindb = 'Minnesota'
$databases = 'Mikey',$maindb

$dbParams = @{
    Name = $databases
    Owner = 'sa'
    RecoveryModel = 'Full'
    PrimaryFileGrowth = 115
    LogGrowth = 115
}

$newdbs = New-DbaDatabase @dbParams -SqlInstance $s1, $s2, $s3


# get the databases
Get-DbaDatabase -SqlInstance $s1, $s2, $s3 -ExcludeSystem | FT

# get the files
Get-DbaDbFile -SqlInstance $s1 -Database $maindb | select *

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

# new synonym
New-DbaDbSynonym -SqlInstance $s1 -Database $maindb -Synonym synonym01 -BaseDatabase master -BaseSchema sys -BaseObject databases
Get-DbaDbSynonym -SqlInstance $s1 -Database $maindb -Synonym synonym01

Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "select * from synonym01;" | ft


# create logins and users

# new login
New-DbaLogin -SqlInstance $s1, $s2 -Login CustomLogin -SecurePassword $securePass -Force

Get-DbaLogin -SqlInstance $s1, $s2 -ExcludeSystemLogin| select * | ogv
Remove-DbaLogin -SqlInstance $s1, $s2 -Login 'BUILTIN\ADMINISTRATORS' -Confirm:$false

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
Install-DbaWhoIsActive -SqlInstance $s1, $s2 -Database $maindb
Invoke-DbaWhoIsActive -SqlInstance $s1 -Database $maindb -ShowSystemSpids | Format-Table

# or FRK by Brent Ozar
Install-DbaFirstResponderKit -SqlInstance $s1, $s2 -Database $maindb -OnlyScript sp_BlitzFirst.sql
Invoke-DbaQuery -SqlInstance $s1 -Database $maindb -Query "EXEC sp_BlitzFirst" | ft


# or diagnostic queries by Glenn Berry
Invoke-DbaDiagnosticQuery -SqlInstance $s1, $s3 -UseSelectionHelper


# or monitoring by Marcin Gmiński
#Install-DbaSqlWatch -SqlInstance $s1 -WhatIf
start microsoft-edge:http://sqlwatch.io



# or maintenance solution by Ola Hallengren
Install-DbaMaintenanceSolution -SqlInstance $s1 -Database $maindb -InstallJobs


# let's start the job
Get-DbaAgentJob -SqlInstance $s1 | ft
Get-DbaAgentJob -SqlInstance $s1 | Start-DbaAgentJob




# get the job history
Get-DbaAgentJobHistory -SqlInstance $s1 | FT


# get the backup history
Get-DbaDbBackupHistory -SqlInstance $s1







# database backup
Backup-DbaDatabase -SqlInstance $s1 -Database $maindb -FilePath DB.BAK -Type Full
Measure-DbaBackupThroughput -SqlInstance $s1 -Database $maindb

docker cp sql1:/var/opt/mssql/data/DB.BAK c:\temp
docker cp c:\temp\DB.BAK sql2:/var/opt/mssql/data/

# database restore 
Restore-DbaDatabase -SqlInstance $s2 -DatabaseName $maindb  -WithReplace -Path  "/var/opt/mssql/data/DB.BAK" -DestinationFilePrefix pre # -OutputScriptOnly

# orphaned users
### report
Get-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft

### attempt to repair that
Repair-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft

# fixing by adding login
New-DbaLogin -SqlInstance $s2 -Login App01 -SecurePassword $securePass -Force

Repair-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft


# copy the login
Copy-DbaLogin -Source $s1 -Destination $s2 -Login CustomLogin

# copy the login - force
Copy-DbaLogin -Source $s1 -Destination $s2 -Login CustomLogin -Force

# report
Get-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | ft



# SQL Server config

### get
Get-DbaSpConfigure -SqlInstance  $s1 | ft

### export
Export-DbaSpConfigure -SqlInstance $s1 -FilePath SQLConfig.txt | ii

### set
Set-DbaSpConfigure -SqlInstance $s1 -Name 'backup checksum default' -Value 1
Get-DbaSpConfigure -SqlInstance  $s1 -Name 'backup checksum default' | ft


### import from the file
Import-DbaSpConfigure -SqlInstance $s1 -Path .\SQLConfig.txt


### import from the server
Import-DbaSpConfigure -Source $s1 -Destination $s2




# testing SQL server
Test-DbaBuild -SqlInstance $s1, $s3 -Latest | ft

Test-DbaDbOwner -SqlInstance $s1, $s2 -TargetLogin CustomDbOwner| ft

Test-DbaMaxDop -SqlInstance $s1 | ft
Set-DbaMaxDop -SqlInstance $s1 -MaxDop 2 -Verbose
Test-DbaMaxMemory -SqlInstance $s1| ft
Set-DbaMaxMemory -SqlInstance $s1 -Max 410 -WhatIf