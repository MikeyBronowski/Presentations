<#

  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
                                                                                        


     888 888               888                      888          
     888 888               888                      888          
     888 888               888                      888          
 .d88888 88888b.   8888b.  888888  .d88b.   .d88b.  888 .d8888b  
d88" 888 888 "88b     "88b 888    d88""88b d88""88b 888 88K      
888  888 888  888 .d888888 888    888  888 888  888 888 "Y8888b. 
Y88b 888 888 d88P 888  888 Y88b.  Y88..88P Y88..88P 888      X88 
 "Y88888 88888P"  "Y888888  "Y888  "Y88P"   "Y88P"  888  88888P' 
                                                                 
                                                                 
                                                                 

                                                     
                                                     
@MikeyBronowski                                                                                                  
                                                                                               
                                                                                        

#> 

Set-Location "C:\Users\MikeyBronowski\OneDrive - Data Masterminds bv\Documents\900_Priv\SQLDay\06_dbatools"

# dbatools.io/docker
# https://github.com/dataplat/docker
# https://github.com/dataplat/docker/tree/main/samples/stackoverflow

# sciagnij obrazy
docker pull dbatools/sqlinstance
docker pull dbatools/sqlinstance2

# zatrzymaj kontenery
docker stop mssql1
docker stop mssql2

# usun kontenery
docker rm mssql1
docker rm mssql2
docker network rm localnet

# stworz dzielona siec
docker network create localnet

# uruchom kontenery
docker run -p 14331:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
docker run -p 14332:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2
docker ps -a

# haslo dla loginu = "dbatools.IO"
if (-not $credential) {
    $securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
    $credential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)
}

$PSDefaultParameterValues = @{
                              "*-Dba*:SqlCredential"=$credential
                              "*-Dba*:DestinationCredential"=$credential
                              "*-Dba*:DestinationSqlCredential"=$credential
                              "*-Dba*:SourceSqlCredential"=$credential
                              "*-Dba*:PrimarySqlCredential"=$credential
                              "*-Dba*:SecondarySqlCredential"=$credential
                            }




$sql1 = "localhost:14331"
$sql2 = "localhost:14332"
$agName = "PowerDBA_AG"

# zmiana modelu na FULL
# OSTATNI RAZ uzywamy -SqlCredential bo jest w domyslnych
Set-DbaDbRecoveryModel -SqlInstance $sql1 -SqlCredential $credential -Database pubs, Northwind -RecoveryModel Full

# kopia zapasowa
Backup-DbaDatabase -SqlInstance $sql1 -Database pubs, Northwind -Type Full -FilePath $null

# parametry AG
$params = @{
    Primary = $sql1
    Secondary = $sql2
    Name = $agName
    Database = "pubs", "Northwind"
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
 }

# stworz nowa grupe dostepnosci
New-DbaAvailabilityGroup @params
# Import-Module dbatools -MinimumVersion 1.1.89


# sprawdz grupe dostepnosci
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Format-Table

# sprawdz bazy w grupie dostepnosci
Get-DbaAgDatabase -SqlInstance $sql1 | Format-Table

Get-DbaAvailabilityGroup -SqlInstance $sql2 | Invoke-DbaAgFailover -Force -Confirm:$false
Get-DbaAvailabilityGroup -SqlInstance $sql1 | Invoke-DbaAgFailover -Force -Confirm:$false

Get-DbaAgDatabase -SqlInstance $sql1, $sql2 | Resume-DbaAgDbDataMovement -Confirm:$false


Get-DbaAgReplica -SqlInstance $sql1 | Format-Table

Get-DbaAgReplica -SqlInstance $sql1 | Set-DbaAgReplica -AvailabilityMode AsynchronousCommit
Get-DbaAgReplica -SqlInstance $sql1 | Set-DbaAgReplica -AvailabilityMode SynchronousCommit


# parametry AG2 - pusta
$params2 = @{
    Primary = $sql1
    Secondary = $sql2
    Name = ($agName+"2")
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
 }

# stworz nowa grupe dostepnosci
New-DbaAvailabilityGroup @params2

# stworz nowa baze
New-DbaDatabase -SqlInstance $sql1 -Name PowerDBA -RecoveryModel Full

