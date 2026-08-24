<#
.SYNOPSIS
    Persistent state tracking for omni-ignition (Windows).
.DESCRIPTION
    Mirrors scripts/lib/state.sh: flat key=value pairs stored in
    %USERPROFILE%\.omni-ignition\state.env. Records what THIS toolkit
    installed/changed so -Uninstall only reverses those things, never
    anything that pre-existed on the machine.
#>

$script:StateRoot = if ($env:OMNI_STATE_ROOT) { $env:OMNI_STATE_ROOT } else { Join-Path $env:USERPROFILE ".omni-ignition" }
$script:StateFile = Join-Path $script:StateRoot "state.env"

# Ensures the state file exists. Safe to call multiple times.
function Initialize-State {
    New-Item -ItemType Directory -Path $script:StateRoot -Force | Out-Null
    if (-not (Test-Path $script:StateFile)) { New-Item -ItemType File -Path $script:StateFile -Force | Out-Null }
}

# Reads a value by key. Returns $null if the key isn't set.
# Params: Key
function Get-State {
    param([string]$Key)
    $line = Get-Content $script:StateFile -ErrorAction SilentlyContinue |
        Where-Object { $_ -match "^$Key=" } | Select-Object -First 1
    if ($line) { return ($line -split "=", 2)[1] }
    return $null
}

# Sets/overwrites a key, replacing any prior value.
# Params: Key, Value
function Set-State {
    param([string]$Key, [string]$Value)
    $lines = @(Get-Content $script:StateFile -ErrorAction SilentlyContinue |
        Where-Object { $_ -notmatch "^$Key=" })
    $lines += "$Key=$Value"
    Set-Content -Path $script:StateFile -Value $lines
}

# Sets a key ONLY if absent — captures the true "before" baseline exactly
# once (e.g. the original Execution Policy), so re-runs never overwrite it.
# Params: Key, Value
function Set-StateIfAbsent {
    param([string]$Key, [string]$Value)
    if (-not (Get-State -Key $Key)) { Set-State -Key $Key -Value $Value }
}

# Marks a component as installed BY THIS TOOLKIT (vs. pre-existing).
# Params: Component name (e.g. "chocolatey")
function Set-InstalledByUs { param([string]$Component) Set-State -Key "installed_$Component" -Value "true" }

# Returns $true if the given component was installed by this toolkit.
# Params: Component name
function Test-InstalledByUs {
    param([string]$Component)
    return (Get-State -Key "installed_$Component") -eq "true"
}