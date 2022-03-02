Configuration dscDemo 
{
    param
    (
        [string[]]$ComputerName='localhost'
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    node $ComputerName {
        file dscDemoDir {
            Type = 'Directory'
            DestinationPath = 'C:\dscDemoDir\'
            Ensure = 'Present'
        }

        file dscDemoFile {
            DependsOn = "[File]dscDemoDir"
            Type = 'File'
            DestinationPath = 'C:\dscDemoDir\dscDemoFile.txt'
            Ensure = 'Present'
            Contents = "This is a text in dscDemoFile file in dscDemoDir folder on localhost"
        }
    }
}