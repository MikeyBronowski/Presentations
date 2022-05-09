<#

  ____   ___  _     ____              ____   ___ ____  ____  
 / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
 \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
  ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
 |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                |___/                        



 .d8888b.  888b     d888  .d88888b.  
d88P  Y88b 8888b   d8888 d88P" "Y88b 
Y88b.      88888b.d88888 888     888 
 "Y888b.   888Y88888P888 888     888 
    "Y88b. 888 Y888P 888 888     888 
      "888 888  Y8P  888 888     888 
Y88b  d88P 888   "   888 Y88b. .d88P 
 "Y8888P"  888       888  "Y88888P"  
                                     
                                     
                                    
   

@MikeyBronowski


#> 

[Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")
# Global Assembly Cache

$instanceName = "localhost"
$smoServer = New-Object "Microsoft.SqlServer.Management.Smo.Server" $instanceName
$smoDatabases = $smoServer.Databases
$smoDatabases | Select-Object Parent, Name, CompatibilityLevel |  Format-Table -AutoSize
$smoDatabases[0] | Format-Table -AutoSize
$smoDatabases['msdb'] | Select-Object Parent, Name, CompatibilityLevel |  Format-Table -AutoSize
$dbTables = $smoDatabases['msdb'].Tables 
$dbTables | Sort-Object -Descending -Property DataSpaceUsed | Select-Object Parent, RowCount, DataSpaceUsed, IndexSpaceUsed -First 10 | Format-Table -AutoSize

$smoDatabases['msdb'].Views.Count
$smoDatabases['msdb'].StoredProcedures.Count



# agent / jobs
# logins


# tworzenie obiektów
# tworzenie bazy
$newDatabaseName = "SMO_PowerDBA"
$smoNewDatabase = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $smoServer, $newDatabaseName
$smoNewDatabase.Create()  
$smoDatabases["$newDatabaseName"] | Select-Object Parent, Name, CompatibilityLevel, Owner |  Format-Table -AutoSize

# dbo
$smoDatabases["$newDatabaseName"].Owner

# ustal nowy dbo
$smoDatabases["$newDatabaseName"].SetOwner("sa",$true)
$smoDatabases["$newDatabaseName"].Refresh()
$smoDatabases["$newDatabaseName"].Owner

# tworzenie nowej tabeli
$newTableName = "SMO_PowerDBA_table"
$smoNewTable = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Table -ArgumentList $smoNewDatabase, $newTableName

#Add various columns to the table.   
$dataType = [Microsoft.SqlServer.Management.SMO.DataType]::Int
$newColumnName = "id"
$smoNewColumn =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Column -ArgumentList $smoNewTable, $newColumnName, $dataType  
$smoNewColumn.Identity = $true  
$smoNewColumn.IdentitySeed = 1  
$smoNewColumn.IdentityIncrement = 1  
$smoNewTable.Columns.Add($smoNewColumn)  
  
$dataType = [Microsoft.SqlServer.Management.SMO.DataType]::Int  
$newColumnName = "int"
$smoNewColumn =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Column -ArgumentList $smoNewTable, $newColumnName, $dataType  
$smoNewColumn.Nullable = $true  
$smoNewTable.Columns.Add($smoNewColumn)  
    
# stworz tabele
$smoNewTable.Create()  
$smoNewTable

# zmiana istniejacego biektu
$smoNewTable = $smoDatabases["$newDatabaseName"].Tables["$newTableName"]
$dataType = [Microsoft.SqlServer.Management.SMO.DataType]::NChar(50) 
$newColumnName = "name"
$smoNewColumn =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Column -ArgumentList $smoNewTable, $newColumnName, $dataType  
$smoNewColumn.Nullable = $true  
$smoNewTable.Columns.Add($smoNewColumn)  
$smoNewTable.Alter() 


# usuwanie obiektów
$smoNewTable.Drop()





# zapytania
$msdb = $smoDatabases['msdb'] 
$msdb.ExecuteWithResults('Select * from sysjobs').Tables.Rows | Format-Table -AutoSize
$msdb.ExecuteWithResults('select @@servername as srv, @@version as ver, db_name() as db').Tables.Rows | Format-Table -AutoSize
$msdb.ExecuteWithResults('select @@servername as srv, @@version as ver, db_name() as db').Tables.Rows | Out-GridView