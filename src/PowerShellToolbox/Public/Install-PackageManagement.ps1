#region Function Install-PackageManagement
function Install-PackageManagement {
    <#
    .SYNOPSIS
    This function installs the necessary Package Management modules for the Windows operating system deployments
    .DESCRIPTION
    This function installs the necessary Package Management modules for the Windows operating system deployments
    This includes PackageManagement and PowerShellGet
    .EXAMPLE
    Install-Packagement
    Installs the PowerShellGet and Packagement modules
    .INPUTS
    None
    .OUTPUTS
    None
    .NOTES
    Part of the Operating System Deployment Kit
    .LINK
    https://github.com/adam-ayala/PowerShellToolbox
    #>
    [CmdletBinding()]
    param (
    )
    begin {
        $osdPhase = Confirm-OSDPhase
        $localURL = 'https://sccm-web.amaisd.org/utility/PackageManagement.1.4.8.1.zip'
    }
    process {
        if ($osdPhase -eq 'WinPE') {
            # We're in WinPE. Get the local package and copy it over since we can't 'Install' it
            $installedModule = Import-Module PackageManagement -PassThru -ErrorAction Ignore
            if (-not $installedModule) {
                Write-LogEntry "[-] Installing PackageManagement 1.4.8.1 for WinPE"
                Invoke-WebRequest -UseBasicParsing -Uri $localURL -OutFile "$env:TEMP\PackageManagement.1.4.8.1.zip"
                $null = New-Item -Path "$env:TEMP\1.4.8.1" -ItemType Directory -Force
                Expand-Archive -Path "$env:TEMP\PackageManagement.1.4.8.1.zip" -DestinationPath "$env:TEMP\1.4.8.1"
                $null = New-Item -Path "$env:PROGRAMFILES\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
                Move-Item -Path "$env:TEMP\1.4.8.1" -Destination "$env:PROGRAMFILES\WindowsPowerShell\Modules\PackageManagement\1.4.8.1"
                Import-Module PackageManagement -Force -Scope Global
            }
        }
        else {
            # We're not in WinPE. Let's install and verify
            #region Installation
            $installedModule = Get-PackageProvider -Name PowerShellGet | Where-Object { $_.Version -ge '2.2.5' } | Sort-Object Version -Descending | Select-Object -First 1
            if (-not $installedModule) {
                Write-LogEntry "[-] Install-PackageProvider PowerShellGet -MinimumVersion 2.2.5"
                Install-PackageProvider -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Scope AllUsers -Source 'https://sccm-web.amaisd.org/NuGet/nuget' | Out-Null
                Import-Module PowerShellGet -Force -Scope Global -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5
            }
            $installedModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object {$_.Version -ge '1.4.8.1'} | Sort-Object Version -Descending | Select-Object -First 1
            if (-not ($installedModule)) {
                Write-LogEntry "[-] Install-Module PackageManagement -MinimumVersion 1.4.8.1"
                Install-Module -Name PackageManagement -MinimumVersion 1.4.8.1 -Force -Confirm:$false -Repository PSGallery -Scope AllUsers
                Import-Module PackageManagement -Force -Scope Global -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5
            }
            #endregion Installation

            #region Verification
            Import-Module PackageManagement -Force -Scope Global -ErrorAction SilentlyContinue
            $installedModule = Get-Module -Name PackageManagement -ListAvailable | Where-Object {$_.Version -ge '1.4.8.1'} | Sort-Object Version -Descending | Select-Object -First 1
            if ($installedModule) {
                Write-LogEntry "[+] PackageManagement $([string]$InstalledModule.Version)"
            }
            Import-Module PowerShellGet -Force -Scope Global -ErrorAction SilentlyContinue
            $installedModule = Get-PackageProvider -Name PowerShellGet | Where-Object {$_.Version -ge '2.2.5'} | Sort-Object Version -Descending | Select-Object -First 1
            if ($InstalledModule) {
                Write-LogEntry "[+] PowerShellGet $([string]$InstalledModule.Version)"
            }
            #endregion Verification
        }
    }
    end {
    }
}
#endregion Function Install-PackageManagement