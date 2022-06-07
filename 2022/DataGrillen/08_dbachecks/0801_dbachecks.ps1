<#


 

 
     888 888                        888                        888               
     888 888                        888                        888               
     888 888                        888                        888               
 .d88888 88888b.   8888b.   .d8888b 88888b.   .d88b.   .d8888b 888  888 .d8888b  
d88" 888 888 "88b     "88b d88P"    888 "88b d8P  Y8b d88P"    888 .88P 88K      
888  888 888  888 .d888888 888      888  888 88888888 888      888888K  "Y8888b. 
Y88b 888 888 d88P 888  888 Y88b.    888  888 Y8b.     Y88b.    888 "88b      X88 
 "Y88888 88888P"  "Y888888  "Y8888P 888  888  "Y8888   "Y8888P 888  888  88888P' 
                                                                                 
                                                                                 
                                                                                 
                                
                                 
                                 
#>
Set-Location C:\Tools\DataGrillen

# older Pester version required
# install module
Get-Module -Name Pester -ListAvailable | Uninstall-Module -Force
Install-Module Pester -RequiredVersion 4.10.1 -Force
Import-Module Pester -RequiredVersion 4.10.1 -Force

# install module
Install-Module dbachecks -Force
Import-Module dbachecks -Force
# choco install dbachecks


# commands
Get-Command -Module dbachecks


# checks and configs
(Get-DbcCheck).Count   # 139
(Get-DbcConfig).Count  # 236


Get-DbcCheck | Out-GridView
Get-DbcConfig | Out-GridView


# find check by tag
Get-DbcCheck -Tag High
Get-DbcCheck -Tag Agent
Get-DbcCheck -Tag RecoveryModel


# find config
Get-DbcConfig -Name policy.database.autoclose , policy.database.autoshrink 
Get-DbcConfig -Name *ola.JobName.*



# config export
# default "$script:localapp\config.json"
# !!! overwrites !!!
Export-DbcConfig
Export-DbcConfig -Path C:\Tools\DataGrillen\dbachecks_config.txt -Force | Invoke-Item


# set config values
Set-DbcConfig -Name policy.database.autoclose -Value $true

# import config
# Import-DbcConfig

# reset config
# Reset-DbcConfig



# examples of invoking the tests
$instances = Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Summary
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Fails
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Failed
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Show Passed


$checkResults = Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $instances -Passthru | Convert-DbcResult -Label SQLDay2022-Test 
$checkResults | Set-DbcFile -FilePath . -FileName .\dbachecks.json -FileType Json
notepad .\dbachecks.json

$null = New-DbaDatabase -SqlInstance localhost -Database dbachecks
$checkResults | Write-DbcTable -SqlInstance localhost -Database dbachecks -Table dbachecks
Invoke-DbaQuery -SqlInstance localhost -Database dbachecks -Query "SELECT * FROM dbachecks" | Format-Table


Invoke-DbcCheck -SqlInstance $instances,$s2 -Tags AutoClose, AutoShrink, MaxMemory -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment 'Test' -Force
Start-DbcPowerBi  








# present tests as Excel spreadsheet
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
cls