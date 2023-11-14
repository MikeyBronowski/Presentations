<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|    
 

 
     888 888                        888                        888               
     888 888                        888                        888               
     888 888                        888                        888               
 .d88888 88888b.   8888b.   .d8888b 88888b.   .d88b.   .d8888b 888  888 .d8888b  
d88" 888 888 "88b     "88b d88P"    888 "88b d8P  Y8b d88P"    888 .88P 88K      
888  888 888  888 .d888888 888      888  888 88888888 888      888888K  "Y8888b. 
Y88b 888 888 d88P 888  888 Y88b.    888  888 Y8b.     Y88b.    888 "88b      X88 
 "Y88888 88888P"  "Y888888  "Y8888P 888  888  "Y8888   "Y8888P 888  888  88888P' 
                                                                                 
                                                                                 
                                                                                 
                                
                                 
                                 
#>


# runs on pester 5.x
# install and import pester module
Get-Module -Name Pester -ListAvailable
Install-Module Pester
Import-Module Pester

# install dbachecks module
Install-Module -Name dbachecks -AllowPrerelease -Force
Import-Module dbachecks

# can be installed with chocolatey
# choco install dbachecks


# commands
Get-Command -Module dbachecks
(Get-Command -Module dbachecks).Count   # 21

# tests and configuration
# # how many ?
(Get-DbcCheck).Count   # 139 v2 / 140 v3
(Get-DbcConfig).Count  # 236 v2 / 317 v3


# # what ?
Get-DbcCheck | Out-GridView
Get-DbcConfig | Out-GridView


# search by tag
Get-DbcCheck -Tag High
Get-DbcCheck -Tag Agent
Get-DbcCheck -Tag RecoveryModel


# find config
Get-DbcConfig -Name policy.database.autoclose , policy.database.autoshrink 
Get-DbcConfig -Name *ola.JobName.*


# export config
# default "$script:localapp\config.json"
# "$((Get-DbcConfig app.localapp).Value)\config.json"
Export-DbcConfig
Export-DbcConfig -Path C:\Tools\PowerDBA\dbachecks_config.txt -Force | Invoke-Item


# change config value
Set-DbcConfig -Name policy.database.autoclose -Value $true

# load config
# Import-DbcConfig

# reset config to default values
# Reset-DbcConfig



# examples of running tests
$instances = Find-DbaInstance -ComputerName localhost # -ScanType Browser, SqlConnect
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Legacy:$false -Verbose

# get examples of running tests
Get-Help Invoke-DbcCheck -Examples

# get help for specific test
Get-Help Invoke-DbcCheck -Parameter Check

# write a powershell function to add two numbers

function Add-Numbers {
    param (
        [Parameter(Mandatory)]
        [int]$a,
        [Parameter(Mandatory)]
        [int]$b
    )
    $a + $b
}

# get help for specific test
`
$PSDefaultParameterValues.Add("Invoke-DbcCheck:Legacy",$False)
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Summary
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Fails
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Failed
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Passed


$checkResults = Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Passthru | Convert-DbcResult -Label PowerDBAv5 
$checkResults | Set-DbcFile -FilePath . -FileName .\PowerDBAv5.json -FileType Json
notepad .\PowerDBAv5.json

$null = New-DbaDatabase -SqlInstance localhost -Database dbachecksv5
$checkResults | Write-DbcTable -SqlInstance localhost -Database dbachecksv5 -Table dbachecksv5
Invoke-DbaQuery -SqlInstance localhost -Database dbachecksv5 -Query "SELECT * FROM dbachecksv5" | Format-Table


Invoke-DbcCheck -SqlInstance $instances,$s2 -Tags AutoClose, AutoShrink, MaxMemory -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment 'Test' -Force
Start-DbcPowerBi  








# wyniki testów dbacheck jako arkusz Excela
# https://jesspomfret.com/dbachecks-importexcel/



$testResults = Invoke-DbcCheck -SqlInstance $instances, $s2 -Check AutoClose, AutoShrink, MaxMemory -PassThru

$ConditionalFormat =$(
    New-ConditionalText -Text Failed -Range 'D:D'
)
  
$excelSplat = @{
    Path               = 'C:\Tools\SQLDay2022\dbachecks.xlsx'
    WorkSheetName      = 'TestResults'
    TableName          = 'Results'
    Autosize           = $true
    ConditionalFormat  = $ConditionalFormat
    IncludePivotTable  = $true
    PivotRows          = 'Describe'
    PivotData          = @{Describe='Count'}
    PivotColumns       = 'Result'
    IncludePivotChart  = $true
    ChartType          = 'ColumnStacked'
}
  
$testResults.TestResult |
Select-Object Describe, Context, Name, Result, FailureMessage |
Export-Excel @excelSplat -Show


# clear screen
Set-Location C:\Tools\SQLDay2022
cls