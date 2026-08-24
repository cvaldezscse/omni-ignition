# omni-ignition 🚀

Cross-platform bootstrapping, package manifests, dotfiles, and setup guides
for **macOS** and **Windows**. Designed for multi-disciplinary workflows
covering **Software Development**, **Full-Spectrum Test Automation (SDET)**,
and **DevOps / Infrastructure**.

---

## 📋 Quick Onboarding Checklist

When setting up a brand-new or freshly formatted machine, open a clean
terminal shell and follow these steps:

### 1. Clone the Repository

```
git clone https://github.com/cvaldezscse/omni-ignition.git ~/.omni-ignition
cd ~/.omni-ignition
```

---

## 🍏 macOS Bootstrapping

1. **Run the Automated Setup Script:**

```
chmod +x scripts/setup-mac.sh
./scripts/setup-mac.sh
```

_This script installs Homebrew, applies os/macos/Brewfile, links dotfiles,
and configures macOS defaults._

2. **Manual & Domain-Specific Setup:**
   - Refer to `docs/macos-setup.md` for system settings and Xcode Command
     Line Tools.
   - Refer to `docs/test-automation.md` for Java, Android SDK, ADB, and iOS
     testing tools setup.

---

## 🪟 Windows Bootstrapping

1. **Open PowerShell and Run:**

```
.\scripts\setup-win.ps1
```

_The script self-elevates if needed, imports packages via Winget
(`os/windows/packages.json`, falling back to Chocolatey), links dotfiles,
and sets up your PowerShell profile._

2. **Manual & Domain-Specific Setup:**
   - Refer to `docs/windows-setup.md` for WSL2, Developer Mode, and
     environment variables.
   - Refer to `docs/devops-cloud.md` for Docker Desktop / Podman and Cloud
     CLI configurations.

---

## 🧪 Testing this toolkit

Testing is intentionally local-only (no CI pipeline) — see `docs/testing.md`
for the full strategy: static lint checks, a disposable VM for the real
"brand-new machine" path, and a manual idempotency/uninstall checklist.

## ♻️ Restoring / Uninstalling

Both entry points track what **they themselves** installed in
`state.env` (never touching anything that pre-existed on the machine), so
restoring is safe and precise:

```
./scripts/setup-mac.sh --uninstall
```

```
.\scripts\setup-win.ps1 -Uninstall
```

If Homebrew (or Chocolatey, on Windows) was already on the machine before
you ran the bootstrap, it's left installed. Only what this toolkit added
gets removed.

---

## 📁 Repository Structure

Below is the complete blueprint of omni-ignition:

```
omni-ignition/
├── README.md                    <-- Main orchestration & quick-start guide
├── docs/                        <-- Deep-dive setup guides per domain
│   ├── dev-env.md               <-- Multi-stack runtimes (Node, Python, Java, Go, .NET, PHP)
│   ├── test-automation.md       <-- Multi-platform QA stack (Web, Mobile, API, Desktop, Performance)
│   ├── testing.md               <-- How to test THIS toolkit itself (lint, VM strategy) — local only
│   ├── devops-cloud.md          <-- Cloud & Infra (AWS CLI, Docker/Podman, Terraform, K8s, CI/CD)
│   ├── macos-setup.md           <-- OS-specific tweaks & manual steps for macOS
│   └── windows-setup.md         <-- OS-specific tweaks, WSL & PowerShell setup for Windows
│
├── os/                          <-- OS Package Manifests & System Defaults
│   ├── macos/
│   │   ├── Brewfile             <-- Homebrew formulae, casks, & Mac App Store apps
│   │   └── macos-defaults.sh    <-- Terminal script for macOS system preferences
│   └── windows/
│       ├── packages.json        <-- Winget bundle for bulk app installation
│       └── profile.ps1          <-- Custom PowerShell profile with dev, QA & DevOps aliases
│
├── apps/                        <-- Cross-platform application configs & dotfiles
│   ├── vscode/                  <-- VS Code / VSCodium preferences
│   ├── git/                     <-- Global Git settings & ignore rules
│   ├── terminal/                <-- Cross-shell prompt theme
│   └── containers/               <-- Shared Docker Engine / Podman configuration
│
├── scripts/                     <-- One-click automated provisioning scripts
│   ├── setup-mac.sh             <-- Layer 0: Xcode CLT + Homebrew, idempotent, --uninstall
│   ├── setup-win.ps1            <-- Layer 0: elevation + winget/Chocolatey, idempotent, -Uninstall
│   └── lib/                     <-- Shared libraries, reused by every module
│       ├── logger.sh            <-- Colored console output, dual log files, end-of-run summary (macOS/Linux)
│       ├── Logger.ps1           <-- Same, for Windows
│       ├── state.sh             <-- Tracks what THIS toolkit installed (macOS/Linux)
│       └── State.ps1            <-- Same, for Windows
```

