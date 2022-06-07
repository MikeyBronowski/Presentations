<#

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

Set-Location "C:\Users\MikeyBronowski\OneDrive - Data Masterminds bv\Documents\900_Priv\DataGrillen"

# dbatools.io/docker
# https://github.com/dataplat/docker
# https://github.com/dataplat/docker/tree/main/samples/stackoverflow

# download images
docker pull dbatools/sqlinstance
docker pull dbatools/sqlinstance2

# stop containers
docker stop mssql1
docker stop mssql2

# remove containers
docker rm mssql1
docker rm mssql2
docker network rm localnet

# create shared network
docker network create localnet

# run containers
docker run -p 14331:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
docker run -p 14332:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2
docker ps -a


# password for the login = "dbatools.IO"
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
$agName = "demoAG"
$instances = $sql1, $sql2

Import-Module dbatools

#:: 1 - AGs

# change the recovery model to FULL
# THE LAST TIME we use -SqlCredential because it's in defaults
Set-DbaDbRecoveryModel -SqlInstance $sql1 -SqlCredential $credential -Database pubs, Northwind -RecoveryModel Full

# take backups
Backup-DbaDatabase -SqlInstance $sql1 -Database pubs, Northwind -Type Full -FilePath $null

# AG creation parameters
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

# new AG
New-DbaAvailabilityGroup @params



# see the details of new AG
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Format-Table

# see the details of the databases in new AG
Get-DbaAgDatabase -SqlInstance $sql1 | Format-Table

Get-DbaAvailabilityGroup -SqlInstance $sql2 | Invoke-DbaAgFailover -Force -Confirm:$false
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Invoke-DbaAgFailover -Force -Confirm:$false

Get-DbaAgReplica -SqlInstance $sql1 | Format-Table

Get-DbaAgDatabase -SqlInstance $sql1, $sql2 | Resume-DbaAgDbDataMovement -Confirm:$false





#:: 2 - objects export
Export-DbaInstance -SqlInstance $sql1 -Exclude LinkedServers, Credentials -Path "C:\Users\MikeyBronowski\OneDrive - Data Masterminds bv\Documents\900_Priv\PowerDBA"


#:: 3 - copying objects
$maindb = 'Mikey'
$null = New-DbaDatabase -SqlInstance $sql1 -Name $maindb -RecoveryModel Full

New-DbaLogin -SqlInstance $sql1 -Login App01 -SecurePassword $securePassword -Force
New-DbaDbUser -SqlInstance $sql1 -Database $maindb -Username App01 -Login App01

# database backup
Backup-DbaDatabase -SqlInstance $sql1 -Database $maindb -FilePath /var/opt/mssql/data/DB.BAK -Type Full -Initialize

# copy files between the docker containers
docker cp mssql1:/var/opt/mssql/data/DB.BAK .\
docker cp .\DB.BAK mssql2:/var/opt/mssql/data/

# restore
Restore-DbaDatabase -SqlInstance $sql2 -DatabaseName $maindb  -WithReplace -Path  "/var/opt/mssql/data/DB.BAK" -DestinationFilePrefix pre  # -OutputScriptOnly


# orphaned users
# report
Get-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# fix - 1st attempt
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# let'a create a missing login then
New-DbaLogin -SqlInstance $sql2 -Login App01 -SecurePassword $securePass -Force
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table


# final fix with login copy including SID and password
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01

# one more time - we need Force
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01 -Force

# report
Get-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table




#:: 4 - sql agent

# rename the SA login
Rename-DbaLogin -SqlInstance $instances[1] -Login sa -NewLogin dbasa

Get-DbaLogin -SqlInstance $instances[1] |
    Where-Object { $_.ID -eq 1 } |
    Select-Object |
    Format-Table


# current owner
# command outputs
$job1 = '- first job'
New-DbaAgentJob -SqlInstance $instances -Job $job1 -Description $job1

# see the jobs
Get-DbaAgentJob -SqlInstance $instances | Sort-Object -Property Name -Descending | Format-Table -AutoSize 

# remove jobs matching criteria
$null = Get-DbaAgentJob -SqlInstance $instances | Where-Object Name -EQ $job1 | Remove-DbaAgentJob -Confirm:$false

# remove all jobs
$null = Get-DbaAgentJob -SqlInstance $instances | Remove-DbaAgentJob -Confirm:$false


# assign SA to the job where the SA is renamed
$job2 = '- - second job'
$null = New-DbaAgentJob -SqlInstance $instances -Job $job2 -OwnerLogin sa

# see the jobs
Get-DbaAgentJob -SqlInstance $instances | Sort-Object -Property Name -Descending | Format-Table -AutoSize 

# create a new job
# with 'sa' as owner - 'sa' can have any name, but it's ID = 1, 0x01
$job3 = '- - - third job'
foreach ($inst in $instances) {
    $localSA = $(Get-DbaLogin -SqlInstance $inst | Where-Object { $_.ID -eq 1 }).Name
    $null = New-DbaAgentJob -SqlInstance $inst -Job $job3 -OwnerLogin $localSA
  }

# see the jobs
Get-DbaAgentJob -SqlInstance $instances | Sort-Object -Property Name -Descending | Format-Table -AutoSize 





# add step 1 & 2
$null = New-DbaAgentJobStep -SqlInstance $instances[1] -Job $job3 -StepName "step 1" -Command "select @@version"
$null = New-DbaAgentJobStep -SqlInstance $instances[1] -Job $job3 -StepName "step 2" -Command "select @@version"

# see the steps
Get-DbaAgentJobStep -SqlInstance $instances[1] -Job $job3 | Select-Object SqlInstance, AgentJob, Name, Id, OnSuccessAction, OnFailAction, OnFailStepId | Format-Table -AutoSize

# insert step in front of everything 
$stepSplat = @{
  StepName        = "step zer0"              
  Database        = "master"
  Subsystem       = "TransactSql"
  StepId          = "1"
  OnFailAction    = "QuitWithFailure"
  OnSuccessAction = "GoToNextStep"
  Command         = "select @@version"
  Insert          = $true             # inserting the step
}
$null = New-DbaAgentJobStep @stepSplat -SqlInstance $instances[1] -Job $job3 

# change single step actions
$null = Set-DbaAgentJobStep -SqlInstance $instances[1] -Job $job3 -StepName "step 1" -OnSuccessAction GoToNextStep -OnFailAction GoToStep -OnFailStepId 1

# see the steps
Get-DbaAgentJobStep -SqlInstance $instances[1] -Job $job3 | Select-Object SqlInstance, AgentJob, Name, Id, OnSuccessAction, OnFailAction, OnFailStep | Format-Table -AutoSize


#:: 5 - community tools
# install Ola Hallengren's solution with jobs
# 1-2 min
$ola = Install-DbaMaintenanceSolution -SqlInstance $instances[1] -Database Mikey -InstallJobs

# if the solution exists - Replace
$ola = Install-DbaMaintenanceSolution -SqlInstance $instances -Database Mikey -InstallJobs -ReplaceExisting

# install community tasks
<#


Community Tools
Export-DbaDiagnosticQuery
Get-DbaMaintenanceSolutionLog
Install-DbaDarlingData
Install-DbaFirstResponderKit
Install-DbaMaintenanceSolution
Install-DbaMultiTooln
Install-DbaSqlWatch
Install-DbaWhoIsActive
Invoke-DbaDiagnosticQuery
Invoke-DbaWhoisActive
New-DbaDiagnosticAdsNotebook
Save-DbaCommunitySoftware
Save-DbaDiagnosticQueryScript


#>