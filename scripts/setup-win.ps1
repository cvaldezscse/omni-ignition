<#
.SYNOPSIS
    Windows bootstrap entry point for omni-ignition ("Layer 0").
.DESCRIPTION
    Runs from inside an already-cloned copy of the repo. Guarantees an
    elevated session, a usable Execution Policy, and a package manager
    (winget, falling back to Chocolatey). Idempotent: every check
    short-circuits if the prerequisite is already satisfied. Supports
    Windows 10 (22H2+) and 11. Prints a compact checklist of what
    succeeded/failed at the end (see lib/Logger.ps1 Add-Summary*).
.PARAMETER Uninstall
    Reverses only what THIS toolkit installed (tracked in state.env).
    Anything that pre-existed on the machine is left untouched.
.EXAMPLE
    git clone https://github.com/cvaldezscse/omni-ignition.git $env:USERPROFILE\.omni-ignition
    cd $env:USERPROFILE\.omni-ignition
    .\scripts\setup-win.ps1
    .\scripts\setup-win.ps1 -Uninstall
#>

param([switch]$Uninstall)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptDir
. (Join-Path $ScriptDir "lib\Logger.ps1")
. (Join-Path $ScriptDir "lib\State.ps1")

Initialize-Log
Initialize-State

# --- Uninstall path ------------------------------------------------------------
if ($Uninstall) {
    Write-LogStep "Restoring machine to its pre-bootstrap state"

    if (Test-InstalledByUs "chocolatey") {
        try {
            Remove-Item -Recurse -Force "$env:ProgramData\chocolatey" -ErrorAction Stop
            Set-State -Key "installed_chocolatey" -Value "false"
            Write-LogSuccess "Chocolatey removed"
            Add-SummaryOk "Chocolatey removed"
        } catch {
            Write-LogError "Failed to remove Chocolatey" -Command $_.Exception.Message
            Add-SummaryFail "Chocolatey removal" $_.Exception.Message
        }
    } else {
        Write-LogInfo "Chocolatey wasn't installed by this toolkit (or winget, a Windows component, was used) — nothing to remove"
        Add-SummaryOk "Chocolatey/winget (left untouched, pre-existed)"
    }

    $priorPolicy = Get-State -Key "prior_execution_policy"
    if ($priorPolicy) {
        Write-LogWarn "Restoring original Execution Policy: $priorPolicy"
        Set-ExecutionPolicy -ExecutionPolicy $priorPolicy -Scope CurrentUser -Force
        Add-SummaryOk "Execution Policy restored to $priorPolicy"
    }

    Show-Summary
    Write-LogSuccess "Restore complete. Full log at $script:LogDir"
    exit 0
}

# --- Install path ----------------------------------------------------------------
Write-LogStep "Layer 0: checking prerequisites"

# 1. Require an elevated session (installs need it)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-LogWarn "Not running as Administrator — relaunching elevated"
    $relaunchArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($Uninstall) { $relaunchArgs += " -Uninstall" }
    Start-Process powershell -Verb RunAs -ArgumentList $relaunchArgs
    exit
}
Write-LogSuccess "Running with Administrator privileges"

# 2. Windows version (informational — Win10 22H2+ and Win11 supported)
$os = Get-CimInstance Win32_OperatingSystem
Write-LogInfo "Detected OS: $($os.Caption) (build $($os.BuildNumber))"

# 3. Execution Policy — the ORIGINAL value is captured once, so -Uninstall
#    can restore it exactly, even across multiple idempotent re-runs.
$policy = Get-ExecutionPolicy -Scope CurrentUser
Set-StateIfAbsent -Key "prior_execution_policy" -Value "$policy"
if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
        Write-LogSuccess "Execution Policy set to RemoteSigned"
        Add-SummaryOk "Execution Policy (RemoteSigned)"
    } catch {
        Write-LogError "Failed to set Execution Policy" -Command $_.Exception.Message
        Add-SummaryFail "Execution Policy" $_.Exception.Message
    }
} else {
    Write-LogSuccess "Execution Policy already permissive ($policy)"
    Add-SummaryOk "Execution Policy ($policy)"
}

# 4. Package manager: winget, falling back to Chocolatey (only Chocolatey
#    is ever tracked for removal — winget is a Windows OS component).
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-LogSuccess "winget already available ($(winget --version))"
    Add-SummaryOk "winget"
} else {
    Write-LogWarn "winget not found — attempting to register App Installer"
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" -ErrorAction Stop
        Write-LogSuccess "winget registered via App Installer"
        Add-SummaryOk "winget"
    } catch {
        Write-LogWarn "App Installer registration failed (likely older Win10) — falling back to Chocolatey"
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Set-InstalledByUs "chocolatey"
            Write-LogSuccess "Chocolatey installed as fallback package manager"
            Add-SummaryOk "Chocolatey (fallback)"
        } catch {
            Write-LogError "Failed to install a package manager (winget and Chocolatey both failed)" -Command $_.Exception.Message
            Add-SummaryFail "Package manager (winget/Chocolatey)" $_.Exception.Message
        }
    }
}

Write-LogStep "Layer 0 complete"
Show-Summary
# TODO: winget import --import-file "$RepoRoot\os\windows\packages.json" (or choco equivalent fallback)
# TODO: dispatch to scripts/modules/windows/*.ps1 (Java resolver, Android SDK, Appium, dotfiles)