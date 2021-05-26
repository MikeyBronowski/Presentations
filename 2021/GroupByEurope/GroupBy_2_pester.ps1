<# 


   ____                       ____          _____                                     __  __               ____   __   
  / ___|_ __ ___  _   _ _ __ | __ ) _   _  | ____|   _ _ __ ___  _ __   ___          |  \/  | __ _ _   _  |___ \ / /_  
 | |  _| '__/ _ \| | | | '_ \|  _ \| | | | |  _|| | | | '__/ _ \| '_ \ / _ \  _____  | |\/| |/ _` | | | |   __) | '_ \ 
 | |_| | | | (_) | |_| | |_) | |_) | |_| | | |__| |_| | | | (_) | |_) |  __/ |_____| | |  | | (_| | |_| |  / __/| (_) |
  \____|_|  \___/ \__,_| .__/|____/ \__, | |_____\__,_|_|  \___/| .__/ \___|         |_|  |_|\__,_|\__, | |_____|\___/ 
                       |_|          |___/                       |_|                                |___/               

  
                                                              
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
                Name = "GroupBy"
                Edition = "Virtual"
            }
        }
    }

    It "The event is virtual" {
        $ug = Get-DataEventDetails

        $ug | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $ug.Name | Should -Be "GroupBy"
        $ug.Edition | Should -Match "Virtual"
    }


    It "The event is in person" {

        $ug | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $ug.Name | Should -Be "GroupBy"
        $ug.Edition | Should -Match "in person"
    }
}

# run the test
Invoke-Pester "$env:TEMP\GroupBy_2_pester.test.ps1"

# get the list of the operators
Get-ShouldOperator | ogv


# https://pester-docs.netlify.app/docs/quick-start
