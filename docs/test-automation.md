# Test Automation Stack

This document covers per-domain QA tooling setup. This revision focuses on
the **Mobile Automation (Java + Appium)** stack; Web, API, Desktop, and
Performance sections can be added the same way as this project grows.

## Mobile Automation (Java + Appium)

Stack: Java, Appium, TestNG, Maven, Freemarker (custom HTML reports),
Android SDK, Xcode/iOS toolchain. Supports both local execution and
AWS Device Farm.

### Prerequisites installed by Layer 0 + Brewfile/packages.json

- Xcode Command Line Tools (macOS) — provides git, clang
- Homebrew (macOS) / winget or Chocolatey (Windows)
- Maven, CocoaPods, libimobiledevice, ios-deploy, Android platform-tools
- AWS CLI (Device Farm uploads and job orchestration)

### Java (JDK)

JDK is **not** installed via Brewfile/packages.json. It's resolved by a
dedicated version resolver script that:

- Prefers **Oracle JDK** over OpenJDK builds, per team convention.
- Accepts a semantic target (e.g. `--java=17`) and resolves the latest
  available patch release for that major version.
- Flags the Oracle license terms: JDK 17+ uses the No-Fee Terms and
  Conditions (free for production use); earlier majors require a
  commercial license for production use — verify before pinning an
  older version in `versions.conf`.

Pinned version lives in `versions.conf` at the repo root.

### Android SDK

1. Install `cmdline-tools` (via the resolver module, not Android Studio,
   unless the optional `android-studio` cask/package is enabled).
2. Accept SDK licenses: `sdkmanager --licenses`.
3. Install `platform-tools`, `platforms;android-<API>`, `emulator`.
4. Set `ANDROID_HOME` / `ANDROID_SDK_ROOT` in the shell profile
   (`.zshrc` on macOS, PowerShell profile on Windows).

### iOS toolchain (macOS only)

1. Full Xcode (not just CLT) must be installed from the App Store —
   this step cannot be fully silent without Apple ID sign-in, so the
   bootstrap only **verifies** it's present and prompts if missing.
2. Accept the Xcode license: `sudo xcodebuild -license accept`.
3. Install/select at least one iOS Simulator runtime via Xcode's
   Platforms settings or `xcodebuild -downloadPlatform iOS`.
4. `pod install` inside Appium's WebDriverAgent when running the
   XCUITest driver for the first time (CocoaPods, already in Brewfile).

### Appium

Installed via npm (not Homebrew/winget), pinned in `versions.conf`:

```
npm install -g appium@<pinned-version>
appium driver install uiautomator2
appium driver install xcuitest
```

**Design target for the future Appium module:** after installing the
drivers, run `appium driver doctor uiautomator2` / `xcuitest` and install
every dependency it reports — both **required** and **optional** — not
just the required ones. The goal is a machine that's ready for real work
out of the box, not just the bare minimum to pass `appium doctor`.

### Local vs. AWS Device Farm execution

Both modes use the same Appium-based framework; the execution target is
selected through `Configuration.java` / the environment-specific YAML
(`configuration.yaml`), and Device Farm runs go through the existing
device-farm interaction library plus the `testSpecs/*.yml` specs already
in this repo's mobile framework.

### Verification

Run `doctor.sh` (macOS) or the Windows equivalent after setup to confirm
detected versions for Java, Maven, Node, Appium, Android SDK, and Xcode.
