<#

                                                                          

                           
                                                                                        
d8b                                         888    8888888888                            888 
Y8P                                         888    888                                   888 
                                            888    888                                   888 
888 88888b.d88b.  88888b.   .d88b.  888d888 888888 8888888    888  888  .d8888b  .d88b.  888 
888 888 "888 "88b 888 "88b d88""88b 888P"   888    888        `Y8bd8P' d88P"    d8P  Y8b 888 
888 888  888  888 888  888 888  888 888     888    888          X88K   888      88888888 888 
888 888  888  888 888 d88P Y88..88P 888     Y88b.  888        .d8""8b. Y88b.    Y8b.     888 
888 888  888  888 88888P"   "Y88P"  888      "Y888 8888888888 888  888  "Y8888P  "Y8888  888 
                  888                                                                        
                  888                                                                        
                  888                                                                        
                                                                                               
                                                                                               
@MikeyBronowski                                                                                           

#> 

Set-Location C:\Tools\DataGrillen\09_importexcel

# install module
Install-Module -Name ImportExcel -Force
Import-Module -Name ImportExcel -Force
Get-Module -Name ImportExcel -ListAvailable


# set location
New-Item -Name Files -ItemType Directory
Set-Location .\Files

# delete existing files
$excelFiles = "MikeyBronowski_1.xlsx","MikeyBronowski_2.xlsx","MikeyBronowski_3.xlsx","MikeyBronowski_4.xlsx","MikeyBronowski_5.xlsx"
Remove-Item $excelFiles -ErrorAction SilentlyContinue

# 1
# new spreadsheet
$excelFile = $excelFiles[0]
$commands = Get-Command -Module dbatools 
$commands | Select-Object Name | Export-Excel -Path $excelFile # -KillExcel -Show


# add sheet at the end
$excel = Open-ExcelPackage -Path $excelFile # -KillExcel
Add-Worksheet -ExcelPackage $excel -WorksheetName Process -MoveToEnd
$process = Get-Process | Select-Object Name, PriorityClass, CPU, Company -First 50
$process | Export-Excel -ExcelPackage $excel -WorksheetName Process -TableName NewNamedTableForMikey -AutoSize -FreezeTopRow -FreezeFirstColumn



# add pivot table
$excel = Open-ExcelPackage -Path $excelFile # -KillExcel
Add-PivotTable -ExcelPackage $excel -PivotRows Name -PivotColumns PriorityClass -PivotData @{'CPU' = 'sum'; 'Company' = 'count'} -SourceWorkSheet Process -PivotTableName 'Pivot' -Activate


# save Excel package
Close-ExcelPackage -ExcelPackage $excel # -Show






# 2
# add conditional formatting
$excelFile = $excelFiles[1]
Remove-Item $excelFile -ErrorAction SilentlyContinue
$events = Get-EventLog  -LogName system | Select-Object EventID, Category, EntryType -First 50

# define conditional formatting
$ConditionalFormat =$(
    New-ConditionalText -ConditionalType AboveAverage -Range 'A:A' -BackgroundColor Red -ConditionalTextColor Black
    New-ConditionalText -ConditionalType DuplicateValues -Range 'B:B' -BackgroundColor Orange -ConditionalTextColor Black
    New-ConditionalText -Text Information -Range 'C:C' -BackgroundColor Blue -ConditionalTextColor Yellow
)
$events | Export-Excel -WorksheetName EventsConditional -TableName EventsConditional -Path $excelFile -ConditionalFormat $ConditionalFormat -AutoSize -Activate # -KillExcel



# quarters
$ConditionalFormat3 =$(
    New-ConditionalFormattingIconSet -Range A2:A6 -ConditionalFormat FiveIconSet -IconType Quarters
)
# add new table
"L",1,2,3,4,5 | Export-Excel -WorksheetName EventsIcons -TableName EventsConditional3 -Path $excelFile -ConditionalFormat $ConditionalFormat3 -Activate # -KillExcel






# 3
# adding charts

$excelFile = $excelFiles[2]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# generate some data
$math = @()
for ($i=0;$i -lt 361; $i++) {
    $r = $i/180*3.14
    $math += [pscustomobject]@{ Angle = $i; Sin = [math]::Sin($r); Cos = [math]::Cos($r) }
}
$math | Export-Excel -Path $excelFile -WorksheetName Math -AutoSize -TableName Math # -KillExcel

# define chart
$chartDef2 = New-ExcelChartDefinition -Title 'Sin(x)/Cos(x)' `
    -ChartType Line   `
    -XRange "Math[Angle]" `
    -YRange @("Math[Cos]","Math[Sin]") `
    -SeriesHeader 'Cos(x)','Sin(x)'`
    -Row 0 -Column 0

# add chart
Export-Excel -Path $excelFile -WorksheetName MathChart -ExcelChartDefinition $chartDef2 -Activate


# 4 
# Excel and images
# example from https://github.com/dfinke/ImportExcel/pull/1133
# load the function
. C:\Tools\DataGrillen\09_importexcel\0901_Add-ExcelImage.ps1

$excelFile = $excelFiles[3]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# Windows only
if ($IsWindows -eq $false) {
    throw "This only works on Windows and won't run on $([environment]::OSVersion)"
}


Add-Type -AssemblyName System.Drawing

$data = ConvertFrom-Csv @"
dzien, data, nazwisko, tytul
wtorek, 9 maja 2022,Erland Sommarskog, Deadlocks - Analysing, Preventing and Mitigating
wtorek, 9 maja 2022,Hubert Kobierzewski,dbt - rozwijaj data lake z SQL-em
wtorek, 9 maja 2022, John Martin, An Introduction to Amazon Redshift cloud data warehouse
sroda,10 maja 2022,Grzegorz Łyp,Be better than SQL Server scalar UDF Inling
sroda,10 maja 2022,Klaus Aschenbrenner,Docker for the SQL Server Developer
"@


try {
    $logo = "C:\Tools\DataGrillen\09_importexcel\powerdba.png"
    $image = [System.Drawing.Image]::FromFile($logo)
    $excel = $data | Export-Excel -Path $excelFile -AutoSize -PassThru
    $excel.Sheet1 | Add-ExcelImage -Image $image -Row 8 -Column 6 -ResizeCell
}
finally {
    if ($image) {
        $image.Dispose()
    }
    if ($excel) {
        Close-ExcelPackage -ExcelPackage $excel
    }
}


# 5 SQL Server + dbatools + ImportExcel
$excelFile = $excelFiles[4]

# get data from SQL Server with dbatools
# make sure the variable is set correctly
$sql1 = "localhost"
if (!$sql1) {
    Write-Host '                             ' -BackgroundColor Yellow -Foregroundcolor Blue
    Write-Host 'Set the SQL Instance variable ' -BackgroundColor Yellow -Foregroundcolor Blue
    Write-Host '                             ' -BackgroundColor Yellow -Foregroundcolor Blue
}
$SQLresults = Invoke-DbaQuery -SqlInstance $sql1 -Database master -Query 'SELECT name, database_id, state_desc FROM sys.databases;'

# export SQL data to Excel spreadsheet (importExcel)
$SQLresults | Export-Excel -Path $excelFile -WorksheetName msdb -AutoSize




# clear screen
cls

