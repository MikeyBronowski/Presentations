$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Demonstrating Code Coverage' {
    It 'Calls FunctionOne with no switch parameter set' {
        FunctionOne | Should -Be 'SwitchParam was not set'
    }

<########## remove this comment to see how script coverage changes
#>
    It 'Calls FunctionOne with switch parameter set' {
        FunctionOne -SwitchParam | Should -Be 'SwitchParam was set'
    }

<###########>

    It 'Calls FunctionTwo' {
        FunctionTwo | Should -Be 'I get executed'
    }
}