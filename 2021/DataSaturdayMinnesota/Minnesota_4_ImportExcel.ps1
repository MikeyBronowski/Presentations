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

                           
                                                                                        
██╗███╗   ███╗██████╗  ██████╗ ██████╗ ████████╗███████╗██╗  ██╗ ██████╗███████╗██╗     
██║████╗ ████║██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║     
██║██╔████╔██║██████╔╝██║   ██║██████╔╝   ██║   █████╗   ╚███╔╝ ██║     █████╗  ██║     
██║██║╚██╔╝██║██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══╝   ██╔██╗ ██║     ██╔══╝  ██║     
██║██║ ╚═╝ ██║██║     ╚██████╔╝██║  ██║   ██║   ███████╗██╔╝ ██╗╚██████╗███████╗███████╗
╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝
                                                                                        

#> 

# Install-Module -Name ImportExcel



# location
Set-Location $env:TEMP
# Invoke-Item $env:TEMP

# remove old files
$excelFiles = "MikeyMinnesotaMN2021_11.xlsx","MikeyMinnesotaMN2021_12.xlsx","MikeyMinnesotaMN2021_13.xlsx","MikeyMinnesotaMN2021_14.xlsx","MikeyMinnesotaMN2021_15.xlsx"
Remove-Item $excelFiles -ErrorAction SilentlyContinue


# new sheet
$excelFile = $excelFiles[0]

$commands = Get-Command -Module ImportExcel 
$commands | SELECT Name | Export-Excel -Path $excelFile -KillExcel


$excel = Open-ExcelPackage -Path $excelFile -KillExcel

# add an extra sheet to the end
Add-Worksheet -ExcelPackage $excel -WorksheetName Process -MoveToEnd


$process = Get-Process | SELECT Name, PriorityClass, CPU, Company -First 50
$process | Export-Excel -ExcelPackage $excel -WorksheetName Process -TableName NewNamedTableForMikey -AutoSize -FreezeTopRow -FreezeFirstColumn



# add pivot table
$excel = Open-ExcelPackage -Path $excelFile -KillExcel
Add-PivotTable -ExcelPackage $excel -PivotRows Name -PivotColumns PriorityClass -PivotData @{'CPU' = 'sum'; 'Company' = 'count'} -SourceWorkSheet Process -PivotTableName 'Pivot' -Activate


# save and open the files
Close-ExcelPackage -ExcelPackage $excel -Show




# add conditional formatting
$excelFile = $excelFiles[1]
Remove-Item $excelFile -ErrorAction SilentlyContinue

$events = Get-EventLog -After (Get-Date -Format 'yyyy-MM-dd') -LogName system | SELECT EventID, Category, EntryType -First 50

# define conditional formatting for each column in a new worksheet
# these are random formats, just to show the capability
$ConditionalFormat =$(
    New-ConditionalText -ConditionalType AboveAverage -Range 'A:A' -BackgroundColor Red -ConditionalTextColor Black
    New-ConditionalText -ConditionalType DuplicateValues -Range 'B:B' -BackgroundColor Orange -ConditionalTextColor Black
    New-ConditionalText -Text Information -Range 'C:C' -BackgroundColor Blue -ConditionalTextColor Yellow
)

# 
$events | Export-Excel -WorksheetName EventsConditional -TableName EventsConditional -Path $excelFile -ConditionalFormat $ConditionalFormat -AutoSize -Activate -KillExcel  -Show


# quarters
$ConditionalFormat3 =$(
    New-ConditionalFormattingIconSet -Range A2:A6 -ConditionalFormat FiveIconSet -IconType Quarters
)
# add a new table
"L",1,2,3,4,5 | Export-Excel -WorksheetName EventsIcons -TableName EventsConditional3 -Path $excelFile -ConditionalFormat $ConditionalFormat3 -Activate -KillExcel -Show




$excelFile = $excelFiles[2]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# new data
$math = @()
for ($i=0;$i -lt 361; $i++) {
    $r = $i/180*3.14
    $math += [pscustomobject]@{ Angle = $i; Sin = [math]::Sin($r); Cos = [math]::Cos($r) }
}




# 
$excelFile = $excelFiles[2]
$math | Export-Excel -Path $excelFile -WorksheetName Math -AutoSize -TableName Math -KillExcel

# define the chart
$chartDef2 = New-ExcelChartDefinition -Title 'Sin(x)/Cos(x)' `
    -ChartType Line   `
    -XRange "Math[Angle]" `
    -YRange @("Math[Cos]","Math[Sin]") `
    -SeriesHeader 'Cos(x)','Sin(x)'`
    -Row 0 -Column 0

# add it to the spreadsheet
Export-Excel -Path $excelFile -WorksheetName MathChart -ExcelChartDefinition $chartDef2 -Activate -Show




$excelFile = $excelFiles[3]

# download data from the SQL server with dbatools
$SQLresults = Invoke-DbaQuery -SqlInstance $s1 -Database msdb -Query 'SELECT * FROM backupset;'

# export SQL data into Excel worksheet (importExcel)
$SQLresults | Export-Excel -Path $excelFile -WorksheetName $maindb -AutoSize -Show