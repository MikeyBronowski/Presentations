############# PLAN
<#

Targets: Azure SQL Database / elastic pool / shard maps
Azure SQL Database (S0 minimum) for Job Database
Elastic Job agent on job server
Database master key on job database 
Database Scoped Credentials on job server (job execution, server refresh)
SQL Logins on target servers – master database
SQL User to enumerate databases on the target server – master database
SQL User to for the job executions on the target server – target database
Additional permissions : what job needs to do – DDL, DML, etc.
Target group and members
Elastic job



#>
cls

############# SETTINGS
    # AZ.SQL
    # Install-Module Az.Sql -MinimumVersion 3.7.1 -Force
    # Import-Module Az.Sql -MinimumVersion 3.7.1
    # https://www.powershellgallery.com/packages/Az.Sql/3.7.1
    Get-Module dbatools, Az.Sql
    Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
    
    # DBATOOLS
    # Import-Module 'C:\Users\micha\OneDrive\learn\dbatools\dbatools.psd1' -Force

    $azCredentials = (Get-Credential -UserName Mikey -Message "Password please")

############# CREATE
$conn = Connect-AzAccount


###### RESOURCE GROUP
    $resourceGroupArgs = @{
        Name = "SQLBitsAzureElasticJobs"
        Location = "East US"
    }

    $resourceGroup = New-AzResourceGroup @resourceGroupArgs -Confirm:$false -Force
    # $resourceGroup = Get-AzResourceGroup @resourceGroupArgs



###### AZURE SQL SERVERS - JOB and TARGETS ~ 3 - 15 minutes

    $serverArgs = @{
        ResourceGroupName = $resourceGroup.ResourceGroupName
        Location = $resourceGroup.Location
        SqlAdministratorCredentials = $azCredentials
    }

    $server0Name = 'az-job-server'
    $server1Name = 'az-target-server-1'
    $server2Name = 'az-target-server-2'

    # job server
    $server0 = New-AzSqlServer @serverArgs -ServerName $server0Name # name is accepted in uppercase, but it will be converted to lowercase

    # target servers
    $server1 = New-AzSqlServer @serverArgs -ServerName $server1Name 
    $server2 = New-AzSqlServer @serverArgs -ServerName $server2Name





###### FIREWALL RULES

    # https://www.scriptinglibrary.com/languages/powershell/how-to-get-your-external-ip-with-powershell-core-using-a-restapi/
    $myIp = Invoke-RestMethod -Uri https://api.ipify.org

    # firewall rule to allow connections from my own ip address
    $random=Get-Random
    $firewallMyIpArgs = @{
        FirewallRuleName = "Firewall rule - Let me in_"+$($random)
        StartIpAddress = $myIp 
        EndIpAddress = $myIp 
        ResourceGroupName = $resourceGroup.ResourceGroupName
    }

    $firewallMyIp0 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server0.ServerName
    $firewallMyIp1 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server1.ServerName
    $firewallMyIp2 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server2.ServerName
    

    # firewall rule to allow connections beteween Azure resources
    $firewallAzureArgs = @{
        ResourceGroupName = $resourceGroup.ResourceGroupName
        AllowAllAzureIPs = $true
    }

    $firewallAzure0 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $server0.ServerName
    $firewallAzure1 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $server1.ServerName
    $firewallAzure2 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $server2.ServerName





###### AZURE SQL DATABASE - job database ~ 1 minute

    $jobDbArgs = @{
        DatabaseName                  = "JobDb"
        ServerName                    = $server0.ServerName
        ResourceGroupName             = $resourceGroup.ResourceGroupName
        Edition                       = "Standard"
        RequestedServiceObjectiveName = "S0"
        MaxSizeBytes                  = 2GB
    }


    $jobDb = New-AzSqlDatabase @jobDbArgs





###### ELASTIC JOB AGENT ~ 1 minute
    
    $jobAgent = $jobDb | New-AzSqlElasticJobAgent -Name 'AZAgent'





###### AZURE SQL DATABASE - target ~ 3 minutes

    $targetDbArgs = @{
        ResourceGroupName = $resourceGroup.ResourceGroupName
        Edition = "Basic"
        MaxSizeBytes = 1GB
    }
    
    $targetDb11 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db11 -ServerName $server1.ServerName
    $targetDb22 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db22 -ServerName $server2.ServerName
    
    $targetDb131 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db131 -ServerName $server1.ServerName
    $targetDb132 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db132 -ServerName $server1.ServerName
    $targetDb133 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db133 -ServerName $server1.ServerName





