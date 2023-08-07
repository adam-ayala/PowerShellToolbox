#region Function Install-Nuget
function Install-Nuget {
    <#
    .SYNOPSIS
    Installs the latest version the NuGet package provider
    .DESCRIPTION
    Installs latest version of the the NuGet package provider
    .EXAMPLE
    Install-Nuget
    Installs latest version of the NuGet package provider
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        #region Variables
        # If we are in WinPE we might need to download NuGet for PowerShellGet, so set these static variables
        $NuGetClientSourceURL = 'https://nuget.org/nuget.exe'
        $NuGetExeName = 'NuGet.exe'
        #endregion Variables
    }
    process {
        if ($osdPhase -eq 'WinPE') {

            #region WinPE PROGRAMDATA
            $PSGetProgramDataPath = Join-Path -Path $env:PROGRAMDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
            $nugetExeBasePath = $PSGetProgramDataPath
            $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
            if (-not (Test-Path -Path $nugetExeFilePath)) {
                if (-not (Test-Path -Path $nugetExeBasePath)) {
                    $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
                Write-LogEntry "[-] Downloading NuGet to $($nugetExeFilePath)"
                $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
            }
            #endregion WinPE PROGRAMDATA

            #region WinPE LOCALAPPDATA
            $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
            $nugetExeBasePath = $PSGetAppLocalPath
            $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
            if (-not (Test-Path -Path $nugetExeFilePath)) {
                if (-not (Test-Path -Path $nugetExeBasePath)) {
                    $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }
                Write-LogEntry "[-] Downloading NuGet to $($nugetExeFilePath)"
                $null = Invoke-WebRequest -UseBasicParsing -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
            }
            #endregion WinPE LOCALAPPDATA

            if (Test-Path "$env:PROGRAMFILES\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll") {
                Write-LogEntry "[+] Nuget 2.8.5.208+"
            }
            else {
                Write-LogEntry "[-] Install-PackageProvider NuGet -MinimumVersion 2.8.5.201"
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers | Out-Null
            }
        }
        else {
            if (Test-Path "$env:PROGRAMFILES\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll") {
                Write-LogEntry "[+] Nuget 2.8.5.208+"
            }
            else {
                Write-LogEntry "[-] Install-PackageProvider NuGet -MinimumVersion 2.8.5.201"
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers | Out-Null
            }
            $InstalledModule = Get-PackageProvider -Name NuGet | Where-Object {$_.Version -ge '2.8.5.201'} | Sort-Object Version -Descending | Select-Object -First 1
            if ($InstalledModule) {
                Write-LogEntry "[+] NuGet $([string]$InstalledModule.Version)"
            }
        }
    }
    end {
    }
}
#endregion Function Install-Nuget
