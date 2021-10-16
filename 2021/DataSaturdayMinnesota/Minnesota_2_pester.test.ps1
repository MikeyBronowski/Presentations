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