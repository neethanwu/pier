<p align="center">
  <img src="assets/icon.png" width="80" alt="Pier icon">
</p>

<h1 align="center">Pier</h1>

<p align="center">
  macOS menu bar app that keeps track of every dev server running on your machine.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14%2B-black" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6-F05138" alt="Swift 6">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License: MIT">
</p>

<p align="center">
  <video src="https://github.com/neethanwu/pier/raw/main/assets/pier.mp4" width="600" autoplay loop muted playsinline></video>
</p>

## Features

- **Auto-detection** — scans for dev servers (node, next, vite, rails, python, go, etc.)
- **Port-first layout** — developers think in ports, so that's the primary column
- **Git branch** — shows the current branch for each project
- **Kill & Open** — stop a server or open it in your browser on hover
- **Breathing status dot** — alive indicator for each running server
- **Launch at Login** — toggle in footer with hover-reveal label
- **Keyboard shortcuts** — `⌘R` refresh, `⌘Q` quit
- **Light & dark mode** — follows system appearance

## Install

Download the latest `.dmg` from [Releases](https://github.com/neethanwu/pier/releases), open it, and drag **Pier.app** to Applications.

> Pier runs as a menu bar app — look for the circle icon in your menu bar after launching.

## Build from Source

Requires **Xcode 16+** and **macOS 14+**.

```bash
git clone https://github.com/neethanwu/pier.git
cd pier

# Run locally (ad-hoc signed)
make run

# Or build a release bundle
make build
make bundle
```

### Signed Release Build

If you have a Developer ID certificate:

```bash
# Set your signing identity
export SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"

# Build, sign, and create DMG
make release
```

## How It Works

Pier uses `lsof` to detect listening TCP ports, then resolves each to a process → working directory → project name → git branch. It polls every 2 seconds and uses no background daemons or privileged helpers.

**Detected servers:** node, next, vite, nuxt, ruby, rails, puma, python, uvicorn, flask, django, go, cargo, deno, bun, php, java, and more.

## Project Structure

```
Sources/Pier/
├── PierApp.swift              # App entry, menu bar setup
├── Models/DevServer.swift     # Server data model
├── Services/
│   ├── ServerMonitor.swift    # Observable view model, polling
│   ├── PortScanner.swift      # lsof-based port detection
│   ├── ProcessResolver.swift  # PID → working directory
│   ├── GitBranchReader.swift  # .git/HEAD parsing
│   └── ShellExecutor.swift    # Async shell execution
├── Views/
│   ├── ServerListView.swift   # Main popover layout
│   ├── ServerRowView.swift    # Individual server row
│   └── EmptyStateView.swift   # No servers state
└── Utilities/
    └── TimeFormatter.swift    # Uptime formatting
```

## Credits

Inspired by [Porter](https://x.com/eduardwieandt/status/2027495344766947415) by [@eduardwieandt](https://x.com/eduardwieandt).

## License

[MIT](LICENSE)
