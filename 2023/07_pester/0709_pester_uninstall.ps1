# https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688
#Requires -RunAsAdministrator

function Uninstall-Pester ([switch]$All) {
    if ([IntPtr]::Size * 8 -ne 64) { throw "Run this script from 64bit PowerShell." }

    #Requires -RunAsAdministrator
    $pesterPaths = foreach ($programFiles in ($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        $path = "$programFiles\WindowsPowerShell\Modules\Pester"
        if ($null -ne $programFiles -and (Test-Path $path)) {
            if ($All) { 
                Get-Item $path
            } <#

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
          
          
          Set-Location C:\SQLDay2022\07_pester
          
          #Requires -RunAsAdministrator

function Uninstall-Pester ([switch]$All) {
    if ([IntPtr]::Size * 8 -ne 64) { throw "Run this script from 64bit PowerShell." }

    #Requires -RunAsAdministrator
    $pesterPaths = foreach ($programFiles in ($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        $path = "$programFiles\WindowsPowerShell\Modules\Pester"
        if ($null -ne $programFiles -and (Test-Path $path)) {
            if ($All) { 
                Get-Item $path
            } 
            else { 
                Get-ChildItem "$path\3.*" 
            }
        }
    }


    if (-not $pesterPaths) {
        "There are no Pester$(if (-not $all) {" 3"}) installations in Program Files and Program Files (x86) doing nothing."
        return
    }

    foreach ($pesterPath in $pesterPaths) {
        takeown /F $pesterPath /A /R
        icacls $pesterPath /reset
        # grant permissions to Administrators group, but use SID to do
        # it because it is localized on non-us installations of Windows
        icacls $pesterPath /grant "*S-1-5-32-544:F" /inheritance:d /T
        Remove-Item -Path $pesterPath -Recurse -Force -Confirm:$false
    }
}

Uninstall-Pester