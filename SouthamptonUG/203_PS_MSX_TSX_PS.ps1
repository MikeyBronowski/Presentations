#################################
# MSX/TSX - Master/Target servers with Powershell
#################################
#
#
#
# Check the SSMS
#
#
#
# Create target servers / master server
Write-Host ' > > > > > > Check existing TSX servers:' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > SELECT * FROM msdb.dbo.SysTargetServers;' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $MSX -Query "SELECT @@SERVERNAME SqlInstance, server_name, enlist_date, poll_interval FROM msdb.dbo.SysTargetServers;" | FT
Start-Sleep -Seconds 5

Write-Host ' > > > > > > Trying to enlist the default installation: ' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > EXEC msdb.dbo.sp_msx_enlist $MSX;' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $Reg09 -Query "EXEC msdb.dbo.sp_msx_enlist N'$MSX';"
Start-Sleep -Seconds 5

Write-Host ' > > > > > > Need a target service account with permission on master' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > TargetServerRole in msdb' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $MSX -Query "USE [master];CREATE LOGIN [DOMAIN\SA19] FROM WINDOWS WITH DEFAULT_DATABASE=[master];
USE [msdb];CREATE USER [DOMAIN\SA19] FOR LOGIN [DOMAIN\SA19];
ALTER ROLE [TargetServersRole] ADD MEMBER [DOMAIN\SA19];"

Write-Host ' > > > > > > Trying to enlist with proper permission' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > EXEC msdb.dbo.sp_msx_enlist $MSX;' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $Reg09 -Query "EXEC msdb.dbo.sp_msx_enlist N'$MSX';"
Start-Sleep -Seconds 5
Write-Host ' > > > > > > Need to set the MsxEncryptChannelOptions option' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > MsxEncryptChannelOptions @value=000000001' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $Reg09 -Query "EXEC master..xp_regwrite @rootkey=N'HKEY_LOCAL_MACHINE', 
@key=N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQL2019\SQLServerAgent', @value_name=N'MsxEncryptChannelOptions', 
@type=N'REG_DWORD', @value=000000001"

Invoke-DbaQuery -SqlInstance $Reg09 -Query "DECLARE @DIRECTORY INT
EXEC master..xp_regread
@rootkey = N'HKEY_LOCAL_MACHINE',
@key = N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQL2019\SQLServerAgent',
@value_name = N'MsxEncryptChannelOptions',
@value = @DIRECTORY OUTPUT;
SELECT @DIRECTORY AS MsxEncryptChannelOptions;" | Format-Table -AutoSize

#Start-Sleep -Seconds 15
$restart = Restart-DbaService -ComputerName localhost -Type Agent -InstanceName SQL2019
Write-Host ' > > > > > > Now should work' -ForegroundColor red -BackgroundColor yellow
Write-Host ' > > > > > > EXEC msdb.dbo.sp_msx_enlist $MSX;' -ForegroundColor red -BackgroundColor yellow
Invoke-DbaQuery -SqlInstance $Reg09 -Query "EXEC msdb.dbo.sp_msx_enlist N'$MSX';"
Invoke-DbaQuery -SqlInstance $MSX -Query "SELECT @@SERVERNAME SqlInstance, server_name, enlist_date, poll_interval FROM msdb.dbo.SysTargetServers;" | FT
