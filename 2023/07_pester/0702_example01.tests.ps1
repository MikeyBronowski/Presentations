Describe "Directory Creation" {
    Context 'Path' {
        It 'should contain: C:\temp' {
            $path = 'C:\temp'
            $path | Should -Exist
        }
    }

    Context "New Directory" {
        It 'Should create a new directory called TestDir' {
            $dir = 'PesterTest'
             $dir | Should -Be 'PesterTest'
        }
    }
}