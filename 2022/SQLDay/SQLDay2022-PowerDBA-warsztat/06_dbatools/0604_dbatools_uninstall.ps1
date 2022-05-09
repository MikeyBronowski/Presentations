<#

  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
                                                                                        


     888 888               888                      888          
     888 888               888                      888          
     888 888               888                      888          
 .d88888 88888b.   8888b.  888888  .d88b.   .d88b.  888 .d8888b  
d88" 888 888 "88b     "88b 888    d88""88b d88""88b 888 88K      
888  888 888  888 .d888888 888    888  888 888  888 888 "Y8888b. 
Y88b 888 888 d88P 888  888 Y88b.  Y88..88P Y88..88P 888      X88 
 "Y88888 88888P"  "Y888888  "Y888  "Y88P"   "Y88P"  888  88888P' 
                                                                 
                                                                 
                                                                 

                                                     
                                                     
                                                                                             
@MikeyBronowski                                                                                                                                                                                                    
                                                                                        

#> 
<# 
    
    Andreas Jordan (@JordanOrdix)
    https://github.com/dataplat/dbatools/discussions/7447

#>

$instances = Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect
$instanceToUninstall = $instances| Out-GridView -Title 'Select instance to uninstall' -OutputMode Multiple
$results = @( )
foreach ($inst in $instanceToUninstall) {
    # What information do we need?
    # * Version for Install-DbaInstance to select the correct setup.exe
    # * InstancePath for Remove-Item to remove all left over files
    try {
        # Try to get information from running instance
        $server = Connect-DbaInstance -SqlInstance $inst.SqlInstance
        $instanceVersion = ($server.GetSqlServerVersionName() -split ' ')[-1]
        $instancePath = $server.RootDirectory -replace 'MSSQL$', ''
    } catch {
        # Fallback to information about the service
        $service = Get-DbaService -ComputerName $inst.ComputerName -InstanceName $inst.InstanceName -Type Engine -EnableException
        $instanceVersion = switch ($service.BinaryPath -replace '^.*MSSQL(\d\d).*$', '$1') { 15 { 2019 } 14 { 2017 } 13 { 2016 } 12 { 2014 } 11 { 2012 } }
        $instancePath = $service.BinaryPath -replace '^"?(.*)MSSQL\\Binn\\sqlservr\.exe.*$', '$1'
    }
    $params = @{
        SqlInstance      = $inst.SqlInstance
        Version          = $instanceVersion
        Configuration    = @{ ACTION = 'Uninstall' } 
        Path             = 'C:\SQL2019'
        Restart          = $true
        # Credential        = $domainAdminCredential
        Confirm          = $false
        Verbose          = $true
    }
    $result = Install-DbaInstance @params
    if (-not $result.Successful) {
        $result.Log | Set-Clipboard
        throw "Uninstall failed, see clipboard for details"
    }
    $results += $result
    
    # Remove directory
    Invoke-Command -ComputerName $inst.ComputerName -ScriptBlock { 
        param($path)
        Remove-Item -Path $path -Recurse -Force
    } -ArgumentList $instancePath
}

# jak sie duzo instaluje, to trzeba pamietac o restartach ;-)
# Verbose:$true bardzo sie przydaje
# Restart-Computer localhost

# sprawdz czy zostalo odinstalowane
Find-DbaInstance -ComputerName localhost -ScanType Browser, SqlConnect