###### JOB CREDENTIAL - job database

    # create job credential in Job database for master user
    $loginPasswordSecure = (ConvertTo-SecureString -String 'password!123' -AsPlainText -Force)

    $refreshCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "refresh_credential", $loginPasswordSecure
    $refreshCred = $jobAgent | New-AzSqlElasticJobCredential -Name "refresh_credential" -Credential $refreshCred

    $jobCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "job_credential", $loginPasswordSecure
    $jobCred = $jobAgent | New-AzSqlElasticJobCredential -Name "job_credential" -Credential $jobCred

    <#
    $refreshCred = $jobAgent | Get-AzSqlElasticJobCredential -Name refresh_credential
    $jobCred = $jobAgent | Get-AzSqlElasticJobCredential -Name job_credential
    #>



###### LOGIN/USER - target database with DBATOOLS.IO

# 7. Create logins and users in target servers

# 7.1. In the master database, create the login for both credentials: refresh and job execution
$targetLoginUserArgs = @{
  'Database' = 'master'
  'SqlInstance' =  @($server1.FullyQualifiedDomainName, $server2.FullyQualifiedDomainName)
  'SqlCredential' = $azCredentials
  'Query' = 'CREATE LOGIN refresh_credential WITH PASSWORD=''password!123'';'
}

Invoke-DbaQuery @targetLoginUserArgs
<# New-DbaLogin
   Azure SQL Database is not supported by this command
#>

$targetLoginUserArgs.Query = "CREATE USER refresh_credential FROM LOGIN refresh_credential;"
Invoke-DbaQuery @targetLoginUserArgs

$targetLoginUserArgs.Query = 'CREATE LOGIN job_credential WITH PASSWORD=''password!123'';'
Invoke-DbaQuery @targetLoginUserArgs


$targetDatabases = Get-DbaDatabase -SqlInstance $server1.FullyQualifiedDomainName, $server2.FullyQualifiedDomainName -SqlCredential $azCredentials -ExcludeSystem
# $targetDatabases | ft
$targetDatabases | % {
    $targetLoginUserArgs.SqlInstance = $_.ComputerName
    $targetLoginUserArgs.Database = $_.Name
    $targetLoginUserArgs.Query = "CREATE USER job_credential FROM LOGIN job_credential;"
    $targetLoginUserArgs.Query += "ALTER ROLE db_owner ADD MEMBER [job_credential];"
    Invoke-DbaQuery @targetLoginUserArgs
}





###### TARGET GROUPS

    # 1 whole server
    $serverGroup1 = $jobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup1'
    $serverGroup1 | Add-AzSqlElasticJobTarget -ServerName $server1.FullyQualifiedDomainName -RefreshCredentialName $refreshCred.CredentialName
    $serverGroup1 | Add-AzSqlElasticJobTarget -ServerName $server2.FullyQualifiedDomainName -RefreshCredentialName $refreshCred.CredentialName


    # 2 selected databases
    $serverGroup2 = $jobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup2'
    $serverGroup2 | Add-AzSqlElasticJobTarget -ServerName $server1.FullyQualifiedDomainName -DatabaseName $targetDb11.DatabaseName
    $serverGroup2 | Add-AzSqlElasticJobTarget -ServerName $server2.FullyQualifiedDomainName -DatabaseName $targetDb22.DatabaseName


    # 3 exclude database from a server
    $serverGroup3 = $jobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup3'
    $($server1 | Get-AzSqlDatabase) | % { $serverGroup3 | Add-AzSqlElasticJobTarget -ServerName $server1.FullyQualifiedDomainName -DatabaseName $_.DatabaseName }
    $serverGroup3 | Add-AzSqlElasticJobTarget -ServerName $server1.FullyQualifiedDomainName -DatabaseName $targetDb11.DatabaseName -Exclude 





###### CREATE ELASTIC JOB

    $jobName = "Job"
    $job = $jobAgent | New-AzSqlElasticJob -Name $jobName -RunOnce

    $sqlText1 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step1Table')) CREATE TABLE [dbo].[Step1Table]([TestId] [int] NOT NULL);"
    $sqlText2 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step2Table')) CREATE TABLE [dbo].[Step2Table]([TestId] [int] NOT NULL);"
    $sqlText3 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step3Table')) CREATE TABLE [dbo].[Step3Table]([TestId] [int] NOT NULL);"

    $job | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $serverGroup1.TargetGroupName -CredentialName $jobCred.CredentialName -CommandText $sqlText1
    $job | Add-AzSqlElasticJobStep -Name "step2" -TargetGroupName $serverGroup2.TargetGroupName -CredentialName $jobCred.CredentialName -CommandText $sqlText2
    $job | Add-AzSqlElasticJobStep -Name "step3" -TargetGroupName $serverGroup3.TargetGroupName -CredentialName $jobCred.CredentialName -CommandText $sqlText3