# stworz wymagana kopie bazy danych.... nawet jesli faktycznie nie zapiszesz do pliku > $null
Backup-DbaDatabase -SqlInstance $sql1 -Database PowerDBA -FilePath $null

# dodaj nowa baze do nowej grupy dostepnosci
Add-DbaAgDatabase -SqlInstance $sql1 -AvailabilityGroup ($agName+"2") -Database PowerDBA -Secondary $sql2 -Verbose





# eksport obiektow
Export-DbaInstance -SqlInstance $sql1 -Exclude LinkedServers, Credentials


# migracja calej instancji
$paramsMigration = @{
    Source = $sql1
    Destination = $sql2
    BackupRestore = $true
    SharedPath = "/shared"
    Exclude = "LinkedServers", "Credentials", "BackupDevices"
    Force = $true
}

Start-DbaMigration @paramsMigration | Out-GridView



### synchronizacja loginow
$maindb = 'SQLDay2022'
$null = New-DbaDatabase -SqlInstance $sql1 -Name $maindb -RecoveryModel Full

New-DbaLogin -SqlInstance $sql1 -Login App01 -SecurePassword $securePass -Force
New-DbaDbUser -SqlInstance $sql1 -Database $maindb -Username App01 -Login App01

# kopia zapasowa bazy
Backup-DbaDatabase -SqlInstance $sql1 -Database $maindb -FilePath /var/opt/mssql/data/DB.BAK -Type Full

# kopiuj plik miedzy kontenerami z urzyciem dysku lokalnego
docker cp mssql1:/var/opt/mssql/data/DB.BAK .\
docker cp .\DB.BAK mssql2:/var/opt/mssql/data/

# odtworz kopie zapasowa na drugiej instancji
Restore-DbaDatabase -SqlInstance $sql2 -DatabaseName $maindb  -WithReplace -Path  "/var/opt/mssql/data/DB2.BAK" -DestinationFilePrefix pre # -OutputScriptOnly


# uzytkownicy niepolaczeni z loginami
# raport
Get-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# sprobuj naprawic polaczenie
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table

# moze inaczej, stworzmy brakujacy login
New-DbaLogin -SqlInstance $sql2 -Login App01 -SecurePassword $securePass -Force
Repair-DbaDbOrphanUser -SqlInstance $sql2 -Database $maindb | Format-Table


# napraw ostatecznie kopiujac login razem z identyfikatorem (SID) i haslem
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01

# jeszcze raz - niech moc bedzie z Toba
Copy-DbaLogin -Source $sql1 -Destination $sql2 -Login App01 -Force

# raport
Get-DbaDbOrphanUser -SqlInstance $s2 -Database $maindb | Format-Table






# sprzatanie
<#

Get-DbaAvailabilityGroup -SqlInstance $sql1, $sql2 -AvailabilityGroup PowerDBA_AG2 | Remove-DbaAvailabilityGroup -Confirm:$false
Get-DbaAgDatabase -SqlInstance $sql1 -AvailabilityGroup PowerDBA_AG2 | Remove-DbaAgDatabase -Confirm:$false

Get-DbaAgDatabase -SqlInstance $sql2 | Remove-DbaAgDatabase -Confirm:$false
Get-DbaDatabase -SqlInstance $sql1, $sql2 -ExcludeSystem -Status Restoring | Remove-DbaDatabase -Confirm:$false
Get-DbaAvailabilityGroup -SqlInstance $sql1, $sql2 | Remove-DbaAvailabilityGroup -Confirm:$false


#>


<#
docker builder prune -a -f
docker compose down --remove-orphans --volumes
docker rmi $(docker images -q "dbatools\/*")
#>


<#
not working properly - troubleshoot
#$ag2 = Get-DbaAvailabilityGroup -SqlInstance $sql1 -AvailabilityGroup ($agName+"2")
#Get-DbaDatabase -SqlInstance $sql1 -Database PowerDBA2 | Add-DbaAgDatabase -AvailabilityGroup $ag2 -Secondary $sql2 -Verbose
Test-DbaAvailabilityGroup -SqlInstance $sql1 -AvailabilityGroup ($agName+"2") -AddDatabase PowerDBA -Secondary $sql2
#>