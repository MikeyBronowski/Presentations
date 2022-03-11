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
    # Install-Module Az
    # Import-Module dbatools, Az.Sql, Az
    # https://www.powershellgallery.com/packages/Az.Sql/3.7.1
    Get-Module dbatools, Az.Sql
    Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
    
    # DBATOOLS
    # Install-Module dbatools -Force



############# CREATE
$freshconn = Connect-AzAccount
$freshazCredentials = (Get-Credential -UserName Mikey -Message "Password please")


###### RESOURCE GROUP
    $freshresourceGroupArgs = @{
        Name = "SQLBitsAzureElasticJobsFresh"
        Location = "East US"
    }

    $freshresourceGroup = New-AzResourceGroup @freshresourceGroupArgs -Confirm:$freshfalse -Force



###### AZURE SQL SERVERS - JOB and TARGETS ~ 3 - 15 minutes

    $freshserverArgs = @{
        ResourceGroupName = $freshresourceGroup.ResourceGroupName
        Location = $freshresourceGroup.Location
        SqlAdministratorCredentials = $freshazCredentials
    }

    $freshserver0Name = 'az-job-server-fresh'
    $freshserver1Name = 'az-target-server-1-fresh'
    $freshserver2Name = 'az-target-server-2-fresh'

    # job server
    $freshserver0 = New-AzSqlServer @serverArgs -ServerName $freshserver0Name # name is accepted in uppercase, but it will be converted to lowercase

    # target servers
    $freshserver1 = New-AzSqlServer @serverArgs -ServerName $freshserver1Name 
    $freshserver2 = New-AzSqlServer @serverArgs -ServerName $freshserver2Name





###### FIREWALL RULES

    # https://www.scriptinglibrary.com/languages/powershell/how-to-get-your-external-ip-with-powershell-core-using-a-restapi/
    $freshmyIp = Invoke-RestMethod -Uri https://api.ipify.org

    # firewall rule to allow connections from my own ip address
    $freshrandom=Get-Random
    $freshfirewallMyIpArgs = @{
        FirewallRuleName = "Firewall rule - Let me in_"+$fresh($freshrandom)
        StartIpAddress = $freshmyIp 
        EndIpAddress = $freshmyIp 
        ResourceGroupName = $freshresourceGroup.ResourceGroupName
    }

    $freshfirewallMyIp0 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $freshserver0.ServerName
    $freshfirewallMyIp1 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $freshserver1.ServerName
    $freshfirewallMyIp2 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $freshserver2.ServerName
    

    # firewall rule to allow connections beteween Azure resources
    $freshfirewallAzureArgs = @{
        ResourceGroupName = $freshresourceGroup.ResourceGroupName
        AllowAllAzureIPs = $freshtrue
    }

    $freshfirewallAzure0 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $freshserver0.ServerName
    $freshfirewallAzure1 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $freshserver1.ServerName
    $freshfirewallAzure2 = New-AzSqlServerFirewallRule @firewallAzureArgs -ServerName $freshserver2.ServerName





###### AZURE SQL DATABASE - job database ~ 1 minute

    $freshjobDbArgs = @{
        DatabaseName                  = "JobDb-fresh"
        ServerName                    = $freshserver0.ServerName
        ResourceGroupName             = $freshresourceGroup.ResourceGroupName
        Edition                       = "Standard"
        RequestedServiceObjectiveName = "S0"
        MaxSizeBytes                  = 2GB
    }


    $freshjobDb = New-AzSqlDatabase @jobDbArgs



<# 

###### ELASTIC JOB AGENT ~ 1 minute
    
    $freshjobAgentName = 'AZAgent'
    $freshjobAgent = $freshjobDb | New-AzSqlElasticJobAgent -Name $freshjobAgentName
#>




###### AZURE SQL DATABASE - target ~ 3 minutes

    $freshtargetDbArgs = @{
        ResourceGroupName = $freshresourceGroup.ResourceGroupName
        Edition = "Basic"
        MaxSizeBytes = 1GB
    }
    
    $freshtargetDb11 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db11-fresh -ServerName $freshserver1.ServerName
    $freshtargetDb22 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db22-fresh -ServerName $freshserver2.ServerName
    
    $freshtargetDb131 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db131-fresh -ServerName $freshserver1.ServerName
    $freshtargetDb132 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db132-fresh -ServerName $freshserver1.ServerName
    $freshtargetDb133 = New-AzSqlDatabase @targetDbArgs -DatabaseName Db133-fresh -ServerName $freshserver1.ServerName





