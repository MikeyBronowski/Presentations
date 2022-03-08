$resourceGroupGet = Get-AzResourceGroup @resourceGroupArgs

$server0Get = Get-AzSqlServer -ResourceGroupName $resourceGroupGet.ResourceGroupName -ServerName $server0Name
$server1Get = Get-AzSqlServer -ResourceGroupName $resourceGroupGet.ResourceGroupName -ServerName $server1Name
$server2Get = Get-AzSqlServer -ResourceGroupName $resourceGroupGet.ResourceGroupName -ServerName $server2Name


$myIp = Invoke-RestMethod -Uri https://api.ipify.org
$random=Get-Random
$firewallMyIpArgs = @{
    FirewallRuleName = "Firewall rule - Let me in_"+$($random)
    StartIpAddress = $myIp 
    EndIpAddress = $myIp 
    ResourceGroupName = $resourceGroupGet.ResourceGroupName
}

$firewallMyIp0 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server0Get.ServerName
$firewallMyIp1 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server1Get.ServerName
$firewallMyIp2 = New-AzSqlServerFirewallRule @firewallMyIpArgs -ServerName $server2Get.ServerName