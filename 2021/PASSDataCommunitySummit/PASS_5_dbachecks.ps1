<# 



  ____   _    ____ ____    ____        _           ____                                      _ _         
 |  _ \ / \  / ___/ ___|  |  _ \  __ _| |_ __ _   / ___|___  _ __ ___  _ __ ___  _   _ _ __ (_) |_ _   _ 
 | |_) / _ \ \___ \___ \  | | | |/ _` | __/ _` | | |   / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | |
 |  __/ ___ \ ___) |__) | | |_| | (_| | || (_| | | |__| (_) | | | | | | | | | | | |_| | | | | | |_| |_| |
 |_| /_/   \_\____/____/  |____/ \__,_|\__\__,_|  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, |
  ____                            _ _     ____   ___ ____  _                                       |___/ 
 / ___| _   _ _ __ ___  _ __ ___ (_) |_  |___ \ / _ \___ \/ |                                            
 \___ \| | | | '_ ` _ \| '_ ` _ \| | __|   __) | | | |__) | |                                            
  ___) | |_| | | | | | | | | | | | | |_   / __/| |_| / __/| |                                            
 |____/ \__,_|_| |_| |_|_| |_| |_|_|\__| |_____|\___/_____|_|                                            
                                                                                                         


          
                                                                        
██████╗ ██████╗  █████╗  ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗███████╗
██╔══██╗██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝██╔════╝
██║  ██║██████╔╝███████║██║     ███████║█████╗  ██║     █████╔╝ ███████╗
██║  ██║██╔══██╗██╔══██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ╚════██║
██████╔╝██████╔╝██║  ██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗███████║
╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝
                                                                        
         
                                                           


#> 
# install earlier version of pester
Install-Module Pester -RequiredVersion 4.10.1 -Force

# install dbachecks
Install-Module dbachecks -Force
# choco install dbachecks


# commands
Get-Command -Module dbachecks


# checks and configs
(Get-DbcCheck).Count   #139
(Get-DbcConfig).Count  # 236


#
Get-DbcCheck | Out-GridView
Get-DbcConfig | Out-GridView


# find the check
Get-DbcCheck -Tag High
Get-DbcCheck -Tag Agent
Get-DbcCheck -Tag RecoveryModel


# find the config
Get-DbcConfig -Name policy.database.autoclose , policy.database.autoshrink 
Get-DbcConfig -Name *ola.JobName.*



# export / config backup
# default "$script:localapp\config.json"
# !!! overwrites the file
Export-DbcConfig
Export-DbcConfig -Path C:\PASS2021\dbachecks_config.txt | ii


# change the config
Set-DbcConfig -Name policy.database.autoclose -Value $true


# examples
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Summary
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Fails
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Failed
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Passed


$checkResults = Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Passthru | Convert-DbcResult -Label PASS2021-Test 
$checkResults | Set-DbcFile -FilePath . -FileName .\PASS2021.json -FileType Json
notepad .\PASS2021.json


$checkResults | Write-DbcTable -SqlInstance $s2 -Database Mikey -Table dbachecks
Invoke-DbaQuery -SqlInstance $s2 -Database Mikey -Query "SELECT * FROM dbachecks" | ft


Invoke-DbcCheck -SqlInstance $s1,$s2 -Tags AutoClose, AutoShrink, MaxMemory -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment 'Test' -Force
Start-DbcPowerBi  


# import the config
# Import-DbcConfig

# reset the config
# Reset-DbcConfig


# https://jesspomfret.com/dbachecks-importexcel/



$testResults = Invoke-DbcCheck -SqlInstance $s1,$s2 -Check AutoClose, AutoShrink, MaxMemory -PassThru

$ConditionalFormat =$(
    New-ConditionalText -Text Failed -Range 'D:D'
)
  
$excelSplat = @{
    Path               = 'C:\PASS2021\PASSdbachecks.xlsx'
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
Set-Location C:\PASS2021
cls