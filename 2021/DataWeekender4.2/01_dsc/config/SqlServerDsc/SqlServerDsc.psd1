@{
    # Version number of this module.
    moduleVersion      = '15.2.0'

    # ID used to uniquely identify this module
    GUID               = '693ee082-ed36-45a7-b490-88b07c86b42f'

    # Author of this module
    Author             = 'DSC Community'

    # Company or vendor of this module
    CompanyName        = 'DSC Community'

    # Copyright statement for this module
    Copyright          = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description        = 'Module with DSC resources for deployment and configuration of Microsoft SQL Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion  = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion         = '4.0'

    # Functions to export from this module
    FunctionsToExport  = @()

    # Cmdlets to export from this module
    CmdletsToExport    = @()

    # Variables to export from this module
    VariablesToExport  = @()

    # Aliases to export from this module
    AliasesToExport    = @()

    DscResourcesToExport = @('SqlAG','SqlAGDatabase','SqlAgentAlert','SqlAgentFailsafe','SqlAgentOperator','SqlAGListener','SqlAGReplica','SqlAlias','SqlAlwaysOnService','SqlConfiguration','SqlDatabase','SqlDatabaseDefaultLocation','SqlDatabaseMail','SqlDatabaseObjectPermission','SqlDatabasePermission','SqlDatabaseRole','SqlDatabaseUser','SqlEndpoint','SqlEndpointPermission','SqlLogin','SqlMaxDop','SqlMemory','SqlPermission','SqlProtocol','SqlProtocolTcpIp','SqlReplication','SqlRole','SqlRS','SqlRSSetup','SqlScript','SqlScriptQuery','SqlSecureConnection','SqlServiceAccount','SqlSetup','SqlTraceFlag','SqlWaitForAG','SqlWindowsFirewall','SqlDatabaseOwner','SqlDatabaseRecoveryModel','SqlServerEndpointState','SqlServerNetwork')

    RequiredAssemblies = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData        = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/SqlServerDsc/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/SqlServerDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [15.2.0] - 2021-09-01

### Changed

- SqlServerDsc
  - Changed to the new GitHub deploy tasks that is required for the latest
    version of the Sampler module.
  - Updated pipeline configuration to align with the latest changes in [Sampler](https://github.com/gaelcolas/Sampler).
  - Update codecov.yml to support carry forward flags.
  - Updated pipelines files to latest from Sampler project.
  - Updated GitHub issue templates.
  - Remove pipeline jobs `Test_Integration_SQL2016`, `Test_Integration_SQL2017`,
    and `Test_Integration_SQL2019` and raplaced with a single job
    `Test_Integration` ([issue #1713](https://github.com/dsccommunity/SqlServerDsc/issues/1713)).
  - Update HQRM tests to run on the VM image `windows-2022`.
  - Update unit tests to run on the VM image `windows-2022`.
  - Update integration tests to run both on Windows Server 2019 and Windows
    Server 2022 ([issue #1713](https://github.com/dsccommunity/SqlServerDsc/issues/1713)).
- SqlSetup
  - The helper function `Connect-SqlAnalysis` was using `LoadWithPartial()`
    to load the assembly _Microsoft.AnalysisServices_. On a node where multiple
    instances with different versions of SQL Server (regardless of features)
    is installed, this will result in the first assembly found in the
    GAC will be loaded into the session, not taking versions into account.
    This can result in an assembly version being loaded that is not compatible
    with the version of SQL Server it was meant to be used with.
    A new method of loading the assembly _Microsoft.AnalysisServices_ was
    introduced under a feature flag; `''AnalysisServicesConnection''`.
    This new functionality depends on the [SqlServer](https://www.powershellgallery.com/packages/SqlServer)
    module, and must be present on the node. The [SqlServer](https://www.powershellgallery.com/packages/SqlServer)
    module can be installed on the node by leveraging the new DSC resource
    `PSModule` in the [PowerShellGet](https://www.powershellgallery.com/packages/PowerShellGet/2.1.2)
    module (v2.1.2 and higher). This new method does not work with the
    SQLPS module due to the SQLPS module does not load the correct assembly,
    while [SqlServer](https://www.powershellgallery.com/packages/SqlServer)
    module (v21.1.18080 and above) does. The new functionality is used
    when the parameter `FeatureFlag` is set to `''AnalysisServicesConnection''`.
    This functionality will be the default in a future breaking release.
  - Under a feature flag `''AnalysisServicesConnection''`. The detection of
    a successful connection to the SQL Server Analysis Services has also been
    changed. Now it actually evaluates the property `Connected` of the returned
    `Microsoft.AnalysisServices.Server` object. The new functionality is used
    when the parameter `FeatureFlag` is set to `''AnalysisServicesConnection''`.
    This functionality will be the default in a future breaking release.
- SqlAgentAlert
  - Switched README file with SqlAgentFailsafe ([issue #1709](https://github.com/dsccommunity/SqlServerDsc/issues/1397)).
- SqlAgentFailsafe
  - Switched README file with SqlAgentAlert ([issue #1709](https://github.com/dsccommunity/SqlServerDsc/issues/1397)).

### Added

- SqlMemory
  - Added two new optional parameters MinMemoryPercent and MaxMemoryPercent.
    Provides the ability to set the minimum and/or maximum buffer pool used by
    the SQL Server instance as a percentage of total server memory.
    ([issue #1397](https://github.com/dsccommunity/SqlServerDsc/issues/1397)).
- SqlRSSetup
  - Integration tests now install _Microsoft SQL Server 2019 Reporting Services_
    ([issue #1717](https://github.com/dsccommunity/SqlServerDsc/issues/1717)).
- SqlRS
  - Integration tests now configures _Microsoft SQL Server 2019 Reporting Services_.

### Fixed

- SqlSetup
  - Fixed integration tests for SQL Server 2016 and SQL Server 2017.
- SqlServerDsc.Common
  - Fixed so that _CredScan_ no longer reports a password false-positive
    ([issue #1712](https://github.com/dsccommunity/SqlServerDsc/issues/1712)).
- SqlRS
  - Fixed SSRS 2019 initialization ([issue #1509](https://github.com/dsccommunity/SqlServerDsc/issues/1509)).
  - Fix a problem that did not correctly evaluate the `UseSSL` property against
    the current state.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
