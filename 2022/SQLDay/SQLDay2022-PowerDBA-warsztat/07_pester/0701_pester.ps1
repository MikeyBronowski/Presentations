<#

  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
                                                                                        

8888888b.                    888                     
888   Y88b                   888                     
888    888                   888                     
888   d88P  .d88b.  .d8888b  888888  .d88b.  888d888 
8888888P"  d8P  Y8b 88K      888    d8P  Y8b 888P"   
888        88888888 "Y8888b. 888    88888888 888     
888        Y8b.          X88 Y88b.  Y8b.     888     
888         "Y8888   88888P'  "Y888  "Y8888  888     
                                                     
                                                     
                                                     
                                                                                             
                                                                                               
@MikeyBronowski                                                                                           

#> 


Set-Location C:\SQLDay2022\07_pester

# https://pester.dev/docs/introduction/installation
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocol]::Tls12

# instaluj modul
Get-Module -Name pester -ListAvailable 
Install-Module -Name Pester -Force -SkipPublisherCheck

# odinstalowanie wbudowanej wersji Pester
# https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688
. .\0709_pester_uninstall.ps1

# potwierdz usuniecie modulu
Get-Module -Name Pester -ListAvailable 

Import-Module -Name Pester -RequiredVersion 4.10.1 -Force
Import-Module -Name Pester -RequiredVersion 5.3.3

# lista operatorow Should
Get-ShouldOperator | Out-GridView

# proste testy
Invoke-Pester .\0701_pester01.tests.ps1
Invoke-Pester .\0701_pester01.tests.ps1 -Output Detailed


Invoke-Pester .\0701_pester02.tests.ps1 -Output Detailed

# zapisanie wyniku testow w zmiennej
$pesterResults = Invoke-Pester .\0701_pester02.tests.ps1 -Output None -PassThru

# wersja 4.x
# $pesterResults = Invoke-Pester .\0701_pester02.tests.ps1 -PassThru

$pesterResults.Failed | Format-Table
$pesterResults.PassedCount
$pesterResults | Select-Object *