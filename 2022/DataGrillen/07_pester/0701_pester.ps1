<#
                                                                                   

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


Set-Location 'C:\Tools\DataGrillen\07_pester'

# https://pester.dev/docs/introduction/installation
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocol]::Tls12

# install module
Get-Module -Name pester -ListAvailable 
Install-Module -Name Pester -Force -SkipPublisherCheck

# uninstall built-in Pester
# https://gist.github.com/nohwnd/5c07fe62c861ee563f69c9ee1f7c9688
. .\0709_pester_uninstall.ps1

# confirm the module is gone
Get-Module -Name Pester -ListAvailable 

Import-Module -Name Pester -RequiredVersion 4.10.1 -Force
Import-Module -Name Pester -RequiredVersion 5.3.3

# Should operators list
Get-ShouldOperator | Out-GridView

# simple tests
$pesterResults = Invoke-Pester -Path ".\0702_example_sql.tests.ps1" -PassThru
$pesterResults.Failed | Format-Table
$pesterResults.PassedCount


#######################################
$options = @{
    Filter = @{

        Tag = "tempdb","agent"
    }

    Output = @{

        Verbosity = "Detailed"
    }
}

$config = New-PesterConfiguration -Hashtable $options

Invoke-Pester -Configuration $config 