###### START / MONITOR ELASTIC JOB

    $jobExecution = $job | Start-AzSqlElasticJob

    # get the latest 10 executions run
    $jobAgent | Get-AzSqlElasticJobExecution -Count 10

    # get the job step execution details
    $jobExecution | Get-AzSqlElasticJobStepExecution

    # get the job target execution details
    $jobExecution | Get-AzSqlElasticJobTargetExecution -Count 13

    $tables = Get-DbaDbTable -SqlInstance $server1.FullyQualifiedDomainName, $server2.FullyQualifiedDomainName -SqlCredential $azCredentials -Table Step1Table, Step2Table, Step3Table
    $tables | ogv





###### EXAMPLE: Collecting data

    # setup credential on central server
    $collectionCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "job_collection", $loginPasswordSecure
    $collectionCred = $jobAgent | New-AzSqlElasticJobCredential -Name "job_collection" -Credential $collectionCred

    $query21 = 'CREATE LOGIN job_collection WITH PASSWORD=''password!123'';'
    Invoke-DbaQuery -SqlInstance $server0.FullyQualifiedDomainName -SqlCredential $azCredentials -Database 'master' -Query $query21

    $query22 = 'CREATE USER job_collection FROM LOGIN job_collection;ALTER ROLE db_owner ADD MEMBER [job_collection];'
    Invoke-DbaQuery -SqlInstance $server0.FullyQualifiedDomainName -SqlCredential $azCredentials -Database $jobDb.DatabaseName -Query $query22




    # setup login/user on targets
    Invoke-DbaQuery -SqlInstance $server1.FullyQualifiedDomainName, $server2.FullyQualifiedDomainName -SqlCredential $azCredentials -Database 'master' -Query $query21

    $targetDatabases | % {
        $targetLoginUserArgs.SqlInstance = $_.ComputerName
        $targetLoginUserArgs.Database = $_.Name
        $targetLoginUserArgs.Query = "CREATE USER job_collection FROM LOGIN job_collection;"
        $targetLoginUserArgs.Query += "ALTER ROLE db_datareader ADD MEMBER [job_credential];"
        Invoke-DbaQuery @targetLoginUserArgs
    }


    # create central table - note internal_execution_id
    $cols = @()
    $cols += @{
        Name      = 'internal_execution_id'
        Type      = 'UNIQUEIDENTIFIER'
        Nullable  = $false
    }
    $cols += @{
        Name      = 'server'
        Type      = 'varchar'
        MaxLength = 50
        Nullable  = $true
    }
    $cols += @{
        Name      = 'db'
        Type      = 'varchar'
        MaxLength = 50
        Nullable  = $true
    }
    $cols += @{
        Name      = 'when'
        Type      = 'datetime2'
        Nullable  = $true
    }
    New-DbaDbTable -SqlInstance $server0.FullyQualifiedDomainName -SqlCredential $azCredentials -Database $jobDb.DatabaseName -Schema Collection -Name CentralOutput -ColumnMap $cols

    # create elastic job
    $jobName2 = "JobCollection"
    $job2 = $jobAgent | New-AzSqlElasticJob -Name $jobName2 -RunOnce

    $sqlText21 = "SELECT @@SERVERNAME AS [server], DB_NAME() AS [db], GETDATE() AS [when];"

    #$job2 | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $serverGroup1.TargetGroupName -CredentialName $jobCred.CredentialName -CommandText $sqlText21 -OutputSchemaName Collection -OutputTableName CentralOutput -OutputCredentialName $jobCred.CredentialName -OutputDatabaseResourceId '/subscriptions/a391f450-9ba5-4fce-aa21-97a1b9ec6937/resourceGroups/AzConf2021/providers/Microsoft.Sql/servers/az-job-server/databases/JobDb'  #-OutputDatabaseObject $jobDb
    $job2 | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $serverGroup1.TargetGroupName -CredentialName $jobCred.CredentialName -CommandText $sqlText21 -OutputSchemaName Collection -OutputTableName CentralOutput -OutputCredentialName 'job_collection' -OutputDatabaseResourceId '/subscriptions/a391f450-9ba5-4fce-aa21-97a1b9ec6937/resourceGroups/AzConf2021/providers/Microsoft.Sql/servers/az-job-server/databases/JobDb'  #-OutputDatabaseObject $jobDb

    $jobExecution2 = $job2 | Start-AzSqlElasticJob

    $jobExecution2 | Get-AzSqlElasticJobTargetExecution -Count 13

    $query23 = 'SELECT * FROM collection.CentralOutput'
    Invoke-DbaQuery -SqlInstance $server0.FullyQualifiedDomainName -SqlCredential $azCredentials -Database $jobDb.DatabaseName -Query $query23



