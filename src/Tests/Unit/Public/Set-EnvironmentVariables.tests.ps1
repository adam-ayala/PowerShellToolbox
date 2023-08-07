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

Describe Set-EnvironmentVariables -Tag 'Unit', 'Utility' {
    Context 'When in the WinPE OSD phase' {
        InModuleScope $ProjectName {
            BeforeAll {
                Mock Confirm-OSDPhase { return 'WinPE' }
            }
            It 'sets LocalAppData in System Environment when it does not exist' {
                Mock Get-Item { return $false }
                Mock Write-LogEntry { }

                Set-EnvironmentVariables

                Should -Invoke Get-Item -Times 1
                Should -Invoke Write-LogEntry -Times 4
            }
            It 'it only logs of the LocalAppData is set' {
                Mock Get-Item { return $true }
                Mock Write-LogEntry { }

                Set-EnvironmentVariables

                Should -Invoke Get-Item -Times 1
                Should -Invoke Write-LogEntry -Times 1
            }
        }
    }
}
