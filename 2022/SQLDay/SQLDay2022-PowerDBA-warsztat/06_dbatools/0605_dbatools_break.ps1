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


$sqlInstances = Find-DbaInstance -ComputerName localhost

# zmien maksymalne ustawienie pamieci
Set-DbaMaxMemory -SqlInstance $sqlInstances -Max 512MB

# zmien nazwy 'sa'
Rename-DbaLogin -SqlInstance $sqlInstances[2] -Login sa -NewLogin dbasa
Get-DbaLogin -SqlInstance $sqlInstances[2] | Where-Object { $_.ID -eq 1 } | Format-Table

# tworz nowa baze
New-DbaDatabase -SqlInstance $sqlInstances -Database SQLDay2022
Get-DbaDatabase -SqlInstance $sqlInstances -Database SQLDay2022 | Format-Table

# sprawdz status uslug
Get-DbaService -ComputerName localhost -Type Agent, Engine | Format-Table

# wystartuj uslugi status uslug
Get-DbaService -ComputerName localhost -Type Agent, Engine | Start-DbaService


# tworz zadanie agenta SQL 
# aktualny login jako wlasciciel
# wydruk informacji podczas tworzenia
foreach ($SqlInstance in $sqlInstances) {
    New-DbaAgentJob -SqlInstance $SqlInstance -Job "pierwsze zadanie na $SqlInstance.SqlInstance" -Description "Pierwsze zadanie"
}

# usun wszystkie zadania
$null = Get-DbaAgentJob -SqlInstance $sqlInstances | Where-Object Name -like "*Sqlcollaborative.Dbatools.Discovery.Db*" | Remove-DbaAgentJob -Confirm:$false


# tworz zadanie agenta SQL 
# bez zwracania informacji ($null=)
# z 'sa' jako walscicielem - 'sa' moze miec dowolna nazwe, ale ma ID = 1, 0x01
foreach ($SqlInstance in $sqlInstances) {
    $null = New-DbaAgentJob -SqlInstance $SqlInstance -Job "pierwsze zadanie na $($SqlInstance.SqlInstance)" -OwnerLogin $(Get-DbaLogin -SqlInstance $SqlInstance | Where-Object { $_.ID -eq 1 }).Name
}


# zobacz zadania
Get-DbaAgentJob -SqlInstance $sqlInstances | Format-Table -AutoSize

# tworz zadanie agenta SQL
# aktualny login jako wlasciciel
$null = New-DbaAgentJob -SqlInstance $sqlInstances -Job "zadanie drugie" -Description "zadanie drugie" -Category "Database Maintenance" -Disabled


# zobacz zadania
Get-DbaAgentJob -SqlInstance $sqlInstances | Format-Table -AutoSize

# testuj czy wlasciciel zdania jest zgodny z domyslnym ustawieniem ('sa')
Test-DbaAgentJobOwner -SqlInstance $sqlInstances | Select-Object SqlInstance, JobName, CurrentOwner, TargetOwner, OwnerMatch | Sort-Object -Propert OwnerMatch | Format-Table

# testuj czy wlasciciel zdania jest zgodny z wybranym ustawieniem ('dbasa')
Test-DbaAgentJobOwner -SqlInstance $sqlInstances -Login 'dbasa' | Select-Object SqlInstance, JobName, CurrentOwner, TargetOwner, OwnerMatch  | Sort-Object -Propert OwnerMatch | Format-Table


# podobnie mozna testowac wlasciciela bazy danych
# testuj czy wlasciciel zdania jest zgodny z wybranym ustawieniem ('dbasa')
Test-DbaDbowner -SqlInstance $sqlInstances | Select-Object SqlInstance, Database, CurrentOwner, TargetOwner, OwnerMatch  | Sort-Object -Propert OwnerMatch | Format-Table
Test-DbaDbowner -SqlInstance $sqlInstances -TargetLogin 'sa' | Select-Object SqlInstance, Database, CurrentOwner, TargetOwner, OwnerMatch  | Sort-Object -Propert OwnerMatch | Format-Table


# wracamy do zadan
# dodaj krok pierwszy
$null = New-DbaAgentJobStep -SqlInstance $sqlInstances[0] -Job "pierwsze zadanie na localhost\DSC" -StepName "krok pierwszy" -Command "select @@version"

# dodaj kolejny krok
$null = New-DbaAgentJobStep -SqlInstance $sqlInstances[0] -Job "pierwsze zadanie na localhost\DSC" -StepName "krok drugi" -Command "select @@version"

# jak wygladaja nasze zadania
Get-DbaAgentJobStep -SqlInstance $sqlInstances[0] -Job "pierwsze zadanie na localhost\DSC" | Select-Object SqlInstance, AgentJob, Name, Id, OnSuccessAction, OnFailAction, OnFailStepId | Format-Table -AutoSize

# wstaw krok na poczatek + kilka dodatkowych ustawien
$stepSplat = @{
    StepName        = "krok zero"              
    Database        = "master"
    Subsystem       = "TransactSql"
    StepId          = "1"
    OnFailAction    = "QuitWithFailure"
    OnSuccessAction = "GoToNextStep"
    Command         = "select @@version"
    Insert          = $true
}
$null = New-DbaAgentJobStep @stepSplat -SqlInstance $sqlInstances[0] -Job "pierwsze zadanie na localhost\DSC" 


# zmien akcje dla pojedynczego kroku
$null = Set-DbaAgentJobStep -SqlInstance $sqlInstances[0] -Job "pierwsze zadanie na localhost\DSC" -StepName "krok pierwszy" -OnSuccessAction GoToNextStep -OnFailAction GoToStep -OnFailStepId 1


# instaluj rozwiazanie Ola Hallengren'a wraz z zadaniami
Install-DbaMaintenanceSolution -SqlInstance $sqlInstances -InstallJobs -ReplaceExisting
Install-DbaMaintenanceSolution -SqlInstance $sqlInstances -InstallJobs -Database SQLDay2022 -ReplaceExisting

# zobacz zadania
Get-DbaAgentJob -SqlInstance $sqlInstances | Format-Table -AutoSize
Get-DbaAgentJob -SqlInstance $sqlInstances | start-dbaagentjob


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






#### Czysc
<#

    Get-DbaDatabase -SqlInstance $sqlInstances -Database SQLDay2022 | Remove-DbaDatabase -Confirm:$false
    Get-DbaAgentJob -SqlInstance $sqlInstances | Remove-DbaAgentJob -Confirm:$false
#>