---

### 🧱 Core Components Breakdown

- **docs/**: Step-by-step guides categorized by discipline (**Software
  Dev**, **Full-Spectrum Test Automation**, **DevOps/Cloud**), plus
  `testing.md` covering the toolkit's own test strategy.
- **os/**: Native OS package manifests (Brewfile for macOS via Homebrew,
  packages.json for Windows via Winget) to provision CLI tools, browsers,
  IDEs, and utilities in bulk.
- **apps/**: Portable dotfiles and app settings shared across operating
  systems.
- **scripts/**: One-command bootstrap entry points, plus `lib/` — shared
  logging and state-tracking used by every current and future module.

---

## 🛠️ App Configurations & Symlink Mappings

| Application / Config   | Location in Repo            | macOS Target                             | Windows Target                       |
| ---------------------- | --------------------------- | ---------------------------------------- | ------------------------------------ |
| **VS Code / VSCodium** | apps/vscode/                | ~/Library/Application Support/Code/User/ | %APPDATA%\Code\User\                 |
| **Git Global Config**  | apps/git/.gitconfig         | ~/.gitconfig                             | %USERPROFILE%.gitconfig              |
| **Global Gitignore**   | apps/git/.gitignore_global  | ~/.gitignore_global                      | %USERPROFILE%.gitignore_global       |
| **Starship Prompt**    | apps/terminal/starship.toml | ~/.config/starship.toml                  | %USERPROFILE%.config\starship.toml   |
| **PowerShell Profile** | os/windows/profile.ps1      | N/A                                      | %USERPROFILE%\Documents\PowerShell\  |

---

## 📖 Domain Documentation Index

- 🟢 [Development Runtimes & SDKs Setup](docs/dev-env.md)
- 🧪 [Full-Spectrum Test Automation Stack](docs/test-automation.md)
- 🧰 [Testing omni-ignition itself](docs/testing.md)
- ☁️ [DevOps, Containers & Cloud Infrastructure](docs/devops-cloud.md)
- 🍏 [macOS Post-Install Tweaks](docs/macos-setup.md)
- 🪟 [Windows / WSL Post-Install Tweaks](docs/windows-setup.md)

---

## 🚧 Status

| Area                                                          | Status                     |
| ------------------------------------------------------------- | -------------------------- |
| Layer 0 (Xcode CLT / Homebrew, elevation / winget+Chocolatey) | ✅ Implemented, both OS    |
| Dual logging (console + human_readable.log + technical.log)   | ✅ Implemented, both OS    |
| State tracking + safe `--uninstall` / `-Uninstall`            | ✅ Implemented for Layer 0 |
| End-of-run summary checklist (installed / failed)             | ✅ Implemented for Layer 0 |
| Auto mode vs. interactive manual mode                         | ⏳ Planned (orchestrator)  |
| Semantic version resolver (`--java=17`, prefers Oracle JDK)   | ⏳ Planned                 |
| Android SDK / Appium / iOS toolchain modules                  | ⏳ Planned                 |
| `doctor.sh` verification report                               | ⏳ Planned                 |
| `versions.conf`, `os/windows/packages.json`                   | ⏳ Planned                 |
