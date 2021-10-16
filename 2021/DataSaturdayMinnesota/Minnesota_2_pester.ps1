<# 


  _____            _              _____           _                        _                   
 |  __ \          | |            / ____|         | |                      | |                  
 | |  | |   __ _  | |_    __ _  | (___     __ _  | |_   _   _   _ __    __| |   __ _   _   _   
 | |  | |  / _` | | __|  / _` |  \___ \   / _` | | __| | | | | | '__|  / _` |  / _` | | | | |  
 | |__| | | (_| | | |_  | (_| |  ____) | | (_| | | |_  | |_| | | |    | (_| | | (_| | | |_| |  
 |_____/   \__,_|  \__|  \__,_| |_____/   \__,_|  \__|  \__,_| |_|     \__,_|  \__,_|  \__, |  
 |  \/  | (_)                                      | |                                  __/ |  
 | \  / |  _   _ __    _ __     ___   ___    ___   | |_    __ _                        |___/   
 | |\/| | | | | '_ \  | '_ \   / _ \ / __|  / _ \  | __|  / _` |                               
 | |  | | | | | | | | | | | | |  __/ \__ \ | (_) | | |_  | (_| |                               
 |_|  |_| |_| |_| |_| |_| |_|  \___| |___/  \___/   \__|  \__,_| 

  
                                                              
██████╗ ███████╗███████╗████████╗███████╗██████╗              
██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗             
██████╔╝█████╗  ███████╗   ██║   █████╗  ██████╔╝             
██╔═══╝ ██╔══╝  ╚════██║   ██║   ██╔══╝  ██╔══██╗             
██║     ███████╗███████║   ██║   ███████╗██║  ██║             
╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝             
                                                              
                             
                                                           


#> 

# Install-Module -Name pester
# choco install pester



# Assertion "Should"

Describe "Checking the event details" {
    BeforeAll {
        function Get-DataEventDetails {
            @{
                Name = "Data Saturday Minnesota"
                Edition = "Virtual"
            }
        }
    }

    It "The event is virtual" {
        $ug = Get-DataEventDetails

        $ug | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $ug.Name | Should -Be "Data Saturday Minnesota"
        $ug.Edition | Should -Match "Virtual"
    }


    It "The event is in person" {

        $ug | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $ug.Name | Should -Be "Data Saturday Minnesota"
        $ug.Edition | Should -Match "in person"
    }
}

# run the test
Invoke-Pester "$env:OneDrive\SQL\Presentation\SQLPS_Bar-fufa\2021_DataSaturdayMinnesota\Minnesota_2_pester.test.ps1"

# get the list of the operators
Get-ShouldOperator | ogv


# https://pester-docs.netlify.app/docs/quick-start
