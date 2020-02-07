# CLEANUP - remove target from MSX
Invoke-DbaQuery -SqlInstance $Reg04 -Query "EXEC msdb.dbo.sp_msx_defect;"
Invoke-DbaQuery -SqlInstance $MSX -Query "EXEC msdb.dbo.sp_delete_targetserver 
    @server_name = '$Reg04', 
    @post_defection =  0;"

Invoke-DbaQuery -SqlInstance $MSX -Query "USE [msdb]; DROP USER [DOMAIN\SA14]; DROP LOGIN [DOMAIN\SA14];"

Invoke-DbaQuery -SqlInstance $Reg06 -Query "EXEC msdb.dbo.sp_msx_defect;"
Invoke-DbaQuery -SqlInstance $MSX -Query "EXEC msdb.dbo.sp_delete_targetserver 
    @server_name = '$Reg06', 
    @post_defection =  0;"


Invoke-DbaQuery -SqlInstance $MSX -Query "USE [msdb]; DROP USER [DOMAIN\SA16];DROP LOGIN [DOMAIN\SA16];"


Invoke-DbaQuery -SqlInstance $Reg09 -Query "EXEC msdb.dbo.sp_msx_defect;"
Invoke-DbaQuery -SqlInstance $MSX -Query "EXEC msdb.dbo.sp_delete_targetserver 
    @server_name = '$Reg09', 
    @post_defection =  0;"

Invoke-DbaQuery -SqlInstance $MSX -Query "USE [msdb]; DROP USER [DOMAIN\SA19];DROP LOGIN [DOMAIN\SA19];"

Invoke-DbaQuery -SqlInstance $Reg04, $Reg06, $Reg09 -Query "EXEC msdb.dbo.sp_delete_operator @name = 'MSXOperator';"

#
#
#
# cleanup CMS
Get-DbaRegServerGroup -SqlInstance $CMS `
    | Remove-DbaRegServerGroup -Confirm:$false
Get-DbaRegServer -SqlInstance $CMS `
    | Remove-DbaRegServer -Confirm:$false
Get-DbaRegServerGroup -SqlInstance $CMS
Get-DbaRegServer -SqlInstance $CMS

$SecurePassword = ConvertTo-SecureString 'Artur9102!' -AsPlainText -Force
#Get-DbaService -ComputerName DC01 -Type Agent -Instance SQL2019 | Update-DbaServiceAccount -Username 'sa19@domain.org' -SecurePassword $SecurePassword

cd 'C:\Users\Administrator\Documents\Data Scotland 2019\Data Scotland 2019\Data Scotland 2019'
&'.\922_PS_MSX_TSX_EncryptionChannel_Revert.ps1'

#Restart-DbaService -ComputerName localhost -Type Agent
