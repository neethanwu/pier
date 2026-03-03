# Pier

macOS menu bar app that keeps track of every dev server running on your machine.

Pier quietly watches for listening TCP ports, resolves them to project names and git branches, and shows everything in a single popover. No setup, no config — just the ports you care about.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138)
![License: MIT](https://img.shields.io/badge/License-MIT-blue)

<!-- ![Pier screenshot](assets/screenshot.png) -->

## Features

- **Auto-detection** — scans for dev servers (node, next, vite, rails, python, go, etc.)
- **Port-first layout** — developers think in ports, so that's the primary column
- **Git branch** — shows the current branch for each project
- **Kill & Open** — stop a server or open it in your browser on hover
- **Breathing status dot** — alive indicator for each running server
- **Keyboard shortcuts** — `⌘R` refresh, `⌘Q` quit, `⌘W` close popover
- **Light & dark mode** — follows system appearance

## Install

Download the latest `.dmg` from [Releases](https://github.com/neethanwu/pier/releases), open it, and drag **Pier.app** to Applications.

> Pier runs as a menu bar app — look for the circle icon in your menu bar after launching.

## Build from Source

Requires **Xcode 16+** and **macOS 14+**.

```bash
git clone https://github.com/neethan/pier.git
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

Pier uses `lsof` to detect listening TCP ports, then resolves each to a process → working directory → project name → git branch. It polls every 5 seconds and uses no background daemons or privileged helpers.

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

Inspired by [Porter](https://x.com/nicklawrenn/status/1893316289581646158) by [@eduardwieandt](https://x.com/eduardwieandt).

## License

[MIT](LICENSE)
