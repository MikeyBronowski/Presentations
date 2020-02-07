#MSXEncryptChannelOptions
# https://docs.microsoft.com/en-us/sql/ssms/agent/set-encryption-options-on-target-servers?view=sql-server-2017
#
# 0	Disables encryption between this target server and the master server. Choose this option only when the channel between the target server and master server is secured by another means.
# 1	Enables encryption only between this target server and the master server, but no certificate validation is required.
# 2	Enables full SSL encryption and certificate validation between this target server and the master server. This setting is the default. Unless you have specific reason to choose a different value, we recommend not changing it.
# 
# https://blog.netnerds.net/2013/04/safely-enable-sql-server-agent-multiserver-administration-using-powershell/



$ComputerName = $env:COMPUTERNAME
$property = Invoke-command -computer $ComputerName {Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"}

### 2017 - DEFAULT
$InstanceName = "MSSQLSERVER" #For default "MSSQLSERVER" For Named "InstanceName" 
$KeyInstanceName = $property.$InstanceName
$KeyInstanceName

if ($InstanceName -eq "MSSQLSERVER") {
$Connection = $ComputerName
}
else {
$Connection = $ComputerName + '\' + $InstanceName
}

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-DbaQuery -SqlInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000001;"

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@value= @DIRECTORY OUTPUT;
select @DIRECTORY as MsxEncryptChannelOptions_setting_after;" | Format-Table -AutoSize



### 2014
$InstanceName = "SQL2014" #For default "MSSQLSERVER" For Named "InstanceName" 
$KeyInstanceName = $property.$InstanceName
$KeyInstanceName

if ($InstanceName -eq "MSSQLSERVER") {
$Connection = $ComputerName
}
else {
$Connection = $ComputerName + '\' + $InstanceName
}

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-DbaQuery -SqlInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000001;"

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@value= @DIRECTORY OUTPUT;
select @DIRECTORY as MsxEncryptChannelOptions_setting_after;" | Format-Table -AutoSize

### 2016
$InstanceName = "SQL2016" #For default "MSSQLSERVER" For Named "InstanceName" 
$KeyInstanceName = $property.$InstanceName
$KeyInstanceName

if ($InstanceName -eq "MSSQLSERVER") {
$Connection = $ComputerName
}
else {
$Connection = $ComputerName + '\' + $InstanceName
}

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-DbaQuery -SqlInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000001;"

Invoke-DbaQuery -SqlInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@value= @DIRECTORY OUTPUT;
select @DIRECTORY as MsxEncryptChannelOptions_setting_after;" | Format-Table -AutoSize





# Fix the encryption for SQL 2019
#Invoke-DbaQuery -SqlInstance 'DC01\SQL2019' -Query "EXEC master..xp_regwrite @rootkey=N'HKEY_LOCAL_MACHINE', @key=N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQL2019\SQLServerAgent', @value_name=N'MsxEncryptChannelOptions', @type=N'REG_DWORD', @value=000000001" | Format-Table -AutoSize

