#################################
# MSX/TSX - Master/Target servers in SSMS
#################################
#
#
#
# Set the MASTER name and target servers
Clear-Variable MSX, Reg04, Reg06, Reg09
$MSX = 'DC01'             # SQL 2017
$Reg04 = 'DC01\SQL2014'   # SQL 2014
$Reg06 = 'DC01\SQL2016'   # SQL 2016
$Reg09 = 'DC01\SQL2019'   # SQL 2019
Get-Variable -Name 'MSX', 'Reg*'
#
#
#
# Add the groups/sub-groups
#
#
#
# Register the servers in CMS
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg04 -Group 03_PROD\IT_Current -Description 'Legacy server'
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg06 -Group 03_PROD\IT_Current -Description 'Current server'
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg09 -Group 03_PROD\IT_POC -Description 'New server'
Add-DbaRegServer -SqlInstance $CMS -ServerName $Reg09 -Name $ServerName03
#
#
#
# Check the SSMS