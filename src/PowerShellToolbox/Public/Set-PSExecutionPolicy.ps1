#region Function Set-PSExecutionPolicy
function Set-PSExecutionPolicy {
    <#
    .SYNOPSIS
    Sets the PowerShell Execution Policy and Scope for the current session
    .DESCRIPTION
    Sets the PowerShell Execution Policy and Scope for the current session
    .EXAMPLE
    Set-PSExecutionPolicy
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
    param (
    )
    begin {
        $osdPhase = Confirm-OSDPhase
    }
    process {
        if ($osdPhase -eq 'WinPE') {
            if ((Get-ExecutionPolicy) -ne 'Bypass') {
                Write-LogEntry "[-] Set-ExecutionPolicy Bypass -Force"
                Set-ExecutionPolicy Bypass -Force
            }
            else {
                Write-LogEntry "[+] Get-ExecutionPolicy Bypass"
            }
        }
        if ($osdPhase -eq 'Windows') {
            # We should not be messing with ExecutionPolicy in Windows Phase. Display information only
            Write-LogEntry "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope Process) [Process]"
            Write-LogEntry "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope CurrentUser) [CurrentUser]"
            Write-LogEntry "[i] Get-ExecutionPolicy $(Get-ExecutionPolicy -Scope LocalMachine) [LocalMachine]"
        }
    }
    end {
    }
}
#endregion Function Set-PSExecutionPolicy
