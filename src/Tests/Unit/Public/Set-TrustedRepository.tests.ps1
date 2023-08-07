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

Describe Set-TrustedRepository -Tag 'Unit' {
    Context 'While setting up the repository' {
        InModuleScope $ProjectName {
            It 'it sets the repo to Trusted if it is Untrusted' {
                $psGalleryMock = [PSCustomObject]@{
                    Name = 'PSGallery'
                    InstallationPolicy = 'Untrusted'
                }
                Mock Get-PSRepository { return $psGalleryMock }
                Mock -CommandName 'Get-PSRepository' -ModuleName 'PowerShellGet'
                Mock Set-PSRepository { }
                Set-TrustedRepository
                Should -Invoke Set-PSRepository -Scope It -Exactly 1
            }
        }
        InModuleScope $ProjectName {
            It 'it only logs if it is already Trusted' {
                Mock Write-LogEntry { }
                $psGalleryMock = [PSCustomObject]@{
                    Name = 'PSGallery'
                    InstallationPolicy = 'Trusted'
                }
                Mock Get-PSRepository { return $psGalleryMock }
                Mock -CommandName 'Get-PSRepository' -ModuleName 'PowerShellGet'
                Set-TrustedRepository
                Should -Invoke Write-LogEntry -Scope It -Exactly 1
            }
        }
    }
}
