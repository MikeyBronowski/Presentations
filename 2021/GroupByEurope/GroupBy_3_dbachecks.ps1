<# 


   ____                       ____          _____                                     __  __               ____   __   
  / ___|_ __ ___  _   _ _ __ | __ ) _   _  | ____|   _ _ __ ___  _ __   ___          |  \/  | __ _ _   _  |___ \ / /_  
 | |  _| '__/ _ \| | | | '_ \|  _ \| | | | |  _|| | | | '__/ _ \| '_ \ / _ \  _____  | |\/| |/ _` | | | |   __) | '_ \ 
 | |_| | | | (_) | |_| | |_) | |_) | |_| | | |__| |_| | | | (_) | |_) |  __/ |_____| | |  | | (_| | |_| |  / __/| (_) |
  \____|_|  \___/ \__,_| .__/|____/ \__, | |_____\__,_|_|  \___/| .__/ \___|         |_|  |_|\__,_|\__, | |_____|\___/ 
                       |_|          |___/                       |_|                                |___/               

          
                                                                        
██████╗ ██████╗  █████╗  ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗███████╗
██╔══██╗██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝██╔════╝
██║  ██║██████╔╝███████║██║     ███████║█████╗  ██║     █████╔╝ ███████╗
██║  ██║██╔══██╗██╔══██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ╚════██║
██████╔╝██████╔╝██║  ██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗███████║
╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝
                                                                        
         
                                                           


#> 


# Install-Module dbachecks
# choco install dbachecks


# commands
Get-Command -Module dbachecks


# checks and configs
(Get-DbcCheck).Count   #136
(Get-DbcConfig).Count  # 233


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
Export-DbcConfig -Path "$env:TEMP\dbachecks_config.json" | ii


# change the config
Set-DbcConfig -Name policy.database.autoclose -Value $true


# examples
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Summary
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Fails
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Failed
Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Show Passed


# import the config
Import-DbcConfig

# reset the config
Reset-DbcConfig


Convert-DbcResult


Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Passthru | Convert-DbcResult -Label SQLDay-Test | Set-DbcFile -FilePath . -FileName .\SQLDay2021.json -FileType Json
ii .\SQLDay2021.json


Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Passthru | Convert-DbcResult -Label SQLDay-Test | Write-DbcTable -SqlInstance $s2 -Database Mikey -Table dbachecks
Invoke-DbaQuery -SqlInstance $s2 -Database Mikey -Query "SELECT * FROM dbachecks" | ft



Invoke-DbcCheck -SqlInstance $s1,$s2 -Tags AutoClose, AutoShrink, MaxMemory -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment 'Test' -Force
Start-DbcPowerBi  




# https://jesspomfret.com/dbachecks-importexcel/



$testResults = Invoke-DbcCheck -SqlInstance $s1,$s2 -Check AutoClose, AutoShrink, MaxMemory -PassThru

$ConditionalFormat =$(
    New-ConditionalText -Text Failed -Range 'D:D'
)
  
$excelSplat = @{
    Path               = 'C:\Temp\GroupBy.xlsx'
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