# Testing omni-ignition (local only)

This toolkit changes real system state — installs packages, elevates
permissions, edits settings. Testing it in a shared CI pipeline isn't
worth it here: install steps like Xcode Command Line Tools have
unpredictable runtimes, and the added pipeline maintenance isn't
justified for a toolkit run occasionally on a handful of machines.
Everything below runs locally instead.

## 1. Static checks (seconds, no installs happen)

Run before trusting any change:

```zsh
shellcheck -s bash scripts/**/*.sh
```

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser
Invoke-ScriptAnalyzer -Path scripts -Recurse
```

## 2. Disposable VM (the real "brand-new machine" test)

- **macOS** (needs an Apple Silicon host): [UTM](https://mac.getutm.app/) or
  [Tart](https://tart.run/) run a macOS guest via Apple's Virtualization
  framework. Snapshot right after a clean OS install, run the script,
  evaluate, revert to the snapshot, repeat.
- **Windows**: Hyper-V, VirtualBox, or Parallels with a Windows 10/11
  evaluation ISO and a snapshot taken right after install. Windows Sandbox
  works for a quick first-run check but resets on every launch, so it
  can't validate idempotency across a second run.

## 3. Manual checklist before merging a change to a `setup-*` script

1. Run it — confirm it installs what's expected, and check the end-of-run
   summary checklist matches reality.
2. Run it again — confirm every check reports "already installed"; nothing
   re-downloads, and the summary shows everything OK with no new work.
3. Run `--uninstall` / `-Uninstall` — confirm only toolkit-installed
   components are removed. Inspect `~/.omni-ignition/state.env` (or
   `%USERPROFILE%\.omni-ignition\state.env`) before and after to verify
   nothing pre-existing got touched.
