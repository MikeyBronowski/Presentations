﻿<# 



  ____   _    ____ ____    ____        _           ____                                      _ _         
 |  _ \ / \  / ___/ ___|  |  _ \  __ _| |_ __ _   / ___|___  _ __ ___  _ __ ___  _   _ _ __ (_) |_ _   _ 
 | |_) / _ \ \___ \___ \  | | | |/ _` | __/ _` | | |   / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | |
 |  __/ ___ \ ___) |__) | | |_| | (_| | || (_| | | |__| (_) | | | | | | | | | | | |_| | | | | | |_| |_| |
 |_| /_/   \_\____/____/  |____/ \__,_|\__\__,_|  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, |
  ____                            _ _     ____   ___ ____  _                                       |___/ 
 / ___| _   _ _ __ ___  _ __ ___ (_) |_  |___ \ / _ \___ \/ |                                            
 \___ \| | | | '_ ` _ \| '_ ` _ \| | __|   __) | | | |__) | |                                            
  ___) | |_| | | | | | | | | | | | | |_   / __/| |_| / __/| |                                            
 |____/ \__,_|_| |_| |_|_| |_| |_|_|\__| |_____|\___/_____|_|                                            
                                                                                                         


  
                                                              
██████╗ ███████╗███████╗████████╗███████╗██████╗              
██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗             
██████╔╝█████╗  ███████╗   ██║   █████╗  ██████╔╝             
██╔═══╝ ██╔══╝  ╚════██║   ██║   ██╔══╝  ██╔══██╗             
██║     ███████╗███████║   ██║   ███████╗██║  ██║             
╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             
                                                              
                             
                                                           


#> 

# install pester
Install-Module -Name pester -Force
# choco install pester



# Assertion "Should"

notepad .\PASS_4_pester.test.ps1

# run the test
Invoke-Pester "PASS_4_pester.test.ps1" -Output Detailed

# get the list of the operators
Get-ShouldOperator | ogv


# https://pester-docs.netlify.app/docs/quick-start


# clear screen
Set-Location C:\PASS2021
cls