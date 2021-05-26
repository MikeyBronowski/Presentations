<# 


   ____                       ____          _____                                     __  __               ____   __   
  / ___|_ __ ___  _   _ _ __ | __ ) _   _  | ____|   _ _ __ ___  _ __   ___          |  \/  | __ _ _   _  |___ \ / /_  
 | |  _| '__/ _ \| | | | '_ \|  _ \| | | | |  _|| | | | '__/ _ \| '_ \ / _ \  _____  | |\/| |/ _` | | | |   __) | '_ \ 
 | |_| | | | (_) | |_| | |_) | |_) | |_| | | |__| |_| | | | (_) | |_) |  __/ |_____| | |  | | (_| | |_| |  / __/| (_) |
  \____|_|  \___/ \__,_| .__/|____/ \__, | |_____\__,_|_|  \___/| .__/ \___|         |_|  |_|\__,_|\__, | |_____|\___/ 
                       |_|          |___/                       |_|                                |___/               



 #>
# setup
docker run -m=1g -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "MSSQL_AGENT_ENABLED=True" -p 1433:1433 --name sql1 -d microsoft/mssql-server-linux
docker run -m=1g -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "MSSQL_AGENT_ENABLED=True" -p 14333:1433 --name sql2 -d microsoft/mssql-server-linux

$credential = New-Object System.Management.Automation.PSCredential('sa', ('<YourStrong@Passw0rd>' | ConvertTo-SecureString -asPlainText -Force))
$PSDefaultParameterValues = @{"*:SqlCredential"=$credential
                              "*:DestinationCredential"=$credential
                              "*:DestinationSqlCredential"=$credential
                              "*:SourceSqlCredential"=$credential}

$s1 = 'localhost:1433'
$s2 = 'localhost:14333'