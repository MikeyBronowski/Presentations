Configuration SQLInstall
{
     Import-DscResource –ModuleName PSDesiredStateConfiguration
     Import-DscResource -ModuleName SqlServerDsc

     node localhost
     {
          WindowsFeature 'NetFramework45'
          {
               Name   = 'NET-Framework-45-Core'
               Ensure = 'Present'
          }

          SqlSetup 'InstallDefaultInstance'
          {
               InstanceName        = 'MSSQLSERVER'
               Features            = 'SQLENGINE'
               SourcePath          = 'C:\SQL2019'
               SQLSysAdminAccounts = @('Administrators')
               DependsOn           = '[WindowsFeature]NetFramework45'
          }

          SqlSetup 'InstallNamedInstance-DSC'
          {
               InstanceName        = 'DSC'
               Features            = 'SQLENGINE'
               SourcePath          = 'C:\SQL2019'
               SQLSysAdminAccounts = @('Administrators')
               DependsOn           = '[WindowsFeature]NetFramework45'
          }
     }
}