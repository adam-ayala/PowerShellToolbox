#region Function Install-PowerShellModule
function Install-PowerShellModule {
    <#
    .SYNOPSIS
    Installs a PowerShell Module
    .DESCRIPTION
    Installs a PowerShell Module
    .PARAMETER Name
    Name of the PowerShell Module
    .PARAMETER Force
    Force the PowerShell Module install
    .EXAMPLE
    Install-PowerShellModule -Name MyModule -Force
    Force installs the MyModule PowerShell Module
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
        [Parameter(Mandatory = $true, HelpMessage = "The name of the PowerShell Module to install")]
        [string]$Name
    )
    begin {
        $osdPhase = Confirm-OSDPhase
        # Set this flag first so we can verify later
        $install = $false
        # Get the properties of the installed module. If it is not available null it.
        $installedModule = Get-Module -Name $Name -ListAvailable -ErrorAction Ignore | Sort-Object Version -Descending | Select-Object -First 1
        $PSGalleryModule = Find-Module -Name $Name -ErrorAction Ignore -WarningAction Ignore
    }
    process {
        if ($installedModule) {
            # If it is installed let's compare versions. Get the version of the module from the PowerShell Gallery
            if (($PSGalleryModule.Version -as [version]) -gt ($installedModule.Version -as [version])) {
                # The version in the gallery is newer than the installed version, so let's update
                $install = $true
            }
        }
        else {
            # Get-Module did not find the module so we need to install it
            $install = $true
        }
        #region Install Module
        if ($install) {
            if ($osdPhase -eq 'WinPE') {
                Write-LogEntry "[-] $($Name) $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $Name -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
            }
            elseif ($osdPhase -eq 'OOBE') {
                Write-LogEntry "[-] $($Name) $($GalleryPSModule.Version) [AllUsers]"
                Install-Module $Name -Scope AllUsers -Force -SkipPublisherCheck -AllowClobber
            }
            else {
                # Install the PowerShell Module in the OS
                Write-LogEntry "[-] $($Name) $($GalleryPSModule.Version) [CurrentUser]"
                Install-Module $Name -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
            }
        }
        #endregion Install Module
        else {
            # The module is already installed and up to date
            Import-Module -Name $Name -Force
            Write-LogEntry "[+] $($Name) $($InstalledModule.Version)"
        }
    }
    end {
    }
}
#endregion Function Install-PowerShellModule