###### JOB CREDENTIAL - job database

    # create job credential in Job database for master user
    $freshloginPasswordSecure = (ConvertTo-SecureString -String 'password!123' -AsPlainText -Force)

    $freshrefreshCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "refresh_credential", $freshloginPasswordSecure
    $freshrefreshCred = $freshjobAgent | New-AzSqlElasticJobCredential -Name "refresh_credential" -Credential $freshrefreshCred

    $freshjobCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "job_credential", $freshloginPasswordSecure
    $freshjobCred = $freshjobAgent | New-AzSqlElasticJobCredential -Name "job_credential" -Credential $freshjobCred


###### LOGIN/USER - target database with DBATOOLS.IO

# 7. Create logins and users in target servers

# 7.1. In the master database, create the login for both credentials: refresh and job execution
$freshtargetLoginUserArgs = @{
  'Database' = 'master'
  'SqlInstance' =  @($freshserver1.FullyQualifiedDomainName, $freshserver2.FullyQualifiedDomainName)
  'SqlCredential' = $freshazCredentials
  'Query' = 'CREATE LOGIN refresh_credential WITH PASSWORD=''password!123'';'
}

Invoke-DbaQuery @targetLoginUserArgs
<# New-DbaLogin
   Azure SQL Database is not supported by this command
#>

$freshtargetLoginUserArgs.Query = "CREATE USER refresh_credential FROM LOGIN refresh_credential;"
Invoke-DbaQuery @targetLoginUserArgs

$freshtargetLoginUserArgs.Query = 'CREATE LOGIN job_credential WITH PASSWORD=''password!123'';'
Invoke-DbaQuery @targetLoginUserArgs


$freshtargetDatabases = Get-DbaDatabase -SqlInstance $freshserver1.FullyQualifiedDomainName, $freshserver2.FullyQualifiedDomainName -SqlCredential $freshazCredentials -ExcludeSystem
# $freshtargetDatabases | ft
$freshtargetDatabases | % {
    $freshtargetLoginUserArgs.SqlInstance = $fresh_.ComputerName
    $freshtargetLoginUserArgs.Database = $fresh_.Name
    $freshtargetLoginUserArgs.Query = "CREATE USER job_credential FROM LOGIN job_credential;"
    $freshtargetLoginUserArgs.Query += "ALTER ROLE db_owner ADD MEMBER [job_credential];"
    Invoke-DbaQuery @targetLoginUserArgs
}





###### TARGET GROUPS

    # 1 whole server
    $freshserverGroup1 = $freshjobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup1'
    $freshserverGroup1 | Add-AzSqlElasticJobTarget -ServerName $freshserver1.FullyQualifiedDomainName -RefreshCredentialName $freshrefreshCred.CredentialName
    $freshserverGroup1 | Add-AzSqlElasticJobTarget -ServerName $freshserver2.FullyQualifiedDomainName -RefreshCredentialName $freshrefreshCred.CredentialName


    # 2 selected databases
    $freshserverGroup2 = $freshjobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup2'
    $freshserverGroup2 | Add-AzSqlElasticJobTarget -ServerName $freshserver1.FullyQualifiedDomainName -DatabaseName $freshtargetDb11.DatabaseName
    $freshserverGroup2 | Add-AzSqlElasticJobTarget -ServerName $freshserver2.FullyQualifiedDomainName -DatabaseName $freshtargetDb22.DatabaseName


    # 3 exclude database from a server
    $freshserverGroup3 = $freshjobAgent | New-AzSqlElasticJobTargetGroup -Name 'TargetGroup3'
    $fresh($freshserver1 | Get-AzSqlDatabase) | % { $freshserverGroup3 | Add-AzSqlElasticJobTarget -ServerName $freshserver1.FullyQualifiedDomainName -DatabaseName $fresh_.DatabaseName }
    $freshserverGroup3 | Add-AzSqlElasticJobTarget -ServerName $freshserver1.FullyQualifiedDomainName -DatabaseName $freshtargetDb11.DatabaseName -Exclude 





###### CREATE ELASTIC JOB

    $freshjobName = "Job"
    $freshjob = $freshjobAgent | New-AzSqlElasticJob -Name $freshjobName -RunOnce

    $freshsqlText1 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step1Table')) CREATE TABLE [dbo].[Step1Table]([TestId] [int] NOT NULL);"
    $freshsqlText2 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step2Table')) CREATE TABLE [dbo].[Step2Table]([TestId] [int] NOT NULL);"
    $freshsqlText3 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step3Table')) CREATE TABLE [dbo].[Step3Table]([TestId] [int] NOT NULL);"

    $freshjob | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $freshserverGroup1.TargetGroupName -CredentialName $freshjobCred.CredentialName -CommandText $freshsqlText1
    $freshjob | Add-AzSqlElasticJobStep -Name "step2" -TargetGroupName $freshserverGroup2.TargetGroupName -CredentialName $freshjobCred.CredentialName -CommandText $freshsqlText2
    $freshjob | Add-AzSqlElasticJobStep -Name "step3" -TargetGroupName $freshserverGroup3.TargetGroupName -CredentialName $freshjobCred.CredentialName -CommandText $freshsqlText3





