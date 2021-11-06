Configuration SQLInstall
{
     Import-DscResource –ModuleName PSDesiredStateConfiguration
     Import-DscResource -ModuleName SqlServerDsc
     Import-DscResource -ModuleName xPSDesiredStateConfiguration
     Import-DscResource -ModuleName StorageDsc

     node localhost
     {
          WindowsFeature 'NetFramework45'
          {
               Name   = 'NET-Framework-45-Core'
               Ensure = 'Present'
          }

        xRemoteFile remotefile 
        {
            # for uri generate a sas token then copy the sas token url in the uri line below
            Uri             = "https://mikeybronowski5.blob.core.windows.net/mikeyct01/SQLServer2019-x64-ENU-Dev.iso"
            DestinationPath = "C:\dscDemoDir\SQLServer2019-x64-ENU-Dev.iso"
            MatchSource     = $false
        }
        
        MountImage ISO
        {
            ImagePath   = "C:\dscDemoDir\SQLServer2019-x64-ENU-Dev.iso"
            DriveLetter = "S"
            #DependsOn   = '[xRemoteFile]remotefile'
        }

        WaitForVolume WaitForISO
        {
            DriveLetter      = "S"
            RetryIntervalSec = 5
            RetryCount       = 10
        }

        SqlSetup 'InstallDefaultInstance'
        {
            InstanceName        = 'MSSQLSERVER'
            Features            = 'SQLENGINE'
            SourcePath          = 'S:\'
            SQLSysAdminAccounts = @('Administrators')
            DependsOn           =  @('[WindowsFeature]NetFramework45', '[MountImage]ISO')
        }

     }
}