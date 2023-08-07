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

Describe Install-NuGet -Tag 'Unit', 'Utility' {
    InModuleScope $ProjectName {
        Context 'When the OSD phase is WinPE' {
            BeforeEach {
                Mock Confirm-OSDPhase { 'WinPE' }
                Mock Invoke-WebRequest { }
                Mock Test-Path { $false }
                Mock Install-PackageProvider { }
                Mock Get-PackageProvider { return @() }
                Mock Write-LogEntry { }
            }
            It 'it downloads NuGet executable to PROGRAMDATA path' {
                Mock Test-Path { return $false }
                Mock Join-Path { return 'TestDrive:\nuget.exe' }
                Install-Nuget
                Should -Invoke Invoke-WebRequest -Times 1
            }
            It 'it downloads NuGet executable to LOCALAPPDATA path' {
                Mock Test-Path { return $false }
                Mock Join-Path { return 'TestDrive:\nuget.exe' }
                Install-Nuget
                Should -Invoke Invoke-WebRequest -Times 1
            }
            It 'it installs the NuGet provider' {
                Mock Test-Path { return $false }
                Install-Nuget
                Should -Invoke Install-PackageProvider -Times 1
                Should -Invoke Write-LogEntry -Times 3
            }
            It 'it writes a verification to the log that NuGet is installed' {
                Mock Test-Path { return $false }
                Install-Nuget
                Should -Invoke Install-PackageProvider -Times 1
                Should -Invoke Write-LogEntry -Times 3
            }
        }
        Context "When in WinPE and Nuget is successfully installed" {
            BeforeAll {
                Mock Join-Path { return 'TestDrive:\nuget.exe' }
                Mock Write-LogEntry { }
                Mock Invoke-WebRequest { }
                Mock New-Item { }
            }
            It 'it logs correctly' {
                Mock Confirm-OSDPhase { return 'WinPE' }
                Mock Test-Path { $true }
                Install-NuGet
                Should -Invoke Test-Path -Times 3

            }
        }


        Context 'When the OSD phase is NOT WinPE' {
            BeforeEach {
                Mock Confirm-OSDPhase { return 'Windows' }
                Mock Write-LogEntry { }
                Mock Install-PackageProvider { }
            }
            # It 'it logs the version if the NuGet provider is already installed' {
            #     $installedModule = [PSCustomObject]@{
            #         Version = '2.8.5.201'
            #     }
            #     Mock Get-PackageProvider { return @($installedModule) }
            #     Mock Test-Path { return $true }
            #     Install-NuGet
            #     Should -Invoke Write-LogEntry -Times 1
            # }

            It 'it installs the NuGet provider if is not installed' {
                Mock Install-PackageProvider { }
                Mock Test-Path { return $false }
                Install-Nuget
                Should -Invoke Install-PackageProvider -Exactly 1 -Scope It
            }
            It 'gets and logs the installed NuGet provider version' {
                $installedModule = [PSCustomObject]@{
                    Version = '2.8.5.201'
                }
                Mock Get-PackageProvider { return @($installedModule) }
                Install-Nuget
                Should -Invoke Write-LogEntry -Times 1 -Scope It
                Should -Invoke Get-PackageProvider -Times 1

            }
        }
    }
}
