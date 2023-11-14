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