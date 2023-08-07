#region Function Set-PowerShellProfile
function Set-PowerShellProfile {
    <#
    .SYNOPSIS
    This function sets the default PowerShell profile for a PowerShell session
    .DESCRIPTION
    This function sets the default PowerShell profile for a PowerShell session
    .EXAMPLE
    Set-PowerShellProfile
    Sets the default PowerShell profile depending on the OS
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
        $winpePowerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('APPDATA',"$env:USERPROFILE\AppData\Roaming",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEDRIVE',"$env:SYSTEMDRIVE",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('HOMEPATH',"$Env:USERPROFILE",[System.EnvironmentVariableTarget]::Process)
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:USERPROFILE\AppData\Local",[System.EnvironmentVariableTarget]::Process)
'@
        $powerShellProfile = @'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
[System.Environment]::SetEnvironmentVariable('Path',$Env:Path + ";$Env:ProgramFiles\WindowsPowerShell\Scripts",'Process')
'@
    }
    process {
        if ($osdPhase -eq 'WinPE') {
            Write-LogEntry "[+] Set LocalAppData in PowerShell Profile"
            $winpePowerShellProfile | Set-Content -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
        }
        else {
            if (-not (Test-Path $Profile.CurrentUserAllHosts)) {
                Write-LogEntry "[+] Set LocalAppData in PowerShell Profile [CurrentUserAllHosts]"
                $null = New-Item $Profile.CurrentUserAllHosts -ItemType File -Force
                $powerShellProfile | Set-Content -Path $Profile.CurrentUserAllHosts -Force -Encoding Unicode
            }
        }
    }
    end {
    }
}
#endregion Function Set-PowerShellProfile
