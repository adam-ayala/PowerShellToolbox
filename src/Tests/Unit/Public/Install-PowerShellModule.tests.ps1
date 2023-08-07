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

Describe Install-PowerShellModule -Tag 'Unit', 'Utility' {
    InModuleScope $ModuleName {
        Context 'When the module is not installed' {
            BeforeEach {
                Mock Install-Module { }
                Mock Write-LogEntry { }
                Mock Find-Module {
                    return [PSCustomObject]@{
                        Name = 'TestModule'
                        Version = '1.0.0'
                    }
                }
                Mock Get-Module { $null }
            }
            It 'in WinPE it installs the module from the PowerShell Gallery' {
                Mock Confirm-OSDPhase { return 'WinPE' }
                Install-PowerShellModule -Name 'TestModule'
                Should -Invoke Install-Module -Times 1
                Should -Invoke Write-LogEntry -Times 1
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
            }
            It 'in OOBE it installs the module from the PowerShell Gallery' {
                Mock Confirm-OSDPhase { return 'OOBE' }
                Install-PowerShellModule -Name 'TestModule'
                Should -Invoke Install-Module -Times 1
                Should -Invoke Write-LogEntry -Times 1
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
            }
            It 'in Windows it installs the module from the PowerShell Gallery' {
                Mock Confirm-OSDPhase { return 'Windows' }
                Install-PowerShellModule -Name 'TestModule'
                Should -Invoke Install-Module -Times 1
                Should -Invoke Write-LogEntry -Times 1
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
            }
        }
        Context 'When module is already installed and up to date' {
            BeforeEach {
                Mock Write-LogEntry { }
                Mock Import-Module { }
                Mock Find-Module {
                    return [PSCustomObject]@{
                        Name = 'TestModule'
                        Version = '1.0.0'
                    }
                }
                Mock Get-Module {
                    return [PSCustomObject]@{
                        Name = 'TestModule'
                        Version = '1.0.0'
                    }
                }
            }
            It 'it imports the module and logs its version' {
                Install-PowerShellModule -Name 'TestModule'
                Should -Invoke Import-Module -Times 1
                Should -Invoke Write-LogEntry -Times 1
            }
        }
        Context 'When module is installed but outdated' {
            BeforeEach {
                Mock Import-Module { }
                Mock Get-Module {
                    return [PSCustomObject]@{
                        Name = 'TestModule'
                        Version = '0.9.0'
                    }
                }
            }
            It 'installs the newer module version from the PowerShell Gallery' {
                Mock Find-Module {
                    return [PSCustomObject]@{
                        Name = 'TestModule'
                        Version = '1.0.0'
                    }
                }
                Mock Install-Module { }
                Install-PowerShellModule -Name 'TestModule'
                Should -Invoke Install-Module -Times 1
            }
        }
    }
}