###### START / MONITOR ELASTIC JOB

    $freshjobExecution = $freshjob | Start-AzSqlElasticJob

    # get the latest 10 executions run
    $freshjobAgent | Get-AzSqlElasticJobExecution -Count 10

    # get the job step execution details
    $freshjobExecution | Get-AzSqlElasticJobStepExecution

    # get the job target execution details
    $freshjobExecution | Get-AzSqlElasticJobTargetExecution -Count 13

    $freshtables = Get-DbaDbTable -SqlInstance $freshserver1.FullyQualifiedDomainName, $freshserver2.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Table Step1Table, Step2Table, Step3Table
    $freshtables | ogv





###### EXAMPLE: Collecting data

    # setup credential on central server
    $freshcollectionCred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "job_collection", $freshloginPasswordSecure
    $freshcollectionCred = $freshjobAgent | New-AzSqlElasticJobCredential -Name "job_collection" -Credential $freshcollectionCred

    $freshquery21 = 'CREATE LOGIN job_collection WITH PASSWORD=''password!123'';'
    Invoke-DbaQuery -SqlInstance $freshserver0.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Database 'master' -Query $freshquery21

    $freshquery22 = 'CREATE USER job_collection FROM LOGIN job_collection;ALTER ROLE db_owner ADD MEMBER [job_collection];'
    Invoke-DbaQuery -SqlInstance $freshserver0.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Database $freshjobDb.DatabaseName -Query $freshquery22




    # setup login/user on targets
    Invoke-DbaQuery -SqlInstance $freshserver1.FullyQualifiedDomainName, $freshserver2.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Database 'master' -Query $freshquery21

    $freshtargetDatabases | % {
        $freshtargetLoginUserArgs.SqlInstance = $fresh_.ComputerName
        $freshtargetLoginUserArgs.Database = $fresh_.Name
        $freshtargetLoginUserArgs.Query = "CREATE USER job_collection FROM LOGIN job_collection;"
        $freshtargetLoginUserArgs.Query += "ALTER ROLE db_datareader ADD MEMBER [job_credential];"
        Invoke-DbaQuery @targetLoginUserArgs
    }


    # create central table - note internal_execution_id
    $freshcols = @()
    $freshcols += @{
        Name      = 'internal_execution_id'
        Type      = 'UNIQUEIDENTIFIER'
        Nullable  = $freshfalse
    }
    $freshcols += @{
        Name      = 'server'
        Type      = 'varchar'
        MaxLength = 50
        Nullable  = $freshtrue
    }
    $freshcols += @{
        Name      = 'db'
        Type      = 'varchar'
        MaxLength = 50
        Nullable  = $freshtrue
    }
    $freshcols += @{
        Name      = 'when'
        Type      = 'datetime2'
        Nullable  = $freshtrue
    }
    New-DbaDbTable -SqlInstance $freshserver0.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Database $freshjobDb.DatabaseName -Schema Collection -Name CentralOutput -ColumnMap $freshcols

    # create elastic job
    $freshjobName2 = "JobCollection"
    $freshjob2 = $freshjobAgent | New-AzSqlElasticJob -Name $freshjobName2 -RunOnce

    $freshsqlText21 = "SELECT @@SERVERNAME AS [server], DB_NAME() AS [db], GETDATE() AS [when];"

    $freshjob2 | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $freshserverGroup1.TargetGroupName -CredentialName $freshjobCred.CredentialName -CommandText $freshsqlText21 -OutputSchemaName Collection -OutputTableName CentralOutput -OutputCredentialName 'job_collection' -OutputDatabaseResourceId $freshjobDb.ResourceId  #-OutputDatabaseObject $freshjobDb


    ###### START / MONITOR ELASTIC JOB
    $freshjobExecution2 = $freshjob2 | Start-AzSqlElasticJob

    $freshjobExecution2 | Get-AzSqlElasticJobTargetExecution -Count 13

    $freshquery23 = 'SELECT * FROM collection.CentralOutput'
    Invoke-DbaQuery -SqlInstance $freshserver0.FullyQualifiedDomainName -SqlCredential $freshazCredentials -Database $freshjobDb.DatabaseName -Query $freshquery23



