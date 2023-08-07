#region Function Set-TrustedRepository
function Set-TrustedRepository {
    <#
    .SYNOPSIS
    Sets the installation policy on Trusted PowerShell Repositories
    .DESCRIPTION
    Sets the installation policy on Trusted PowerShell Repositories
    .EXAMPLE
    Set-TrustedRepository
    Sets the installation policy on Trusted PowerShell Repositories
    .INPUTS
    None
    .OUTPUTS
    None
    .NOTES
    Part of the Operating System Deployment Kit
    .LINK
    https://github.com/adam-ayala/PowerShellToolbox
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification='None')]
    param (
    )
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    }
    process {
        if ((Get-PSRepository -Name 'PSGallery' -ErrorAction 'Ignore').InstallationPolicy -ne 'Trusted') {
            Write-LogEntry "[-] Set-PSRepository PSGallery Trusted"
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
        }
        if ((Get-PSRepository -Name 'PSGallery' -ErrorAction 'Ignore').InstallationPolicy -eq 'Trusted') {
            Write-LogEntry "[+] PSRepository PSGallery Trusted"
        }
    }
    end {
    }
}
#endregion Function Set-TrustedRepository