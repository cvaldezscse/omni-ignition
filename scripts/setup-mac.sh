#!/usr/bin/env zsh
# setup-mac.sh - macOS bootstrap entry point for omni-ignition.
#
# Runs from inside an already-cloned copy of the repo (per README's
# clone-first flow). Handles "Layer 0": Xcode Command Line Tools + Homebrew,
# the two things every other step depends on. Idempotent — every check
# short-circuits if the prerequisite is already satisfied. Prints a compact
# checklist of what succeeded/failed at the end (see lib/logger.sh summary_*).
#
# Usage:
#   git clone https://github.com/cvaldezscse/omni-ignition.git ~/.omni-ignition
#   cd ~/.omni-ignition
#   chmod +x scripts/setup-mac.sh && ./scripts/setup-mac.sh
#   ./scripts/setup-mac.sh --uninstall   # reverses only what THIS toolkit installed

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/state.sh"

log_init
state_init

# --- Uninstall path ----------------------------------------------------------
# Only reverses components this toolkit itself installed (tracked in
# state.env). Anything that pre-existed on the machine is left untouched.
if [[ "${1:-}" == "--uninstall" ]]; then
  log_step "Restoring machine to its pre-bootstrap state"

  if state_was_installed_by_us "homebrew"; then
    log_warn "Removing Homebrew (this toolkit installed it)"
    if NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"; then
      state_set "installed_homebrew" "false"
      log_success "Homebrew removed"
      summary_ok "Homebrew removed"
    else
      log_error "Homebrew removal failed"
      summary_fail "Homebrew removal" "uninstall script failed"
    fi
  else
    log_info "Homebrew pre-existed before bootstrap — leaving it installed"
    summary_ok "Homebrew (left untouched, pre-existed)"
  fi

  log_info "Xcode Command Line Tools are never auto-removed (too many system"
  log_info "tools depend on them). To remove manually:"
  log_info "  sudo rm -rf /Library/Developer/CommandLineTools"

  summary_print
  log_success "Restore complete. Full log at ${LOG_DIR}"
  exit 0
fi

# --- Install path --------------------------------------------------------------
log_step "Layer 0: checking prerequisites"

# 1. Detect chip architecture (defines the Homebrew install prefix)
ARCH="$(uname -m)"
if [[ "${ARCH}" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi
log_info "Detected architecture: ${ARCH} (Homebrew prefix: ${BREW_PREFIX})"

# 2. Xcode Command Line Tools (provides git, clang, make)
if xcode-select -p >/dev/null 2>&1; then
  log_success "Xcode Command Line Tools already installed"
  summary_ok "Xcode Command Line Tools"
else
  log_warn "Xcode Command Line Tools not found — triggering install"
  xcode-select --install || true
  log_info "This opens a GUI installer. Press Enter here once it finishes..."
  read -r
  if xcode-select -p >/dev/null 2>&1; then
    log_success "Xcode Command Line Tools installed"
    summary_ok "Xcode Command Line Tools"
  else
    log_error "Xcode Command Line Tools still not detected after install attempt"
    summary_fail "Xcode Command Line Tools" "not detected after install"
  fi
fi

# 3. Homebrew — only mark it in state.env if WE install it, so --uninstall
#    never removes a Homebrew the user already had.
if command -v brew >/dev/null 2>&1; then
  log_success "Homebrew already installed ($(brew --version | head -n1))"
  summary_ok "Homebrew"
else
  log_warn "Homebrew not found — installing"
  if NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
    state_mark_installed "homebrew"
    log_success "Homebrew installed"
    summary_ok "Homebrew"
  else
    log_error "Homebrew installation failed"
    summary_fail "Homebrew" "install script failed"
  fi
fi

log_step "Layer 0 complete"
summary_print
# TODO: brew bundle --file="${REPO_ROOT}/os/macos/Brewfile"
# TODO: dispatch to scripts/modules/macos/*.sh (Java resolver, Android SDK, Appium, dotfiles)