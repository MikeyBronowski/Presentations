Describe "what is Pester?" {   
    Context "getting started with simple tests" {
        It "My first test" {
            $var01 = "PowerDBA"
            $var01 | Should -Be "PowerDBA"
        }


        It "My second test" {
            $var02 = 2023
            $var02 | Should -BeGreaterOrEqual 2023
        }

        It "Third test" {
            $var03 = "C:\PowerDBA"
            $var03 | Should -Exist
        }

        It "This test will fail" {
            $var04 = "X:\PowerDBA"
            $var04 | Should -Exist
        }
    }
    
}

Describe "More tests" {
    BeforeAll {
        $computerInfo = Get-ComputerInfo
    }
    Context "Context 1 - OS" {
        It "It is 64-bit server version" {
            $computerInfo.OsProductType | Should -Be "Server"
            $computerInfo.OsArchitecture | Should -Be "64-bit"
        }

        It "It is 2022 Standard Edition" {
            $computerInfo.OsName | Should -Contain "Microsoft Windows Server 2022 Standard"
        }
    }
    
    Context "Context 2 - Machine" {
        It "Name includes PowerDBA" {
            $computerInfo.CsName | Should -BeLike "*PowerDBA*"
        }
    }
}

Describe "Testing functions" {
    BeforeAll {
        function Get-PowerDBA {
            param (
                [string]$Module = "*"
            )

            $modules = Get-Module -ListAvailable
            $modules | Where-Object Name -like $Module   
        }
    }

    Context "Testing PowerShell modules" {
        It "Pester modules number is 2" {
            $modulesPester = Get-PowerDBA Pester
            $modulesPester.Count | Should -Be 2
        }
        
        It "Returns module with the specific name" {
            $modulesDbatools = Get-PowerDBA dbatools
            $modulesDbatools.Name | Should -Be "dbatools"
        }

    }
    
    Context "Test installed PowerShell modules" {
        BeforeAll {
            $moduleName = 'dbatools', 'dbachecks', 'pester', 'oh-my-posh'
            $module = (Get-Module -Name $moduleName -ListAvailable | Get-Unique).Name
        }
        
        it "[dbatools] is installed" {
            $module | Should -Contain 'dbatools'
        }

        it "[dbachecks] is installed" {
            $module | Should -Contain 'dbachecks'
        }

        it "[pester] is installed" {
            $module | Should -Contain 'pester'
        }

        it "[oh-my-posh] is installed" {
            $module | Should -Contain 'oh-my-posh'
        }
    }
    
    Context "Testing Chocolatey is installed" {
    
        It "[Chocolatey] is installed ]" {
            $chocoExists = Test-Path "$($env:ProgramData)\chocolatey\bin\choco.exe"
            $chocoExists | Should -BeTrue
        }
    }    
}