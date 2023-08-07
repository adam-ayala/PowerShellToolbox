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

Describe Confirm-OSDPhase -Tag 'Unit', 'Utility' {
    Context "When running in WinPE" {
        InModuleScope $ProjectName {
            BeforeEach {
                Mock Test-Path { return $true }
                Mock Write-LogEntry { }
            }
            It "it should set the osdPhase variable to 'WinPE'" {
                Confirm-OSDPhase | Should -Be "WinPE"
            }
        }
    }
    Context "When the OSD phase is Specialize" {
        InModuleScope $ProjectName {
            It "it should set the osdPhase variable to 'Specialize'" {
                $state = @{
                    ImageState = 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE'
                }
                Mock Test-Path { $false }
                Mock Get-ItemProperty { return $state }
                Mock Write-LogEntry { }
                Confirm-OSDPhase | Should -Be "Specialize"
            }
        }
    }
    Context "When the OSD phase is Audit" {
        InModuleScope $ProjectName {
            It "it should set the osdPhase variable to 'AuditMode'" {
                $state = @{
                    ImageState = 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT'
                }
                Mock Test-Path { $false }
                Mock Get-ItemProperty { return $state }
                Mock Write-LogEntry { }
                Confirm-OSDPhase | Should -Be "AuditMode"
            }
        }
    }
    Context "When OSD phase is Windows" {
        InModuleScope $ProjectName {
            BeforeEach {
                Mock Test-Path { $false }
                Mock Get-ItemProperty { $null }
                Mock Write-LogEntry { }
            }
            It "it should set the osdPhase variable to 'Windows'" {
                Confirm-OSDPhase | Should -Be "Windows"
            }
        }
    }
    Context "When OSD phase is OOBE" {
        InModuleScope $ProjectName {
            BeforeEach {
                Mock Test-Path { $false }
                Mock Write-LogEntry { }
                $env:USERNAME = 'defaultuser0'
            }
            It "it should set the osdPhase variable to 'OOBE'" {
                Confirm-OSDPhase | Should -Be "OOBE"
            }
        }
    }

}
