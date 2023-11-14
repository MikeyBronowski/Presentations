<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|    
 
 
                           
                                                                                        

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

Set-Location C:\Tools\PowerDBA\07_pester

# https://pester.dev/docs/introduction/installation
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocol]::Tls12


# install module
Get-Module -Name pester -ListAvailable 
Install-Module -Name Pester -Force -SkipPublisherCheck

# unistall built-in Pester module

# get content from github
$uri = 'https://gist.githubusercontent.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688/raw/58b06ee24bf28e3127f60a9b447f6e7f9419516d/Uninstall-Pester.ps1'
$wc = New-Object System.Net.WebClient
$script = $wc.DownloadString($uri)

# save to file
$script | Out-File -FilePath .\0709_pester_uninstall.ps1 -Encoding ascii

# run script
. .\0709_pester_uninstall.ps1


# confirm uninstallation
Get-Module -Name Pester -ListAvailable 

Import-Module -Name Pester -RequiredVersion 4.10.1 -Force
Import-Module -Name Pester -RequiredVersion 5.5.0

# Should operator list
Get-ShouldOperator | Out-GridView


# simple tests
Invoke-Pester .\0701_pester01.tests.ps1
Invoke-Pester .\0701_pester01.tests.ps1 -Output Detailed


Invoke-Pester .\0701_pester02.tests.ps1 -Output Detailed

# save test results to variable
$pesterResults = Invoke-Pester .\0701_pester02.tests.ps1 -Output None -PassThru

# version 4.x
# $pesterResults = Invoke-Pester .\0701_pester02.tests.ps1 -PassThru

$pesterResults.Failed | Format-Table
$pesterResults.PassedCount
$pesterResults | Select-Object *