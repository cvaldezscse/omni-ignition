<#
.SYNOPSIS
    Centralized logging library for omni-ignition (Windows).
.DESCRIPTION
    Mirrors scripts/lib/logger.sh: colored console output plus two
    persistent log files per run under %USERPROFILE%\.omni-ignition\logs\.
      human_readable.log -> plain, timestamped (for humans)
      technical.log        -> same events + calling function (for debugging)
    Dot-source this file and call Initialize-Log once before any other
    Write-Log* call.
#>

$script:LogRoot = if ($env:OMNI_LOG_ROOT) { $env:OMNI_LOG_ROOT } else { Join-Path $env:USERPROFILE ".omni-ignition\logs" }
$script:LogDir = $null
$script:HumanLog = $null
$script:TechLog = $null

# Creates a fresh, timestamped log directory for this run and points a
# "latest" junction at it (junctions, unlike symlinks, need no admin rights).
function Initialize-Log {
    $runTs = Get-Date -Format "yyyyMMdd-HHmmss"
    $script:LogDir = Join-Path $script:LogRoot $runTs
    New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
    $script:HumanLog = Join-Path $script:LogDir "human_readable.log"
    $script:TechLog  = Join-Path $script:LogDir "technical.log"
    New-Item -ItemType File -Path $script:HumanLog -Force | Out-Null
    New-Item -ItemType File -Path $script:TechLog -Force | Out-Null

    $latest = Join-Path $script:LogRoot "latest"
    if (Test-Path $latest) { Remove-Item $latest -Force -Recurse -ErrorAction SilentlyContinue }
    New-Item -ItemType Junction -Path $latest -Target $script:LogDir | Out-Null
}

# Internal: appends one plain-text line to a log file.
# Params: Path (target file), Level, Message, Caller (function name)
function Write-LogFile {
    param([string]$Path, [string]$Level, [string]$Message, [string]$Caller)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($Path -eq $script:TechLog) {
        Add-Content -Path $Path -Value "[$ts] [$Level] [$Caller] $Message"
    } else {
        Add-Content -Path $Path -Value "[$ts] [$Level] $Message"
    }
}

# Internal: prints a colored console line and mirrors it to both log files.
# Params: Color (console color), Level, Message
function Write-LogEmit {
    param([string]$Color, [string]$Level, [string]$Message)
    $caller = (Get-PSCallStack)[2].FunctionName
    Write-Host "[$Level] " -ForegroundColor $Color -NoNewline
    Write-Host $Message
    if ($script:HumanLog) { Write-LogFile -Path $script:HumanLog -Level $Level -Message $Message -Caller $caller }
    if ($script:TechLog)  { Write-LogFile -Path $script:TechLog  -Level $Level -Message $Message -Caller $caller }
}

# Public logging levels. Each mirrors console + human_readable.log + technical.log.
function Write-LogInfo    { param([string]$Message) Write-LogEmit -Color Cyan   -Level "INFO" -Message $Message }
function Write-LogWarn    { param([string]$Message) Write-LogEmit -Color Yellow -Level "WARN" -Message $Message }
function Write-LogSuccess { param([string]$Message) Write-LogEmit -Color Green  -Level "OK"   -Message $Message }

# Prints a visually distinct section header (used to mark each install step).
# Params: Message (step description)
function Write-LogStep {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Magenta
    $caller = (Get-PSCallStack)[1].FunctionName
    Write-LogFile -Path $script:HumanLog -Level "STEP" -Message $Message -Caller $caller
    Write-LogFile -Path $script:TechLog  -Level "STEP" -Message $Message -Caller $caller
}

# Logs an error. Optionally records the failed command/exit code in
# technical.log only, keeping human_readable.log approachable.
# Params: Message, Command (optional), ExitCode (optional)
function Write-LogError {
    param([string]$Message, [string]$Command = "", [int]$ExitCode = 1)
    Write-LogEmit -Color Red -Level "ERROR" -Message $Message
    if ($Command) {
        $caller = (Get-PSCallStack)[1].FunctionName
        Write-LogFile -Path $script:TechLog -Level "ERROR" -Message "command='$Command' exit_code=$ExitCode" -Caller $caller
    }
}

# Thin wrapper around the native Write-Progress cmdlet, kept API-consistent
# with logger.sh's progress_bar for large downloads/installs (Android SDK,
# Xcode-equivalent Windows downloads, etc).
# Params: Current, Total, Label
function Show-ProgressBar {
    param([int]$Current, [int]$Total, [string]$Label)
    $pct = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Label -Status "$pct% complete" -PercentComplete $pct
    if ($Current -ge $Total) { Write-Progress -Activity $Label -Completed }
}

# --- Run summary (end-of-execution checklist) -------------------------------
# Populated via Add-SummaryOk/Add-SummaryFail as each step runs, printed once
# via Show-Summary. Kept separate from State.ps1: State.ps1 persists across
# runs (for -Uninstall), this is just for the current run's report.
$script:SummaryOk = @()
$script:SummaryFail = @()

# Records a component as successfully installed/verified.
# Params: Item label
function Add-SummaryOk { param([string]$Item) $script:SummaryOk += $Item }

# Records a component that failed to install/verify.
# Params: Item label, Reason (optional short reason)
function Add-SummaryFail {
    param([string]$Item, [string]$Reason = "")
    $script:SummaryFail += if ($Reason) { "$Item ($Reason)" } else { $Item }
}

# Prints a compact checklist of everything installed/verified vs failed.
function Show-Summary {
    Write-Host ""
    Write-Host "==> Summary" -ForegroundColor Magenta
    foreach ($item in $script:SummaryOk)   { Write-Host "  [OK] $item" -ForegroundColor Green }
    foreach ($item in $script:SummaryFail) { Write-Host "  [x]  $item" -ForegroundColor Red }
    Write-LogFile -Path $script:HumanLog -Level "SUMMARY" `
        -Message "OK: $($script:SummaryOk.Count) item(s), FAILED: $($script:SummaryFail.Count) item(s)" `
        -Caller "Show-Summary"
}