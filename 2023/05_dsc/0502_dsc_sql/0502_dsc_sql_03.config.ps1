<#
  _____         _____ _____    _____ _    _ __  __ __  __ _____ _______   ___   ___ ___  _  _   
 |  __ \ /\    / ____/ ____|  / ____| |  | |  \/  |  \/  |_   _|__   __| |__ \ / _ \__ \| || |  
 | |__) /  \  | (___| (___   | (___ | |  | | \  / | \  / | | |    | |       ) | | | | ) | || |_ 
 |  ___/ /\ \  \___ \\___ \   \___ \| |  | | |\/| | |\/| | | |    | |      / /| | | |/ /|__   _|
 | |  / ____ \ ____) |___) |  ____) | |__| | |  | | |  | |_| |_   | |     / /_| |_| / /_   | |  
 |_| /_/    \_\_____/_____/  |_____/ \____/|_|  |_|_|  |_|_____|  |_|    |____|\___/____|  |_|        
 
                           
           


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

          SqlSetup 'InstallNamedInstance-DSCPS7'
          {
               InstanceName        = 'DSCPS7'
               Features            = 'SQLENGINE'
               SourcePath          = 'C:\SQL2019'
               SQLSysAdminAccounts = @('Administrators')
               DependsOn           = '[WindowsFeature]NetFramework45'
          }
     }
}