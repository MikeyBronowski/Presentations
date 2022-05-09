<#

  ____   ___  _     ____              ____   ___ ____  ____  
 / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
 \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
  ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
 |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                |___/                        


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




# zmienne
cls # Get-Alias cls
Set-Location "C:\Tools\SQLDay2022\02_powershell"

$var = '** PowerDBA na SQL Day 2022 **'
Write-Host '$var - zmienna traktowana jako tekst'
Write-Host "$var - wartość zmiennej dodana do tekstu"
Write-Host "$var Get-Date - funkcja traktowana jako tekst"
Write-Host "$var $(Get-Date) - wartość funkcji dodana"

# ?????? 
Write-Host '$var0 $(Get-Date)'





# pakiet parametrow (splatting)
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.2


New-Item -Name "test.txt" -ItemType File
Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf


$HashArguments  = @{
    Path        = "test.txt"
    Destination = "test3.txt"
    WhatIf      = $true
}
Copy-Item @HashArguments


$HashArguments2 = @{
    Path        = "test.txt"
    WhatIf      = $true
    Exclude     = "prod"
    Include     = "test*"
}
Copy-Item @HashArguments2 -Destination "test4.txt"
Copy-Item @HashArguments2 -Destination "test5.txt"
Copy-Item @HashArguments2 -Destination "test6.txt" -Include "g"


$ArrayArguments = "test.txt", "test7.txt"
Copy-Item @ArrayArguments -WhatIf




# ustalenie wartosci domyslnych
# https://techgenix.com/powershell-with-default-parameters/

# ustal domyslna wartosc Verbose dla kazdej funkcji
$PSDefaultParameterValues = @{ "*:Verbose" = $false }

# komenda z domyslnym wlaczonym Verbose
New-Item -Name "PSDefaultParameterValues_all.txt" -ItemType File # -verbose



# ustal domyslna wartosc Verbose tylko dla funkcji dbatools
$PSDefaultParameterValues = @{ "*-Dba*:Verbose" = $true }

# brak dodatkowych wiadomosci
New-Item -Name "PSDefaultParameterValues_dba.txt" -ItemType File 


# wyswietl pliki bez domyslnych wartosci
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Format-Table

# wiecej wartosci domyslnych
$PSDefaultParameterValues = @{
    "*:AutoSize"        =$true;
    "Format-Table:Wrap" = $true;
}

# wyswietl pliki z wartosciami domyslnymi
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Format-Table

# dodanie wartosci domyslnych do istniejacego zbioru
$PSDefaultParameterValues.Add("Stop-Process:WhatIf",$True)

# usuniecie konkretnych wartosci domyslnych ze zbioru
$PSDefaultParameterValues.Remove("Stop-Process:WhatIf")

# wylaczenie wartosci domyslnych globalnie
$PSDefaultParameterValues.Add("Disabled", $true)
$PSDefaultParameterValues["Disabled"] = $true

# wlaczenie wartosci domyslnych globalnie
$PSDefaultParameterValues.Add("Disabled", $false)
$PSDefaultParameterValues["Disabled"] = $false

# wyczyszczenie wartosci domyslnych
$PSDefaultParameterValues.Clear()



# potok (piping/pipeline) + przekazywanie zmiennych
$services               = Get-Service -Name "*sql*" 
$stoppedServices        = $services                 | Where-Object {($_.Status -eq "Stopped")} 
$stoppedServicesFirst2  = $stoppedServices          | Select-Object -First 2 
$stoppedServicesFirst2  | Export-Csv -Path services.txt

# lub bez zmiennych
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 | Export-Csv -Path services.txt 



# wyświetlamy plik

Invoke-Item .\services.txt
# co tu się...?


# inne sposoby wyswietlania
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 | Format-Table -AutoSize -Wrap
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 -Property Name, StartupType, Status | Out-GridView
Get-Service -Name "*sql*" | Where-Object {($_.Status -eq "Stopped")} | Select-Object -First 2 -Property * | Out-GridView 


# więcej informacji podczas wykonywania funkcji/komendy
New-Item -Name "test.txt" -ItemType File -Verbose


# przelacznik WhatIf
Get-Item  "test.txt" | Remove-Item -Verbose -WhatIf



# dużo przykładów dla początkujących
<# 

    https://powershellbyexample.dev/  - Sander Stad

    Learn Windows PowerShell in a Month of Lunches - Don Jones

#>






# polityka wykonywania skryptów
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy 

# zaufane repozytoria

# komu ufamy?
Get-PSRepository

# zaufajmy PSGallery
Get-PSRepository | Set-PSRepository -InstallationPolicy Trusted







# instalowanie modułów

# zainstaluj z PSGallery
Install-Module -Name dbachecks -Verbose

# jeszcze raz ten sam moduł
Install-Module -Name dbachecks -Verbose

# ok, jeszcze raz tylko mocniej
Install-Module -Name dbachecks -Verbose -Force

# znajdź inne wersje w repozytorium
Find-Module -Name dbachecks -AllVersions | Select-Object -First 5

# zainstaluj starszą wersję
Install-Module -Name dbachecks -RequiredVersion 2.0.13 -Verbose

Get-Module -Name dbachecks -ListAvailable



# instalowanie z GitHub na przykład
$dir = "c:\temp"
New-Item -Path $dir -ItemType Directory
$zip = "$dir\InstallModuleFromGitHub.zip"
$repoUrl = "https://github.com/dfinke/InstallModuleFromGitHub/archive/refs/heads/master.zip" 

Invoke-RestMethod -Uri $repoUrl -OutFile $zip

Expand-Archive -Path $zip -DestinationPath $dir -Force

Get-ChildItem -Recurse C:\temp\InstallModuleFromGitHub-master | Unblock-File

Import-Module C:\temp\InstallModuleFromGitHub-master\InstallModuleFromGitHub.psm1



# sprawdzamy czy modul jest zinstalowany
Get-Module -Name InstallModuleFromGitHub

# lokalizacja modulu
(Get-Module -Name InstallModuleFromGitHub).path
Get-Command -Module InstallModuleFromGitHub



#### czyszczenie

# usun obiekty
Get-ChildItem "PSDefaultParameterValues_dba.txt", "PSDefaultParameterValues_all.txt" | Remove-Item