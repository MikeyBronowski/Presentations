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

# https://pester.dev/docs/usage/code-coverage

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

# write pester test for FunctionOne



function FunctionTwo
{
    return 'I get executed'
    return 'I do not'
}