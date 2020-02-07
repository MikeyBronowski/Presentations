#MSXEncryptChannelOptions
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

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-Sqlcmd -ServerInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000002";

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
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

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-Sqlcmd -ServerInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000002";

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
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

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-Sqlcmd -ServerInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000002";

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@value= @DIRECTORY OUTPUT;
select @DIRECTORY as MsxEncryptChannelOptions_setting_after;" | Format-Table -AutoSize

### 2019
$InstanceName = "SQL2019" #For default "MSSQLSERVER" For Named "InstanceName" 
$KeyInstanceName = $property.$InstanceName
$KeyInstanceName

if ($InstanceName -eq "MSSQLSERVER") {
$Connection = $ComputerName
}
else {
$Connection = $ComputerName + '\' + $InstanceName
}

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions_setting_before;" | Format-Table -AutoSize

Invoke-Sqlcmd -ServerInstance $Connection -Query "EXEC master..xp_regwrite
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@type=N'REG_DWORD',
@value=00000002";

Invoke-Sqlcmd -ServerInstance $Connection -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey=N'HKEY_LOCAL_MACHINE',
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\$KeyInstanceName\SQLServerAgent',
@value_name=N'MsxEncryptChannelOptions',
@value= @DIRECTORY OUTPUT;
select @DIRECTORY as MsxEncryptChannelOptions_setting_after;" | Format-Table -AutoSize


