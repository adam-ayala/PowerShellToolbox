#region Function Write-LogEntry
function Write-LogEntry {
    <#
    .SYNOPSIS
    Writes a detailed and informational log entry
    .DESCRIPTION
    Writes a detailed and informational log entry
    .PARAMETER Value
    Writes an informational log entry
    .PARAMETER Severity
    Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.
    .PARAMETER FileName
    Name of the log file that the entry will written to.
    .PARAMETER LogsDirectory
    Path to the logging directory.
    .EXAMPLE
    Write-LogEntry -Value "This is a message" -Severity 2
    Writes a log entry
    .INPUTS
    None
    .OUTPUTS
    None
    .NOTES
    This function is only useful during a Task Sequence or Windows operating system deployment
    Part of the Operating System Deployment Kit
    .LINK
    https://github.com/adam-ayala/PowerShellToolbox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Value added to the log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [Parameter(Mandatory = $false, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("1", "2", "3")]
        [string]$Severity = 1,
        [Parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "OSDkit.log", # Default to the OSDkit for now
        [Parameter(Mandatory = $false)]
        [string]$LogsDirectory
    )
    begin {
        # Get the logging file path
        if (-not $PSBoundParameters.ContainsKey('LogsDirectory')) {
            if (Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT) {
                $LogsDirectory = 'X:\Windows\TEMP'
            }
            else {
                $LogsDirectory = $env:TEMP
            }
        }
        $logFilePath = Join-Path -Path $LogsDirectory -ChildPath $FileName
    }
    process {
        # Construct time format for log entry
        $Time = Get-Date -Format "HH:mm:ss.fff"
        # Construct date format for log entry
        $Date = Get-Date -Format "MM-dd-yyyy"
        # Construct context for log entry
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        # Construct final log entry
        $logText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""OSD"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
        # Add the entry to the log file and write output to the console for debugging
        try {
            Out-File -InputObject $logText -Append -NoClobber -FilePath $logFilePath -ErrorAction Stop -Encoding default
            Write-Output "$($Value)"
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to append log entry to $($FileName) file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
    }
    end {
    }
}
#endregion Function Write-LogEntry
