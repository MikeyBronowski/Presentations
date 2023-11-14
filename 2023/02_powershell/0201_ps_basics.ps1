<#

  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|  
  

8888888b.                                         .d8888b.  888               888 888 
888   Y88b                                       d88P  Y88b 888               888 888 
888    888                                       Y88b.      888               888 888 
888   d88P .d88b.  888  888  888  .d88b.  888d888 "Y888b.   88888b.   .d88b.  888 888 
8888888P" d88""88b 888  888  888 d8P  Y8b 888P"      "Y88b. 888 "88b d8P  Y8b 888 888 
888       888  888 888  888  888 88888888 888          "888 888  888 88888888 888 888 
888       Y88..88P Y88b 888 d88P Y8b.     888    Y88b  d88P 888  888 Y8b.     888 888 
888        "Y88P"   "Y8888888P"   "Y8888  888     "Y8888P"  888  888  "Y8888  888 888 
   

@MikeyBronowski


#> 




# variables
cls # Get-Alias cls
Set-Location "C:\Tools\PowerDBA\02_powershell\"

$var = '** PowerDBA on PASS Data Community Summit 2023 **'
Write-Host '$var - variable as string'
Write-Host "$var - variable value added to string"
Write-Host "$var Get-Date - function as string"
Write-Host "$var $(Get-Date) - function value returned"

# ?????? 
Write-Host '$var $(Get-Date)'





# splatting
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.3


New-Item -Name "test.txt" -ItemType File
Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf

# create sample text files named dev, stage, test, prod


# give example of copy-item with -exclude and -include
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item?view=powershell-7.1


cd ..

New-Item -Name "copy01" -ItemType Directory
Set-Location copy01

New-Item -Name "des" -ItemType Directory
New-Item -Name "test.txt" -ItemType File
New-Item -Name "prod.txt" -ItemType File
New-Item -Name "test.ini" -ItemType File
New-Item -Name "prod.ini" -ItemType File


Copy-Item -Path "test.txt" -Destination "des\test1.txt" -WhatIf
Copy-Item -Path "test.txt" -Destination "des\test1.txt"


$HashArguments  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
    Destination = "des"
    WhatIf      = $true
}
Copy-Item @HashArguments



$HashArguments  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
    Destination = "des"
    Exclude     = "*.ini"
    WhatIf      = $true
}
Copy-Item @HashArguments


$HashArguments  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
    Destination = "des"
    Exclude     = "*.ini"
    Include     = "*prod*"
    WhatIf      = $true
}
Copy-Item @HashArguments



$HashArguments  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
    Destination = "des"
    Exclude     = "*.ini"
    Include     = "*prod*"
    WhatIf      = $false
}
Copy-Item @HashArguments




$HashArguments2  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
####Destination = "des"#############################
    Exclude     = "*.ini"
    Include     = "*prod*"
    WhatIf      = $true
}

Copy-Item @HashArguments2 -Destination "des\prod2.txt"
Copy-Item @HashArguments2 -Destination "des\prod3.txt"


$HashArguments2  = @{
    Path        = "C:\Users\MikeyBronowski\copy01\*"
####Destination = "des"#############################
    Exclude     = "*.ini"
    Include     = "*prod*"
    WhatIf      = $false
}

Copy-Item @HashArguments2 -Destination "des\prod2.txt"
Copy-Item @HashArguments2 -Destination "des\prod3.txt"



$ArrayArguments = @("test.txt", "test2.txt")
Copy-Item @ArrayArguments -WhatIf




# set default parameters
# https://techgenix.com/powershell-with-default-parameters/

# set default Verbose=$true for all commands
$PSDefaultParameterValues = @{ "*:Verbose" = $True }

# command with default Verbose=$true
New-Item -Name "PSDefaultParameterValues_all.txt" -ItemType File -Force


# set default Verbose=$true for all dbatools commands only
$PSDefaultParameterValues = @{ "*-Dba*:Verbose" = $True }

# no longer VERBOSE messages
New-Item -Name "PSDefaultParameterValues_dba.txt" -ItemType File -Force


# see the created files
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Format-Table

# more default parameters
$PSDefaultParameterValues = @{
    "*:AutoSize"        =$true;
    "Format-Table:Wrap" = $true;
}

# see the created files with default parameters
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Format-Table
 

# add default parameters to existing values
$PSDefaultParameterValues.Add("Stop-Process:WhatIf",$True)

# remove specific default parameters
$PSDefaultParameterValues.Remove("Stop-Process:WhatIf")

# disable default parameters globally
$PSDefaultParameterValues.Add("Disabled", $true)
$PSDefaultParameterValues["Disabled"] = $true

# enable default parameters globally
$PSDefaultParameterValues.Add("Disabled", $false)
$PSDefaultParameterValues["Disabled"] = $false

# clear default parameters
$PSDefaultParameterValues.Clear()




# piping/pipeline
$services               = Get-Service -Name "*sql*" 
$stoppedServices        = $services                 | Where-Object {($_.Status -eq "Stopped")} 
$stoppedServicesFirst2  = $stoppedServices          | Select-Object -First 2 
$stoppedServicesFirst2  | Export-Csv -Path services.txt

# or witout variables
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 | Export-Csv -Path services.txt 



# display the file

Invoke-Item .\services.txt
# what the...?



# other ways to display
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 | Format-Table -AutoSize -Wrap
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 -Property Name, StartupType, Status | Out-GridView
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 -Property * | Out-GridView 


# more information during function/command execution
New-Item -Name "test.txt" -ItemType File -Verbose


# przelacznik WhatIf
# WhatIf switch
Get-Item  "test.txt" | Remove-Item -Verbose -WhatIf



# lots of examples for beginners
<# 

    https://powershellbyexample.dev/  - Sander Stad

    Learn Windows PowerShell in a Month of Lunches - Don Jones

#>







# script execution policy
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy  Unrestricted -Scope CurrentUser

# trusted repositories


# who do we trust?
Get-PSRepository

# trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted 







# installing modules


# install from PSGallery
Install-Module -Name dbachecks -AllowPrerelease


# one more time the same module
Install-Module -Name dbachecks -AllowPrerelease


# ok one more time but with force
Install-Module -Name dbachecks -AllowPrerelease -Force


# find other versions in the repository
Find-Module -Name dbachecks -AllVersions | Select-Object -First 5


# install older version
Install-Module -Name dbachecks -RequiredVersion 2.0.13 -Verbose

Get-Module -Name dbachecks -ListAvailable



# install from GitHub
$dir = "c:\temp"
New-Item -Path $dir -ItemType Directory
$zip = "$dir\InstallModuleFromGitHub.zip"
$repoUrl = "https://github.com/dfinke/InstallModuleFromGitHub/archive/refs/heads/master.zip" 

Invoke-RestMethod -Uri $repoUrl -OutFile $zip

Expand-Archive -Path $zip -DestinationPath $dir -Force

Get-ChildItem -Recurse C:\temp\InstallModuleFromGitHub-master | Unblock-File

Import-Module C:\temp\InstallModuleFromGitHub-master\InstallModuleFromGitHub.psm1



# check if module is installed
Get-Module -Name InstallModuleFromGitHub

# location of the module
(Get-Module -Name InstallModuleFromGitHub).path
Get-Command -Module InstallModuleFromGitHub



#### clean up

# delete files
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Remove-Item