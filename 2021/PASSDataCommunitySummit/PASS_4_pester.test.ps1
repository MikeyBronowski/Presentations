Describe "Checking the event details" {
    BeforeAll {
        function Get-DataEventDetails {
            @{
                Name = "PASS Data Community Summit 2021"
                Edition = "Virtual"
            }
        }
    }

    It "The event is virtual" {
        $event = Get-DataEventDetails

        $event | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $event.Name | Should -Be "PASS Data Community Summit 2021"
        $event.Edition | Should -Match "Virtual"
    }


    It "The event is in person" {

        $event | Should -Not -BeNullOrEmpty -ErrorAction Stop
        $event.Name | Should -Be "PASS Data Community Summit 2021"
        $event.Edition | Should -Match "in person"
    }
}