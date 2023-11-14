## Dbachecks Database Connection
$instances = Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect
$dbachecksServer = 'localhost'
$dbachecksDatabase = 'dbachecks'

## Define instances and checks to run
$checks = "Agent"       # 1 min
$checks = "AdHocWorkload","SaRenamed","SaDisabled","MaxDopInstance","ErrorLogCount","CLREnabled","LatestBuild","ModelDbGrowth","TraceFlagsExpected","TraceFlagsNotExpected","LoginAudit","AutoClose","AutoShrink" # 
$checks = "High"        # 1 min
$checks = "Instance"    # 3 min

$checks = "Agent","High","Instance"
$checksExclude = "InstanceConnection"


$chkResults = Invoke-DbcCheck -SqlInstance $instances -Checks $checks -ExcludeCheck $checksExclude -PassThru
$chkResults = $chkResults | Convert-DbcResult -Label 'MorningChecks'
$chkResults | Write-DbcTable -SqlInstance $dbachecksServer -Database $dbachecksDatabase


# zamieniamy sie w kreatywnego ksiegowego
Invoke-DbaQuery -SqlInstance $dbachecksServer -Database $dbachecksDatabase -Query 'update CheckResults set [date]=DATEADD(DAY, -7,[date])'

<#####################################################################>
# naprawiamy niektore rzeczy
Rename-DbaLogin -SqlInstance $fix -Login sa -NewLogin newsa
Set-DbaMaxDop -SqlInstance $instances -MaxDop 2

$spconfigs = "XPCmdShellEnabled", "DefaultBackupCompression","OptimizeAdhocWorkloads","RemoteDacConnectionsEnabled"
Get-DbaSpConfigure -SqlInstance $instances -Name $spconfigs | Format-Table
$null = Get-DbaSpConfigure -SqlInstance $instances -Name $spconfigs | Set-DbaSpConfigure -Value $true

foreach ($inst in $instances) {
    $null = Set-DbaAgentJobOwner -SqlInstance $inst -Login $(Get-DbaLogin -SqlInstance $inst | Where-Object { $_.ID -eq 1 }).Name
  }


  # uruchom t-sql na localhost
  # https://www.brentozar.com/blitz/configure-sql-server-alerts/
  Copy-DbaAgentAlert -Source localhost -Destination $instances

# zamieniamy sie w kreatywnego ksiegowego
Invoke-DbaQuery -SqlInstance $dbachecksServer -Database $dbachecksDatabase -Query 'update CheckResults set [date]=DATEADD(DAY, -7,[date])'


$chkResults = Invoke-DbcCheck -SqlInstance $instances -Checks $checks -ExcludeCheck $checksExclude -PassThru
$chkResults = $chkResults | Convert-DbcResult -Label 'MorningChecks'
$chkResults | Write-DbcTable -SqlInstance $dbachecksServer -Database $dbachecksDatabase

<#####################################################################>

Set-DbcConfig -Name policy.database.autoclose -Value $true
Start-DbaService -ComputerName localhost -Type Agent -Confirm:$false
Get-Service -Name *Sqlagent*, SQLSERVERAGENT | Set-service -StartupType Automatic