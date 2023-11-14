
Describe "Check SQL instance" -Tag "instance" {
    Context "Basic information" -Tag "info" {
        
        BeforeAll {
            $sqlInstance = Connect-DbaInstance -sqlInstance localhost
            $tempdbFiles = $sqlInstance | Get-DbaDbFile -Database tempdb -FileGroup PRIMARY
            $agent = $sqlInstance | Get-DbaAgentServer
        }

        It "Should be Enterprise Edition" -Tag "config" {
            
            $sqlInstance.DatabaseEngineEdition | Should -Be "Enterprise"
        }

        It "Should be Standalone" -Tag "config" {
            
            $sqlInstance.DatabaseEngineType | Should -Be "Standalone"
        }


        It "Should have Tcp Eenabled" -Tag "config" {
            
            $sqlInstance.TcpEnabled | Should -BeTrue
        }

        It "Should have Hadr enabled" -Tag "config" {
            
            $sqlInstance.IsHadrEnabled | Should -BeTrue
        }

        It "Should have be CaseSensitive" -Tag "config" {
            
            $sqlInstance.IsCaseSensitive | Should -BeTrue
        }

        It "TempDb has at least 4 files" -Tag "tempdb" {
            $tempdbFiles.Count | Should -BeGreaterOrEqual 4
        }

        It "Agent job history is default" -Tag "agent" {
            $agent.JobHistoryIsEnabled | Should -BeTrue
            $agent.MaximumHistoryRows | Should -Be 1000
            $agent.MaximumJobHistoryRows | Should -Be 100
        }
        
    }
    
}


