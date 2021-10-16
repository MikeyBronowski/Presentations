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
Export-DbcConfig -Path C:\Temp\dbachecks_config.json | ii


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


Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Passthru | Convert-DbcResult -Label DataSaturdayMinnesota-Test | Set-DbcFile -FilePath . -FileName .\DataSaturdayMinnesota2021.json -FileType Json
ii .\DataSaturdayMinnesota.json


Invoke-DbcCheck -Check AutoClose, AutoShrink, MaxMemory -SqlInstance $s1 -Passthru | Convert-DbcResult -Label DataSaturdayMinnesota-Test | Write-DbcTable -SqlInstance $s2 -Database Mikey -Table dbachecks
Invoke-DbaQuery -SqlInstance $s2 -Database Mikey -Query "SELECT * FROM dbachecks" | ft



Invoke-DbcCheck -SqlInstance $s1,$s2 -Tags AutoClose, AutoShrink, MaxMemory -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment 'Test' -Force
Start-DbcPowerBi  




# https://jesspomfret.com/dbachecks-importexcel/



$testResults = Invoke-DbcCheck -SqlInstance $s1,$s2 -Check AutoClose, AutoShrink, MaxMemory -PassThru

$ConditionalFormat =$(
    New-ConditionalText -Text Failed -Range 'D:D'
)
  
$excelSplat = @{
    Path               = 'C:\Temp\DataSatMN.xlsx'
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