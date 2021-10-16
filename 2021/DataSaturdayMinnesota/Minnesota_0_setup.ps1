<# 


  
  _____            _              _____           _                        _                   
 |  __ \          | |            / ____|         | |                      | |                  
 | |  | |   __ _  | |_    __ _  | (___     __ _  | |_   _   _   _ __    __| |   __ _   _   _   
 | |  | |  / _` | | __|  / _` |  \___ \   / _` | | __| | | | | | '__|  / _` |  / _` | | | | |  
 | |__| | | (_| | | |_  | (_| |  ____) | | (_| | | |_  | |_| | | |    | (_| | | (_| | | |_| |  
 |_____/   \__,_|  \__|  \__,_| |_____/   \__,_|  \__|  \__,_| |_|     \__,_|  \__,_|  \__, |  
 |  \/  | (_)                                      | |                                  __/ |  
 | \  / |  _   _ __    _ __     ___   ___    ___   | |_    __ _                        |___/   
 | |\/| | | | | '_ \  | '_ \   / _ \ / __|  / _ \  | __|  / _` |                               
 | |  | | | | | | | | | | | | |  __/ \__ \ | (_) | | |_  | (_| |                               
 |_|  |_| |_| |_| |_| |_| |_|  \___| |___/  \___/   \__|  \__,_|                               
                                                                                               
                                                                                               




 #>

# setup
Set-ExecutionPolicy Bypass -Scope Process
Import-Module "$env:OneDrive\learn\dbatools\dbatools.psd1" -Force
Import-Module "$env:OneDrive\GIT\dbachecks\dbachecks.psd1" -Force
#load assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
#Need SmoExtended for backup
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

docker stop sql1, sql2, sql3
docker rm sql1, sql2, sql3

docker run -m=1g -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "MSSQL_AGENT_ENABLED=True" -p 1433:1433 --name sql1 -d microsoft/mssql-server-linux
docker run -m=1g -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "MSSQL_AGENT_ENABLED=True" -p 14333:1433 --name sql2 -d microsoft/mssql-server-linux
docker run -m=2g -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "MSSQL_AGENT_ENABLED=True" -p 14335:1433 --name sql3 -d mcr.microsoft.com/mssql/server:2019-CU13-ubuntu-20.04

docker ps -a

$securePass = ('<YourStrong@Passw0rd>' | ConvertTo-SecureString -asPlainText -Force)
$credential = New-Object System.Management.Automation.PSCredential('sa', $securePass)
$PSDefaultParameterValues = @{"*:SqlCredential"=$credential
                              "*:DestinationCredential"=$credential
                              "*:DestinationSqlCredential"=$credential
                              "*:SourceSqlCredential"=$credential}

$s1 = 'localhost:1433'
$s2 = 'localhost:14333'
$s3 = 'localhost:14335'

#Connect-DbaInstance -SqlInstance $s3 -SqlCredential $credential