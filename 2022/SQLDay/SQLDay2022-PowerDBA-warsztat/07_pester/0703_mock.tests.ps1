BeforeAll{
    function Build-It ($version) {
        Write-Host "a build was run for version: $version"
    }
    
    function Get-Version{
        return 'Version'
    }
    
    function Get-NextVersion {
        return 'NextVersion'
    }
    
    function Build-IfChanged {
        $thisVersion = Get-Version
        $nextVersion = Get-NextVersion
        if ($thisVersion -ne $nextVersion) { Build-It $nextVersion }
        return $nextVersion
    }
}

Describe "BuildIfChanged" {
    Context "When there are Changes" {
        BeforeEach{
            Mock Get-Version {return 1.1}
            Mock Get-NextVersion {return 1.2}
            Mock Build-It {} -Verifiable -ParameterFilter {$version -eq 1.2}
    
            $result = Build-IfChanged
        }

        It "Builds the next version" {
            Should -InvokeVerifiable
        }
        
        It "returns the next version number" {
            $result | Should -Be 1.2
        }
    }
    Context "When there are no Changes" {
        BeforeEach{
            Mock Get-Version { return 1.1 }
            Mock Get-NextVersion { return 1.1 }
            Mock Build-It {}
    
            $result = Build-IfChanged
        }

        It "Should not build the next version" {
            Should -Invoke -CommandName Build-It -Times 0 -ParameterFilter {$version -eq 1.1}
        }
    }
}