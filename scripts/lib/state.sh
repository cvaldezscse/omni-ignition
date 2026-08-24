#!/usr/bin/env zsh
# state.sh - Persistent state tracking for omni-ignition.
#
# Records what THIS toolkit installed/changed (as opposed to what already
# existed on the machine), as flat key=value pairs in
# ~/.omni-ignition/state.env. This is what makes --uninstall safe: it only
# reverses what we added, never things that were already there.
#
# Every module must `source scripts/lib/state.sh` and call state_init once.

STATE_ROOT="${STATE_ROOT:-$HOME/.omni-ignition}"
STATE_FILE="${STATE_ROOT}/state.env"

# Ensures the state file exists. Safe to call multiple times.
state_init() {
  mkdir -p "${STATE_ROOT}"
  [[ -f "${STATE_FILE}" ]] || : > "${STATE_FILE}"
}

# Reads a value by key. Prints nothing if the key isn't set.
# Args: $1 key
state_get() {
  local key="$1"
  grep -m1 "^${key}=" "${STATE_FILE}" 2>/dev/null | cut -d= -f2-
}

# Sets/overwrites a key, replacing any prior value.
# Args: $1 key, $2 value
state_set() {
  local key="$1" value="$2"
  local tmp="${STATE_FILE}.tmp"
  grep -v "^${key}=" "${STATE_FILE}" 2>/dev/null > "${tmp}" || true
  echo "${key}=${value}" >> "${tmp}"
  mv "${tmp}" "${STATE_FILE}"
}

# Sets a key ONLY if it doesn't already exist. Used to capture a value's
# true "before" baseline exactly once (e.g. the original Execution Policy) —
# re-running the bootstrap must never overwrite that original snapshot.
# Args: $1 key, $2 value
state_set_if_absent() {
  local key="$1" value="$2"
  [[ -z "$(state_get "${key}")" ]] && state_set "${key}" "${value}"
}

# Marks a component as installed BY THIS TOOLKIT (vs. pre-existing).
# Args: $1 component name (e.g. "homebrew")
state_mark_installed() { state_set "installed_$1" "true"; }

# Returns success (0) if the given component was installed by this toolkit.
# Args: $1 component name
state_was_installed_by_us() {
  [[ "$(state_get "installed_$1")" == "true" ]]
}