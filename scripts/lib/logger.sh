#!/usr/bin/env zsh
# logger.sh - Centralized logging library for omni-ignition.
#
# Provides colored console output plus two persistent log files per run:
#   human_readable.log  -> plain, timestamped, no color codes (for humans)
#   technical.log        -> same events + source function/context (for debugging)
#
# Every script/module must `source scripts/lib/logger.sh` and call log_init
# once, before any other log_* call. All functions are safe to call repeatedly.

# --- Color setup ---------------------------------------------------------
# Colors are disabled when NO_COLOR is set or stdout isn't a terminal,
# so piping output to a file or CI never produces raw escape codes.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  readonly C_RESET=$'\033[0m'
  readonly C_INFO=$'\033[36m'    # cyan
  readonly C_WARN=$'\033[33m'    # yellow
  readonly C_ERROR=$'\033[31m'   # red
  readonly C_SUCCESS=$'\033[32m' # green
  readonly C_STEP=$'\033[35m'    # magenta
else
  readonly C_RESET="" C_INFO="" C_WARN="" C_ERROR="" C_SUCCESS="" C_STEP=""
fi

# --- Log file state --------------------------------------------------------
LOG_ROOT="${LOG_ROOT:-$HOME/.omni-ignition/logs}"
LOG_DIR=""
HUMAN_LOG=""
TECH_LOG=""

# Initializes a fresh, timestamped log directory for the current run and
# points a "latest" symlink at it for quick access.
# Globals set: LOG_DIR, HUMAN_LOG, TECH_LOG
log_init() {
  local run_ts
  run_ts="$(date +%Y%m%d-%H%M%S)"
  LOG_DIR="${LOG_ROOT}/${run_ts}"
  mkdir -p "${LOG_DIR}"
  HUMAN_LOG="${LOG_DIR}/human_readable.log"
  TECH_LOG="${LOG_DIR}/technical.log"
  : > "${HUMAN_LOG}"
  : > "${TECH_LOG}"
  ln -sfn "${LOG_DIR}" "${LOG_ROOT}/latest"
}

# Internal: appends one plain-text line to a log file.
# Args: $1 target file, $2 level, $3 message, $4 caller function name
_log_write() {
  local file="$1" level="$2" msg="$3" caller="$4"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  if [[ "${file}" == "${TECH_LOG}" ]]; then
    echo "[${ts}] [${level}] [${caller}] ${msg}" >> "${file}"
  else
    echo "[${ts}] [${level}] ${msg}" >> "${file}"
  fi
}

# Internal: prints a colored console line and mirrors it to both log files.
# Args: $1 color, $2 level label, $3 message
_log_emit() {
  local color="$1" level="$2" msg="$3"
  local caller="${funcstack[3]:-main}"
  printf '%s[%s]%s %s\n' "${color}" "${level}" "${C_RESET}" "${msg}"
  [[ -n "${HUMAN_LOG}" ]] && _log_write "${HUMAN_LOG}" "${level}" "${msg}" "${caller}"
  [[ -n "${TECH_LOG}" ]]  && _log_write "${TECH_LOG}"  "${level}" "${msg}" "${caller}"
}

# Public logging levels. Each mirrors console + human_readable.log + technical.log.
log_info()    { _log_emit "${C_INFO}"    "INFO" "$1"; }
log_warn()    { _log_emit "${C_WARN}"    "WARN" "$1"; }
log_success() { _log_emit "${C_SUCCESS}" "OK"   "$1"; }

# Prints a visually distinct section header (used to mark each install step).
# Args: $1 step description
log_step() {
  printf '\n%s==> %s%s\n' "${C_STEP}" "$1" "${C_RESET}"
  _log_write "${HUMAN_LOG}" "STEP" "$1" "${funcstack[2]:-main}"
  _log_write "${TECH_LOG}"  "STEP" "$1" "${funcstack[2]:-main}"
}

# Logs an error. Optionally records the failed command and exit code in
# technical.log only, so human_readable.log stays readable for non-engineers.
# Args: $1 message, $2 optional failed command, $3 optional exit code
log_error() {
  local msg="$1" cmd="${2:-}" code="${3:-1}"
  _log_emit "${C_ERROR}" "ERROR" "${msg}"
  if [[ -n "${cmd}" ]]; then
    _log_write "${TECH_LOG}" "ERROR" "command='${cmd}' exit_code=${code}" "${funcstack[2]:-main}"
  fi
}

# Renders an in-place percentage progress bar (overwrites the line via \r).
# Intended for large downloads/installs (Xcode CLT, Android SDK, JDK, etc).
# Args: $1 current, $2 total, $3 label
progress_bar() {
  local current="$1" total="$2" label="$3"
  local width=30
  local pct=$(( current * 100 / total ))
  local filled=$(( width * current / total ))
  local bar
  bar="$(printf '%0.s#' $(seq 1 "${filled}" 2>/dev/null))$(printf '%0.s.' $(seq 1 $((width - filled)) 2>/dev/null))"
  printf '\r%s[%s] %3d%% %s%s' "${C_INFO}" "${bar}" "${pct}" "${label}" "${C_RESET}"
  [[ "${current}" -ge "${total}" ]] && echo
}

# --- Run summary (end-of-execution checklist) -----------------------------
# Populated via summary_ok/summary_fail as each step runs, printed once via
# summary_print. Kept separate from state.sh: state.sh persists across runs
# (for --uninstall), this is just for the current run's report.
SUMMARY_OK=()
SUMMARY_FAIL=()

# Records a component as successfully installed/verified.
# Args: $1 component label
summary_ok() { SUMMARY_OK+=("$1"); }

# Records a component that failed to install/verify.
# Args: $1 component label, $2 optional short reason
summary_fail() {
  local label="$1" reason="${2:-}"
  SUMMARY_FAIL+=("${label}${reason:+ (${reason})}")
}

# Prints a compact checklist of everything installed/verified vs failed.
summary_print() {
  echo ""
  printf '%s==> Summary%s\n' "${C_STEP}" "${C_RESET}"
  local item
  for item in "${SUMMARY_OK[@]}"; do
    printf '  %s[OK]%s %s\n' "${C_SUCCESS}" "${C_RESET}" "${item}"
  done
  for item in "${SUMMARY_FAIL[@]}"; do
    printf '  %s[x] %s %s\n' "${C_ERROR}" "${C_RESET}" "${item}"
  done
  _log_write "${HUMAN_LOG}" "SUMMARY" "OK: ${#SUMMARY_OK[@]} item(s), FAILED: ${#SUMMARY_FAIL[@]} item(s)" "summary_print"
}