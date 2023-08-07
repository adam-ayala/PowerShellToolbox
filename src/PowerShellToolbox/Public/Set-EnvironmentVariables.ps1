#region Function Set-EnvironmentVariables
function Set-EnvironmentVariables {
    <#
    .SYNOPSIS
    Sets the environment variables a PowerShell session for WinPE
    .DESCRIPTION
    Sets the environment variables a PowerShell session for WinPE
    .EXAMPLE
    Set-EnvironmentVariables
    Sets the environment variables
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='I like plural nouns')]
    param (
    )
    begin {
        $osdPhase = Confirm-OSDPhase
    }
    process {
        if ($osdPhase -eq 'WinPE') {
            if (Get-Item env:\LOCALAPPDATA -ErrorAction Ignore) {
                Write-LogEntry "[+] Set LocalAppData in System Environment"
            }
            else {
                Write-LogEntry "[+] Set LocalAppData in System Environment"
                Write-LogEntry 'WinPE does not have the LocalAppData System Environment Variable'
                Write-LogEntry 'This can be enabled for this Power Session, but it will not persist'
                Write-LogEntry 'Set System Environment Variable LocalAppData for this PowerShell session'
                [System.Environment]::SetEnvironmentVariable('APPDATA',"$env:USERPROFILE\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
                [System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$env:SYSTEMDRIVE",[System.EnvironmentVariableTarget]::Process)
                [System.Environment]::SetEnvironmentVariable('HOMEPATH',"$env:USERPROFILE",[System.EnvironmentVariableTarget]::Process)
                [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:USERPROFILE\AppData\Local",[System.EnvironmentVariableTarget]::Process)
            }
        }
    }
    end {
    }
}
#endregion Function Set-EnvironmentVariables
