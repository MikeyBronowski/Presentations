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