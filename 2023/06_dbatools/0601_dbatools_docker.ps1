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

Set-Location "C:\Users\MikeyBronowski\OneDrive - Data Masterminds bv\Documents\900_Priv\SQLDay\06_dbatools"

# dbatools.io/docker
# https://github.com/dataplat/docker
# https://github.com/dataplat/docker/tree/main/samples/stackoverflow

# pull the images
docker pull dbatools/sqlinstance
docker pull dbatools/sqlinstance2

# stop containers
docker stop mssql1
docker stop mssql2
docker stop mssql3
<##>
docker start mssql1
docker start mssql2
docker start mssql3
#>

# remove containers
docker rm -v mssql1
docker rm -v mssql2
docker rm -v mssql3
docker network rm localnet

# create shared network
docker network create localnet

# run containerts
docker run -p 14331:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
docker run -p 14332:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2
docker run -p 14333:1433 --volume shared:/shared:z --name mssql3 --hostname mssql3 --network localnet -d dbatools/sqlinstance2
docker ps -a

# assign alias 
New-DbaClientAlias -ServerName 'localhost,14331' -Alias mssql1
New-DbaClientAlias -ServerName 'localhost,14332' -Alias mssql2
New-DbaClientAlias -ServerName 'localhost,14333' -Alias mssql3

# default password for "sqladmin" = "dbatools.IO"
if (-not $credential) {
    $securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
    $credential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)
}

$PSDefaultParameterValues = @{
                              "*-Dba*:SqlCredential"=$credential
                              "*-Dba*:DestinationCredential"=$credential
                              "*-Dba*:DestinationSqlCredential"=$credential
                              "*-Dba*:SourceSqlCredential"=$credential
                              "*-Dba*:PrimarySqlCredential"=$credential
                              "*-Dba*:SecondarySqlCredential"=$credential
                            }




$sql1 = "localhost:14331"
$sql2 = "localhost:14332"
$agName = "PowerDBA_AG"


Set-DbatoolsInsecureConnection

# change model to FULL
# THE LAST ONE -SqlCredential because it's in defaults now
Set-DbaDbRecoveryModel -SqlInstance $sql1 -SqlCredential $credential -Database pubs, Northwind -RecoveryModel Full


# backup
Backup-DbaDatabase -SqlInstance $sql1 -Database pubs, Northwind -Type Full -FilePath $null

# params AG
$params = @{
    Primary = $sql1
    Secondary = $sql2
    Name = $agName
    Database = "pubs", "Northwind"
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
 }

# create new AG
New-DbaAvailabilityGroup @params
# Import-Module dbatools -MinimumVersion 1.1.89


# check the AG
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Format-Table

# check databases in AG
Get-DbaAgDatabase -SqlInstance $sql1 | Format-Table

Get-DbaAvailabilityGroup -SqlInstance $sql2 | Invoke-DbaAgFailover -Force -Confirm:$false
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Invoke-DbaAgFailover -Force -Confirm:$false

Get-DbaAgDatabase -SqlInstance $sql1, $sql2 | Resume-DbaAgDbDataMovement -Confirm:$false


Get-DbaAgReplica -SqlInstance $sql1 | Format-Table

Get-DbaAgReplica -SqlInstance $sql1 | Set-DbaAgReplica -AvailabilityMode AsynchronousCommit
Get-DbaAgReplica -SqlInstance $sql1 | Set-DbaAgReplica -AvailabilityMode SynchronousCommit






# params AG2 - empty
$params2 = @{
    Primary = $sql1
    Secondary = $sql2
    Name = ($agName+"2")
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
 }

# new AG
New-DbaAvailabilityGroup @params2

# new database
New-DbaDatabase -SqlInstance $sql1 -Name PowerDBA -RecoveryModel Full

# required backup.... even though it is not saved  > nul
Backup-DbaDatabase -SqlInstance $sql1 -Database PowerDBA -FilePath nul

# add new db to the AG
Add-DbaAgDatabase -SqlInstance $sql1 -AvailabilityGroup ($agName+"2") -Database PowerDBA -Secondary $sql2 -Verbose





# export objects
Export-DbaInstance -SqlInstance $sql1 -Exclude LinkedServers, Credentials


# migrate whole instance
$paramsMigration = @{
    Source = $sql1
    Destination = $sql2
    BackupRestore = $true
    SharedPath = "/shared"
    Exclude = "LinkedServers", "Credentials", "BackupDevices"
    Force = $true
}

Start-DbaMigration @paramsMigration | Out-GridView



### synchronize logins
$maindb = 'PASSSummit2023'
$null = New-DbaDatabase -SqlInstance $sql1 -Name $maindb -RecoveryModel Full

New-DbaLogin -SqlInstance $sql1 -Login App01 -SecurePassword $securePass -Force
New-DbaDbUser -SqlInstance $sql1 -Database $maindb -Username App01 -Login App01

# backup
Backup-DbaDatabase -SqlInstance $sql1 -Database $maindb -FilePath /var/opt/mssql/data/DB2.BAK -Type Full

# copy backups between the containers using local drive
docker cp mssql1:/var/opt/mssql/data/DB2.BAK .\
docker cp .\DB2.BAK mssql2:/var/opt/mssql/data/

# EXEC master.sys.xp_delete_files  '/Shared/*.BAK';

# restore backup on a second instance
Restore-DbaDatabase -SqlInstance $sql2 -DatabaseName $maindb  -WithReplace -Path  "/var/opt/mssql/data/DB2.BAK" -DestinationFilePrefix pre  # -OutputScriptOnly


# get orphaned users
# report
Get-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# attempting to fix it
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# again, add logins
New-DbaLogin -SqlInstance $sql2 -Login App01 -SecurePassword $securePass -Force
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table


# final fix, including SID and password
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01

# ok, one more push - with Force
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01 -Force

# report
Get-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table






# sprzatanie
<#

Get-DbaAvailabilityGroup -SqlInstance $sql1, $sql2 -AvailabilityGroup PowerDBA_AG2 | Remove-DbaAvailabilityGroup -Confirm:$false
Get-DbaAgDatabase -SqlInstance $sql1 -AvailabilityGroup PowerDBA_AG2 | Remove-DbaAgDatabase -Confirm:$false

Get-DbaAgDatabase -SqlInstance $sql2 | Remove-DbaAgDatabase -Confirm:$false
Get-DbaDatabase -SqlInstance $sql1, $sql2 -ExcludeSystem -Status Restoring | Remove-DbaDatabase -Confirm:$false
Get-DbaAvailabilityGroup -SqlInstance $sql1, $sql2 | Remove-DbaAvailabilityGroup -Confirm:$false


#>


<#
docker builder prune -a -f
docker compose down --remove-orphans --volumes
docker rmi $(docker images -q "dbatools\/*")
#>


<#
not working properly - troubleshoot
#$ag2 = Get-DbaAvailabilityGroup -SqlInstance $sql1 -AvailabilityGroup ($agName+"2")
#Get-DbaDatabase -SqlInstance $sql1 -Database PowerDBA2 | Add-DbaAgDatabase -AvailabilityGroup $ag2 -Secondary $sql2 -Verbose
Test-DbaAvailabilityGroup -SqlInstance $sql1 -AvailabilityGroup ($agName+"2") -AddDatabase PowerDBA -Secondary $sql2
#>