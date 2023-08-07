#region Function Confirm-OSDPhase
function Confirm-OSDPhase {
    <#
    .SYNOPSIS
    Verifies the Windows Operating System deployment phase.
    .DESCRIPTION
    Verifies the Windows Operating System deployment phase. WinPE, OOBE, Specialize, Audit Mode or Windows
    .EXAMPLE
    Confirm-OSDPhase
    Confirms the Operating System Deployment phase
    .INPUTS
    None
    .OUTPUTS
    System.String
    .NOTES
    Part of the Operating System Deployment Kit
    .LINK
    https://github.com/adam-ayala/PowerShellToolbox
    #>
    [CmdletBinding()]
    param (
    )
    begin {
    }
    process {
        if (Test-Path -Path "X:\") {
            Write-LogEntry "[+] OSD Phase is WinPE."
            $osdPhase = 'WinPE'
        }
        else {
            $imageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
            if ($env:USERNAME -eq 'defaultuser0') { $osdPhase = 'OOBE' }
            elseif ($imageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') { $osdPhase = 'Specialize' }
            elseif ($imageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') { $osdPhase = 'AuditMode' }
            else {$osdPhase = 'Windows'}
            Write-LogEntry "[+] OSD Phase is $($osdPhase)."
        }
    }
    end {
        Write-Output -InputObject $osdPhase
    }
}
#endregion Function Confirm-OSDPhase