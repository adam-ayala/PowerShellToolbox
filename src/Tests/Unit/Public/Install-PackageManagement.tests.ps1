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

Describe Install-PackageManagement -Tag 'Unit', 'Utility' {
    InModuleScope $ModuleName {
        Context 'When in the WinPE OSD phase' {
            BeforeEach {
                Mock Confirm-OSDPhase { return 'WinPE' }
                Mock Invoke-WebRequest { }
                Mock New-Item { }
                Mock Move-Item { }
                Mock Expand-Archive { }
                Mock Write-LogEntry { }
                Mock Import-Module { $null }
            }
            It 'it installs the PackageManagement module from local URL' {
                Install-PackageManagement
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
                Should -Invoke Invoke-WebRequest -Times 1
                Should -Invoke New-Item -Times 2
                Should -Invoke Expand-Archive -Times 1
                Should -Invoke Write-LogEntry -Times 1
            }
        }
        Context 'When not running in WinPE' {
            BeforeEach {
                Mock Confirm-OSDPhase { return 'Windows' }
                Mock Install-PackageProvider { }
                Mock Import-Module { }
                Mock Start-Sleep { }
                Mock Write-LogEntry { }
                Mock Get-PackageProvider { }
                Mock Get-Module { $null }
                Mock New-Item { }
                Mock Invoke-WebRequest { }
            }
            It 'installs the necessary modules if not already installed' {
                Mock Get-PackageProvider { $null }
                #Mock -CommandName 'Get-PSRepository' -ModuleName 'PowerShellGet'
                Mock Install-Module { }
                Install-PackageManagement
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
                Should -Invoke Install-PackageProvider -Times 1
                Should -Invoke Import-Module -Times 2
                Should -Invoke Start-Sleep -Times 2
                Should -Invoke Write-LogEntry -Times 2
            }
            It 'verifies the installed modules' {
                Mock Get-PackageProvider {
                    return [PSCustomObject]@{
                        Name = 'PowerShellGet'
                        Version = '2.2.5'
                    }
                }
                Mock Get-Module {
                    return [PSCustomObject]@{
                        Name = 'PackageManagement'
                        Version = '1.4.8.1'
                    }
                }
                Install-PackageManagement
                Should -Invoke Confirm-OSDPhase -Times 1 -Exactly
                Should -Invoke Import-Module -Times 2
                Should -Invoke Write-LogEntry -Times 2
            }
        }
    }
}
