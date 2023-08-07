
@{
RootModule = 'PowerShellToolbox.psm1'
ModuleVersion = '0.0.1'
# CompatiblePSEditions = @()
GUID = '433b5cc2-3936-41f6-a8bc-490556530a66'
Author = 'Adam Ayala'
CompanyName = 'adam-ayala'
Copyright = '(c) 2023 Adam Ayala. All rights reserved.'
Description = 'PowerShell module containing utility functions for Windows OS'
# PowerShellVersion = ''
# PowerShellHostName = ''
# PowerShellHostVersion = ''
# DotNetFrameworkVersion = ''
# CLRVersion = ''
# ProcessorArchitecture = ''
# RequiredModules = @()
# RequiredAssemblies = @()
# ScriptsToProcess = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
FunctionsToExport = @(
    'Confirm-OSDPhase',
    'Install-Nuget',
    'Install-PackageManagement',
    'Install-PowerShellModule',
    'Set-EnvironmentVariables',
    'Set-PowerShellProfile',
    'Set-PSExecutionPolicy',
    'Set-TrustedRepository',
    'Write-LogEntry'
)
CmdletsToExport = @()
VariablesToExport = @()
AliasesToExport = @()
# DscResourcesToExport = @()
# ModuleList = @()
# FileList = @()
PrivateData = @{
    PSData = @{
        # Tags = @()
        # LicenseUri = ''
        ProjectUri = 'https://github.com/adam-ayala/PowerShellToolbox'
        # IconUri = ''
        # ReleaseNotes = ''
    }
}
# HelpInfoURI = ''
# DefaultCommandPrefix = ''
}


