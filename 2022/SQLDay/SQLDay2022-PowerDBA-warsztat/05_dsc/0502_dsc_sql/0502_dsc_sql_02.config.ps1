<#
  ____   ___  _     ____              ____   ___ ____  ____  
  / ___| / _ \| |   |  _ \  __ _ _   _|___ \ / _ \___ \|___ \ 
  \___ \| | | | |   | | | |/ _` | | | | __) | | | |__) | __) |
   ___) | |_| | |___| |_| | (_| | |_| |/ __/| |_| / __/ / __/ 
  |____/ \__\_\_____|____/ \__,_|\__, |_____|\___/_____|_____|
                                 |___/                        
 
                           
           


8888888b.                    d8b                       888  .d8888b.  888             888             
888  "Y88b                   Y8P                       888 d88P  Y88b 888             888             
888    888                                             888 Y88b.      888             888             
888    888  .d88b.  .d8888b  888 888d888  .d88b.   .d88888  "Y888b.   888888  8888b.  888888  .d88b.  
888    888 d8P  Y8b 88K      888 888P"   d8P  Y8b d88" 888     "Y88b. 888        "88b 888    d8P  Y8b 
888    888 88888888 "Y8888b. 888 888     88888888 888  888       "888 888    .d888888 888    88888888 
888  .d88P Y8b.          X88 888 888     Y8b.     Y88b 888 Y88b  d88P Y88b.  888  888 Y88b.  Y8b.     
8888888P"   "Y8888   88888P' 888 888      "Y8888   "Y88888  "Y8888P"   "Y888 "Y888888  "Y888  "Y8888  

 .d8888b.                     .d888 d8b                                    888    d8b                   
d88P  Y88b                   d88P"  Y8P                                    888    Y8P                   
888    888                   888                                           888                          
888         .d88b.  88888b.  888888 888  .d88b.  888  888 888d888  8888b.  888888 888  .d88b.  88888b.  
888        d88""88b 888 "88b 888    888 d88P"88b 888  888 888P"       "88b 888    888 d88""88b 888 "88b 
888    888 888  888 888  888 888    888 888  888 888  888 888     .d888888 888    888 888  888 888  888 
Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 Y88b 888 888     888  888 Y88b.  888 Y88..88P 888  888 
 "Y8888P"   "Y88P"  888  888 888    888  "Y88888  "Y88888 888     "Y888888  "Y888 888  "Y88P"  888  888 
                                             888                                                        
                                        Y8b d88P                                                        
                                         "Y88P"                                                         

                                                                                                      
                                                                                                      
#>


Configuration SQLInstall
{
     param
     (
         [string[]]$ComputerName='localhost'
     )

     Import-DscResource -ModuleName PSDesiredStateConfiguration
     Import-DscResource -ModuleName SqlServerDsc

     node $ComputerName
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