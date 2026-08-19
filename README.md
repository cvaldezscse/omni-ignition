# omni-ignition 🚀

Cross-platform bootstrapping, package manifests, dotfiles, and setup guides for **macOS** and **Windows**. Designed for multi-disciplinary workflows covering **Software Development**, **Full-Spectrum Test Automation (SDET)**, and **DevOps / Infrastructure**.

---

## 📋 Quick Onboarding Checklist

When setting up a brand-new or freshly formatted machine, open a clean terminal shell and follow these steps:

### 1. Clone the Repository

```
git clone https://github.com/your-username/omni-ignition.git ~/.omni-ignition
cd ~/.omni-ignition
```

---

## 🍏 macOS Bootstrapping

1. **Run the Automated Setup Script:**

```
   chmod +x scripts/setup-mac.sh
   ./scripts/setup-mac.sh
```

_This script installs Homebrew, applies os/macos/Brewfile, links dotfiles, and configures macOS defaults._

2. **Manual & Domain-Specific Setup:**
   - Refer to docs/macos-setup.md for system settings and Xcode Command Line Tools.
   - Refer to docs/test-automation.md for Java, Android SDK, ADB, and iOS testing tools setup.

---

## 🪟 Windows Bootstrapping

1. **Open PowerShell as Administrator and Run:**
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\scripts\setup-win.ps1
   _This script imports packages via Winget (os/windows/packages.json), links dotfiles, and sets up your PowerShell profile._

2. **Manual & Domain-Specific Setup:**
   - Refer to docs/windows-setup.md for WSL2, Developer Mode, and environment variables.
   - Refer to docs/devops-cloud.md for Docker Desktop / Podman and Cloud CLI configurations.

---

## 📁 Repository Structure

Below is the complete blueprint of omni-ignition:

<details open>
<summary><b>🔍 Click to view full directory tree</b></summary>

```text
omni-ignition/
├── README.md                    <-- Main orchestration & quick-start guide
├── docs/                        <-- Deep-dive setup guides per domain
│   ├── dev-env.md               <-- Multi-stack runtimes (Node, Python, Java, Go, .NET, PHP)
│   ├── test-automation.md       <-- Multi-platform QA stack (Web, Mobile, API, Desktop, Performance)
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
│   │   ├── settings.json        <-- Editor UI, formatting, and linter settings
│   │   ├── keybindings.json     <-- Custom keyboard shortcuts
│   │   └── extensions.txt       <-- Essential extensions for Dev, Test Automation & DevOps
│   ├── git/
│   │   ├── .gitconfig           <-- Global Git settings, aliases, and diff tools
│   │   └── .gitignore_global    <-- System-wide ignored files (.DS_Store, Thumbs.db, etc.)
│   ├── terminal/
│   │   └── starship.toml        <-- Cross-shell prompt theme & status indicators
│   └── containers/
│       └── daemon.json          <-- Shared Docker Engine / Podman configurations
│
└── scripts/                     <-- One-click automated provisioning scripts
    ├── setup-mac.sh             <-- Installs Homebrew, applies Brewfile & links dotfiles
    └── setup-win.ps1            <-- Runs Winget import, links configs & sets PowerShell env
```

</details>

---

### 🧱 Core Components Breakdown

- **docs/**: Step-by-step guides categorized by discipline (**Software Dev**, **Full-Spectrum Test Automation**, **DevOps/Cloud**). Ideal for manual setup steps, environment variables, secret managers, and framework runtimes.
- **os/**: Native OS package manifests (Brewfile for macOS via Homebrew, packages.json for Windows via Winget) to provision all CLI tools, browsers, IDEs, and utilities in bulk.
- **apps/**: Portable dotfiles and app settings shared seamlessly across operating systems (VS Code/VSCodium, Git global rules, terminal prompts).
- **scripts/**: One-command automated bootstrap scripts to provision a freshly formatted or brand-new machine in minutes.

---

## 🛠️ App Configurations & Symlink Mappings

| Application / Config   | Location in Repo            | macOS Target                             | Windows Target                       |
| :--------------------- | :-------------------------- | :--------------------------------------- | :----------------------------------- |
| **VS Code / VSCodium** | apps/vscode/                | ~/Library/Application Support/Code/User/ | %APPDATA%\Code\User\                 |
| **Git Global Config**  | apps/git/.gitconfig         | ~/.gitconfig                             | %USERPROFILE%\.gitconfig             |
| **Global Gitignore**   | apps/git/.gitignore_global  | ~/.gitignore_global                      | %USERPROFILE%\.gitignore_global      |
| **Starship Prompt**    | apps/terminal/starship.toml | ~/.config/starship.toml                  | %USERPROFILE%\.config\starship.toml  |
| **PowerShell Profile** | os/windows/profile.ps1      | N/A                                      | %USERPROFILE%\Documents\PowerShell\  |

---

## 📖 Domain Documentation Index

- 🟢 [Development Runtimes & SDKs Setup](docs/dev-env.md)
- 🧪 [Full-Spectrum Test Automation Stack](docs/test-automation.md)
- ☁️ [DevOps, Containers & Cloud Infrastructure](docs/devops-cloud.md)
- 🍏 [macOS Post-Install Tweaks](docs/macos-setup.md)
- 🪟 [Windows / WSL Post-Install Tweaks](docs/windows-setup.md)
