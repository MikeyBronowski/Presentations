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

# https://pester-docs.netlify.app/docs/usage/code-coverage

function FunctionOne ([switch] $SwitchParam)
{
    if ($SwitchParam)
    {
        return 'SwitchParam was set'
    }
    else
    {
        return 'SwitchParam was not set'
    }
}

function FunctionTwo
{
    return 'I get executed'
    return 'I do not'
}



<#
FunctionOne
FunctionOne -SwitchParam

FunctionTwo
Invoke-Pester .\0704_coverage.Tests.ps1 -CodeCoverage .\0704_coverage.ps1 -Show All
#>