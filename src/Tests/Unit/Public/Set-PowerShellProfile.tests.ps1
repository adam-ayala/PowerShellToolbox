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

Describe Set-PowerShellProfile -Tag 'Unit', 'Utility' {
    Context "When running in WinPE" {
        InModuleScope $ProjectName {
            BeforeEach {
                Mock Confirm-OSDPhase { 'WinPE' }
                Mock Write-LogEntry { }
                Mock Set-Content { }
            }
            It "it should set the PowerShell profile correctly" {
                Set-PowerShellProfile
                Should -Invoke Confirm-OSDPhase -Times 1
                Should -Invoke Set-Content -Times 1
                Should -Invoke Write-LogEntry -Times 1
            }
        }
    }
    Context "When running in Windows" {
        InModuleScope $ProjectName {
            BeforeEach {
                Mock Test-Path { $false }
                Mock Confirm-OSDPhase { 'Windows' }
                Mock Write-LogEntry { }
                Mock Set-Content { }
                Mock New-Item { }
            }
            It "it should set the PowerShell profile correctly" {
                Set-PowerShellProfile
                Should -Invoke Test-Path -Times 1
                Should -Invoke New-Item -Times 1
                Should -Invoke Set-Content -Times 1
                Should -Invoke Write-LogEntry -Times 1
            }
        }
    }
}
