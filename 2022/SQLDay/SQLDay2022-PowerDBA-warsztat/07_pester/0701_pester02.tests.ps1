Describe "Co to jest Pester?" {
    Context "Poznajemy proste testy" {
        It "Moj pierwszy test" {
            $var01 = "PowerDBA"
            $var01 | Should -Be "PowerDBA"
        }

        It "Drugi test" {
            $var02 = 2022
            $var02 | Should -BeGreaterOrEqual 2022
        }

        It "Do Czech razy štuka" {
            $var03 = "C:\SQLDay2022"
            $var03 | Should -Exist
        }

        It "Ten test nie przejdzie" {
            $var04 = "X:\SQLDay2022"
            $var04 | Should -Exist
        }
    }
    
}

Describe "Wiecej testow" {
    BeforeAll {
        $computerInfo = Get-ComputerInfo
    }
    Context "Kontekst 1 - OS" {
        It "To jest wersja serwerowa 64-bitowa" {
            $computerInfo.OsProductType | Should -Be "Server"
            $computerInfo.OsArchitecture | Should -Be "64-bit"
        }

        It "To jest wersja 2022 standard" {
            $computerInfo.OsName | Should -Contain "Microsoft Windows Server 2022 Standard"
        }
    }
    
    Context "Kontekst 2 - Maszyna" {
        It "Nazwa zawiera PowerDBA" {
            $computerInfo.CsName | Should -BeLike "*PowerDBA*"
        }
    }
}

Describe "Testy funkcji" {
    BeforeAll {
        function Get-PowerDBA {
            param (
                [string]$Module = "*"
            )

            $modules = Get-Module -ListAvailable
            $modules | Where-Object Name -like $Module   
        }
    }

    Context "Badamy moduly PowerShell" {
        It "Liczba modulow Pester jest rowna 2" {
            $modulesPester = Get-PowerDBA Pester
            $modulesPester.Count | Should -Be 2
        }
        
        It "Zwraca modul o podanej nazwie" {
            $modulesDbatools = Get-PowerDBA dbatools
            $modulesDbatools.Name | Should -Be "dbatools"
        }

    }
    
    Context "Testuj zainstalowane moduly PowerShell" {
        BeforeAll {
            $moduleName = 'dbatools', 'dbachecks', 'pester', 'oh-my-posh'
            $module = (Get-Module -Name $moduleName -ListAvailable | Get-Unique).Name
        }
        
        it "[dbatools] jest zainstalowany" {
            $module | Should -Contain 'dbatools'
        }

        it "[dbachecks] jest zainstalowany" {
            $module | Should -Contain 'dbachecks'
        }

        it "[pester] jest zainstalowany" {
            $module | Should -Contain 'pester'
        }

        it "[oh-my-posh] jest zainstalowany" {
            $module | Should -Contain 'oh-my-posh'
        }
    }
    
    Context "Testuj zainstalowany Chocolatey" {
    
        It "[Chocolatey] jest zainstalowane]" {
            $chocoExists = Test-Path "$($env:ProgramData)\chocolatey\bin\choco.exe"
            $chocoExists | Should -BeTrue
        }
    }    
}