$config = New-PesterConfiguration
$config.Run.Path = ".\0704_coverage.Tests.ps1 "
$config.CodeCoverage.Enabled = $true


# Optional to scope the coverage to the list of files or directories in this path
$config.CodeCoverage.Path = ".\0704_coverage.ps1"

Invoke-Pester -Configuration $config

$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config 

$config.CodeCoverage




$config.CodeCoverage.OutputPath = "coverage.xml"
$config.CodeCoverage.OutputFormat = "JaCoCo"
ii coverage.xml

