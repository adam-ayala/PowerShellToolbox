$ProjectRoot = "$PSScriptRoot\..\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectRoot\*\*\*.psd1).Where{
    ($_.Directory.Name -match 'src' -or $_.Directory.Name -eq $_.BaseName) -and
    $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
}).BaseName
#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ProjectName, "$ProjectName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ProjectName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ProjectName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope $ModuleName {

Describe Set-PSExecutionPolicy -Tag 'Unit','Utility' {
    Context 'When in the WinPE OSD phase' {
        BeforeAll {
            Mock Confirm-OSDPhase { return 'WinPE' }
        }
        It 'it sets execution policy to Bypass when not already set' {
            Mock Get-ExecutionPolicy { return 'Undefined' }
            Mock Write-LogEntry { }
            Set-PSExecutionPolicy
            Should -Invoke Write-LogEntry -Times 1
        }
        It 'it only logs when execution policy is already set to Bypass' {
            Mock Get-ExecutionPolicy { return 'Bypass' }
            Mock Write-LogEntry { }
            Set-PSExecutionPolicy
            Should -Invoke Write-LogEntry -Times 1
        }
    }
    Context "When in the Windows OSD Phase" {
        BeforeAll {
            Mock Confirm-OSDPhase { 'Windows' }
        }
        It 'only displays information but does not set the execution policy' {
            # Mock Get-ExecutionPolicy for different scopes
            Mock Get-ExecutionPolicy -ParameterFilter { $_ -eq 'Process' } { return 'ProcessScopePolicy' }
            Mock Get-ExecutionPolicy -ParameterFilter { $_ -eq 'CurrentUser' } { return 'CurrentUserScopePolicy' }
            Mock Get-ExecutionPolicy -ParameterFilter { $_ -eq 'LocalMachine' } { return 'LocalMachineScopePolicy' }
            Mock Write-LogEntry { }
            Set-PSExecutionPolicy
            Should -Invoke Write-LogEntry -Times 3
        }
    }
}
}
