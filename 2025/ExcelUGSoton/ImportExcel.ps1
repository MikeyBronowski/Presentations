
Get-Module -Name ImportExcel
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Import-Module -Name ImportExcel -RequiredVersion 7.8.10
Import-Module -Name ImportExcel -RequiredVersion 7.1.1

###################################################################################################################################################
Set-Location $env:TEMP

# cleanup any previous files
$excelFiles = "MikeyAtImportExcel1.xlsx","MikeyAtImportExcel2.xlsx","MikeyAtImportExcel3.xlsx","MikeyAtImportExcel4.xlsx","MikeyAtImportExcel5.xlsx"
Remove-Item $excelFiles -ErrorAction SilentlyContinue



$excelFile = $excelFiles[0]
$commands = Get-Command -Module ImportExcel 
$commands | SELECT Name | Export-Excel -Path $excelFile -KillExcel -Show



$excelFile = $excelFiles[0]
$excel = Open-ExcelPackage -Path $excelFile -KillExcel

# add an extra sheet to the end
Add-Worksheet -ExcelPackage $excel -WorksheetName NewTabForMikey -MoveToEnd

$process = Get-Process | SELECT Name, PriorityClass, CPU, Company -First 50
$process | Export-Excel -ExcelPackage $excel -WorksheetName NewTabForMikey -TableName NewNamedTableForMikey -AutoSize -FreezeTopRow -FreezeFirstColumn -Show


$excelFile = $excelFiles[0]
$excel = Open-ExcelPackage -Path $excelFile -KillExcel


Add-PivotTable -ExcelPackage $excel -PivotRows Name -PivotColumns PriorityClass -PivotData @{'CPU' = 'sum'; 'Company' = 'count'} -SourceWorkSheet NewTabForMikey -PivotTableName 'Pivot' -Activate


# save it to the file and display
Close-ExcelPackage -ExcelPackage $excel -Show


$excelFile = $excelFiles[1]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# create a new file in TEMP location - clean worksheet
$events = Get-EventLog -After (Get-Date -Format 'yyyy-MM-dd') -LogName system | SELECT EventID, Category, EntryType -First 50

# define conditional formatting for each column in a new worksheet
# these are random formats, just to show the capability
$ConditionalFormat =$(
    New-ConditionalText -ConditionalType AboveAverage -Range 'A:A' -BackgroundColor Red -ConditionalTextColor Black
    New-ConditionalText -ConditionalType DuplicateValues -Range 'B:B' -BackgroundColor Orange -ConditionalTextColor Black
    New-ConditionalText -Text Information -Range 'C:C' -BackgroundColor Blue -ConditionalTextColor Yellow
)

# add the new worksheet with ConditionalFormat.
$events | Export-Excel -WorksheetName EventsConditional -TableName EventsConditional -Path $excelFile -ConditionalFormat $ConditionalFormat -AutoSize -Activate -KillExcel


# define conditional format for the IconSet using Quarters
$ConditionalFormat3 =$(
    New-ConditionalFormattingIconSet -Range A2:A6 -ConditionalFormat FiveIconSet -IconType Quarters
)
# add a new table
"L",1,2,3,4,5 | Export-Excel -WorksheetName EventsIcons -TableName EventsConditional3 -Path $excelFile -ConditionalFormat $ConditionalFormat3 -Activate -KillExcel -Show




$excelFile = $excelFiles[2]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# create an array with the data
$math = @()
for ($i=0;$i -lt 361; $i++) {
    $r = $i/180*3.14
    $math += [pscustomobject]@{ Angle = $i; Sin = [math]::Sin($r); Cos = [math]::Cos($r) }
}

# export data first
$math | Export-Excel -Path $excelFile -WorksheetName Math -AutoSize -TableName Math -KillExcel

# define the chart
$chartDef2 = New-ExcelChartDefinition -Title 'Sin(x)/Cos(x)' `
    -ChartType Line   `
    -XRange "Math[Angle]" `
    -YRange @("Math[Cos]","Math[Sin]") `
    -SeriesHeader 'Cos(x)','Sin(x)'`
    -Row 0 -Column 0

# add the chart to another worksheet
Export-Excel -Path $excelFile -WorksheetName MathChart -ExcelChartDefinition $chartDef2 -Activate -Show



# cleanup any previous files
$excelFile = $excelFiles[3]
Remove-Item $excelFile -ErrorAction SilentlyContinue

# define data
$data = @"
Surface,Value
Right wall,1
Floor,1
Left wall,1
"@

# export data to the excel worksheet
$data | ConvertFrom-Csv | Export-Excel -Path  $excelFile -AutoFilter -WorksheetName Pie -AutoNameRange -KillExcel

# using Open/Close ExcelPackage add the new chart
$excel = Open-ExcelPackage $excelFile
Add-ExcelChart -Worksheet $excel.Pie -ChartType Pie -Title Pie -XRange Surface -YRange Value
Close-ExcelPackage $excel -Show

9ROGED3MCD8962M6
