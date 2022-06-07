## Dbachecks Database Connection
$instances = 'localhost'
$dbachecksServer = 'localhost'
$dbachecksDatabase = 'dbachecks'


$checks = "Agent","Database"


$chkResults = Invoke-DbcCheck -SqlInstance $instances -Checks $checks -PassThru
$chkResults = $chkResults | Convert-DbcResult -Label 'MorningChecks' 
$chkResults | Write-DbcTable -SqlInstance $dbachecksServer -Database $dbachecksDatabase



  # run t-sql on localhost
  # https://www.brentozar.com/blitz/configure-sql-server-alerts/

Invoke-DbaQuery -SqlInstance $dbachecksServer -Database $dbachecksDatabase -Query 'update CheckResults set [date]=DATEADD(DAY, -7,[date])'


# Start-DbcPowerBi -FromDatabase