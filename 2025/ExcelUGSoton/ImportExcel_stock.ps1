# Import necessary modules
Import-Module -Name ImportExcel

# Set temporary location
Set-Location $env:TEMP

# Cleanup any previous files
$excelFiles = "StockData1.xlsx","StockData2.xlsx","StockData3.xlsx","StockData4.xlsx","StockData5.xlsx"
Remove-Item $excelFiles -ErrorAction SilentlyContinue
$excelFile = $excelFiles[0]

# Define the API key and the stock symbol
$apiKey = "9ROGED3MCD8962M6"
$symbol = "MSFT"

# Fetch stock data from Alpha Vantage
$stockData = Invoke-RestMethod -Uri "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey&datatype=csv"

# Convert CSV data to a table
$csvData = $stockData | ConvertFrom-Csv

# Export the stock data to an Excel file
$csvData | Export-Excel -Path $excelFile -WorksheetName "StockData" -AutoSize -TableName "StockData" -KillExcel -Show

# Open the Excel package
$excel = Open-ExcelPackage -Path $excelFile -KillExcel

# Get the worksheet
$sheet = $excel.Workbook.Worksheets["StockData"]

# Add a new worksheet for the chart
$chartSheet = Add-Worksheet -ExcelPackage $excel -WorksheetName "StockChart" -MoveToEnd

# Define the chart
$chart = $chartSheet.Drawings.AddChart("Stock Prices", [OfficeOpenXml.Drawing.Chart.eChartType]::Line)
$chart.Title.Text = "Stock Prices"
$chart.SetPosition(1, 0, 1, 0)
$chart.SetSize(800, 600)

# Set the data range for the chart
$series = $chart.Series.Add("StockData[close]", "StockData[date]")
$series.Header = "Close Price"

# Save and close the Excel package
Close-ExcelPackage -ExcelPackage $excel -Show
