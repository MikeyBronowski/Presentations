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

Set-Location "C:\Tools\SQLDay2022\06_dbatools"


# nowe obiekty
$db1 = New-DbaDatabase -SqlInstance $instances -Name PowerDBA -RecoveryModel Full
$db2 = New-DbaDatabase -SqlInstance $instances -Name SQLDay2022 -RecoveryModel Full -Owner sa

$db2 | Backup-DbaDatabase -CopyOnly

#domyslna sciezka do backupu
$instances |Get-DbaDefaultPath
$($instances |Get-DbaDefaultPath).Backup

# wybrana historia backupu
$backupHistory = Get-DbaDbBackupHistory -SqlInstance $instances -IncludeCopyOnly -LastFull
$backupHistory | Format-Table



# zmien nazwy 'sa'
Rename-DbaLogin -SqlInstance $instances[2] -Login sa -NewLogin dbasa
Get-DbaLogin -SqlInstance $instances[2] | Where-Object { $_.ID -eq 1 } | Format-Table

# tworz zadanie agenta SQL 
# aktualny login jako wlasciciel
# wydruk informacji podczas tworzenia
foreach ($inst in $instances) {
  New-DbaAgentJob -SqlInstance $inst -Job "pierwsze zadanie na $inst.SqlInstance" -Description "Pierwsze zadanie"
}

# zobacz zadania
Get-DbaAgentJob -SqlInstance $instances | Format-Table -AutoSize

# usun wszystkie zadania
$null = Get-DbaAgentJob -SqlInstance $instances | Where-Object Name -like "*Sqlcollaborative.Dbatools.Discovery.Db*" | Remove-DbaAgentJob -Confirm:$false


# tworz zadanie agenta SQL 
# bez zwracania informacji ($null=)
# aktualny login jako wlasciciel
$null = New-DbaAgentJob -SqlInstance $instances -Job "pierwsze zadanie na $($inst.SqlInstance)" - -Category "Database Maintenance" -Disabled


# zobacz zadania
Get-DbaAgentJob -SqlInstance $instances | Format-Table -AutoSize

# tworz zadanie agenta SQL
# z 'sa' jako walscicielem - 'sa' moze miec dowolna nazwe, ale ma ID = 1, 0x01
foreach ($inst in $instances) {
  $null = New-DbaAgentJob -SqlInstance $inst -Job "zadanie drugie" Description "zadanie drugie" -OwnerLogin $(Get-DbaLogin -SqlInstance $inst | Where-Object { $_.ID -eq 1 }).Name
}


# zobacz zadania
Get-DbaAgentJob -SqlInstance $instances | Format-Table -AutoSize

# testuj czy wlasciciel zdania jest zgodny z domyslnym ustawieniem ('sa')
Test-DbaAgentJobOwner -SqlInstance $instances | Select-Object Server, Job, CurrentOwner, TargetOwner, OwnerMatch | Sort-Object -Propert OwnerMatch | Format-Table

# testuj czy wlasciciel zdania jest zgodny z wybranym ustawieniem ('dbasa')
Test-DbaAgentJobOwner -SqlInstance $instances -Login 'dbasa' | Select-Object Server, Job, CurrentOwner, TargetOwner, OwnerMatch | Sort-Object -Propert OwnerMatch | Format-Table


# podobnie mozna testowac wlasciciela bazy danych
# testuj czy wlasciciel zdania jest zgodny z wybranym ustawieniem ('dbasa')
Test-DbaDbowner -SqlInstance $instances | Select-Object SqlInstance, Database, CurrentOwner, TargetOwner, OwnerMatch  | Sort-Object -Propert OwnerMatch | Format-Table
Test-DbaDbowner -SqlInstance $instances -TargetLogin 'sa' | Select-Object SqlInstance, Database, CurrentOwner, TargetOwner, OwnerMatch  | Sort-Object -Propert OwnerMatch | Format-Table


# wracamy do zadan
# dodaj krok pierwszy
$null = New-DbaAgentJobStep -SqlInstance localhost -Job "pierwsze zadanie na localhost" -StepName "krok pierwszy" -Command "select @@version"

# dodaj kolejny krok
$null = New-DbaAgentJobStep -SqlInstance localhost -Job "pierwsze zadanie na localhost" -StepName "krok drugi" -Command "select @@version"

# jak wygladaja nasze zadania
Get-DbaAgentJobStep -SqlInstance localhost -Job "pierwsze zadanie na localhost" | Select-Object SqlInstance, AgentJob, Name, Id, OnSuccessAction, OnFailAction, OnFailStepId | Format-Table -AutoSize

# wstaw krok na poczatek + kilka dodatkowych ustawien
$stepSplat = @{
  StepName        = "krok zero"              
  Database        = "master"
  Subsystem       = "TransactSql"
  StepId          = "1"
  OnFailAction    = "QuitWithFailure"
  OnSuccessAction = "GoToNextStep"
  Command         = "select @@version"
  Insert          = $true             # wstawiamy krok
}
$null = New-DbaAgentJobStep @stepSplat -SqlInstance localhost -Job "pierwsze zadanie na localhost" 

# jak wygladaja nasze zadania
Get-DbaAgentJobStep -SqlInstance localhost -Job "pierwsze zadanie na localhost" | Select-Object SqlInstance, AgentJob, Name, Id, OnSuccessAction, OnFailAction, OnFailStepId | Format-Table -AutoSize

# zmien akcje dla pojedynczego kroku
$null = Set-DbaAgentJobStep -SqlInstance localhost -Job "pierwsze zadanie na localhost" -StepName "krok pierwszy" -OnSuccessAction GoToNextStep -OnFailAction GoToStep -OnFailStepId 1



# instaluj rozwiazanie Ola Hallengren'a wraz z zadaniami
# 1-2 min
$ola = Install-DbaMaintenanceSolution -SqlInstance $instances -Database SQLDay2022 -InstallJobs
# $ola = Install-DbaMaintenanceSolution -SqlInstance $instances -Database SQLDay2022 -InstallJobs -ReplaceExisting

# instaluj narzedzia spolecznosci
<#


Community Tools
Export-DbaDiagnosticQuery
Get-DbaMaintenanceSolutionLog
Install-DbaDarlingData
Install-DbaFirstResponderKit
Install-DbaMaintenanceSolution
Install-DbaMultiTooln
Install-DbaSqlWatch
Install-DbaWhoIsActive
Invoke-DbaDiagnosticQuery
Invoke-DbaWhoisActive
New-DbaDiagnosticAdsNotebook
Save-DbaCommunitySoftware
Save-DbaDiagnosticQueryScript


#>