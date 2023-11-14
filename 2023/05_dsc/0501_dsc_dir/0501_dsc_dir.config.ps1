<#
    https://docs.microsoft.com/en-us/powershell/dsc/reference/resources/windows/fileresource?view=dsc-1.1

    
  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|  
     
#>
Configuration dscDemo 
{
    param
    (
        [string[]]$ComputerName='localhost'
    )
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    <#
        WARNING: The configuration 'dscDemo' is loading one or more built-in resources without explicitly importing associated modules. 
        Add Import-DscResource –ModuleName 'PSDesiredStateConfiguration' to your configuration to avoid this message.
    #>

    node $ComputerName {

        file dscDemoDir {
            Type = 'Directory'
            DestinationPath = 'C:\dscDemoDir\'
            Ensure = 'Present'
        }

        file dscDemoFile_permanent {
            DependsOn = "[File]dscDemoDir"
            Type = 'File'
            DestinationPath = 'C:\dscDemoDir\dscDemoFile_permanent.txt'
            Ensure = 'Present'
            Contents = "This is a text in dscDemoFile file that is permanent in dscDemoDir folder on localhost. $(Get-Date) on $env:COMPUTERNAME"
        }

        file dscDemoFile_temp {
            DependsOn = "[File]dscDemoDir"
            Type = 'File'
            DestinationPath = 'C:\dscDemoDir\dscDemoFile_temp.txt'
            #Ensure = 'Present'
            Ensure = 'Absent'
            Contents = "This is a text in dscDemoFile file that is temporary in dscDemoDir folder on localhost and will be gone when we change 'Ensure' value to 'Absent'." 
        }
    }
}
