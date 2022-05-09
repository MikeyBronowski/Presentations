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
            $var03 = "C:\Tools\SQLDay2022"
            $var03 | Should -Exist
        }

        It "Ten test nie przejdzie" {
            $var04 = "X:\SQLDay2022"
            $var04 | Should -Exist
        }
    }
    
}