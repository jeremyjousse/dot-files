# Installation & Package Manifests

Package manifests and installation bundles for bootstrapping developer tools and applications on macOS.

## Overview

This directory contains Homebrew bundle manifests defining all CLI tools, development runtimes, GUI applications,
fonts, and Visual Studio Code extensions needed for a complete developer environment.

## Files

- **`Brewfile`**: Primary Homebrew bundle containing CLI tools and package managers:
  - **Taps**: Third-party tap repositories (e.g. Databricks, FluxCD).
  - **Shells & Prompts**: Shells, completions, prompts, and workspace managers (`carapace`, `starship`, `zellij`, `zoxide`).
  - **CLI Navigation & File Utilities**: Modern CLI tools (`bat`, `diffnav`, `dust`, `fd`, `git-delta`, `jq`, `lsd`,
    `ripgrep`, `tailspin`).
  - **Shell Editors**: Terminal text editors (`helix`).
  - **Dev Languages & Runtimes**: Runtime managers and build tools (`mise`, `pnpm`, `ruff`, `uv`, `xcodegen`).
  - **Containers & Orchestration**: Container runtimes and Kubernetes tools (`container`, `container-compose`, `flux`,
    `helm`, `kubectl`, `kubectx`, `podman`, `podman-compose`).
  - **AI & Agent Tools**: Local AI coding assistants and proxies (`codeburn`, `rtk`).
  - **Cloud & SaaS CLIs**: Cloud platform CLIs (`databricks`, `gh`).
  - **Code Quality & Linters**: Linters and formatters (`markdownlint-cli2`, `shellcheck`, `shfmt`).
  - **System, Security & Networking**: System tools and network utilities (`dockutil`, `gnupg`, `mas`, `wrk`).
  - **Libraries & Compilers**: Shared libraries and build tools (`ffmpeg`, `graphviz`, `pkg-config`).
- **`CaskBrewfile`**: GUI applications, tools, and fonts managed via Homebrew Cask:
  - **Browsers**: Developer and primary web browsers (`firefox@developer-edition`, `google-chrome`).
  - **Terminals**: Terminal emulators and multiplexers (`cmux`, `ghostty`).
  - **Development & IDEs**: IDEs and toolbox managers (`jetbrains-toolbox`, `visual-studio-code`).
  - **Developer Tools**: API clients, dev utilities, cloud tools, container GUIs (`bruno`, `devtoys`, `gcloud-cli`, `jdk-mission-control`, `podman-desktop`).
  - **Productivity & Notes**: Cloud storage and knowledge management (`google-drive`, `obsidian`).
  - **macOS Utilities & Automation**: Mac automation and shortcut managers (`hammerspoon`, `hyperkey`, `keyclu`).
  - **Security & Passwords**: Password managers (`1password@7`).
  - **Media**: Media players (`vlc`).
  - **Fonts**: Patched fonts for terminal glyphs (`font-fira-code-nerd-font`, `font-meslo-lg-nerd-font`).
- **`MasBrewfile`**: Mac App Store packages managed via `mas`.
- **`VscodeBrewfile`**: Curated Visual Studio Code extensions.
- **`ProfessionalBrewfile`** *(optional, uncommitted)*: Supplementary Homebrew bundle for work-specific or proprietary tools.

The CLI bundle includes **CodeBurn**, for tracking local AI token usage and costs, and **rtk**, a CLI proxy that
reduces LLM token consumption. CodeBurn is available through the `cb` shell alias (`cb status`, `cb overview`,
`cb models`); its OpenCode MCP server also exposes usage and savings tools when configured.

## Installation Procedure

### Automated Installation

Before bootstrapping, optionally configure `.env` with values such as `GIT_USER_NAME`, `GIT_USER_EMAIL`, and
`GIT_SIGNING_KEY`. Installation is executed automatically during machine bootstrap. By default, this installs CLI
tools and VS Code extensions:

```bash
./bootstrap.sh
```

To also install GUI applications and Mac App Store apps on a new machine, use:

```bash
./bootstrap.sh --with-gui
```

Routine Homebrew updates use `make update`, which upgrades formulae only and leaves Casks untouched. GUI bundles can
also be installed separately with `make brew-gui-packages`.

### Manual Installation

To install or synchronize packages directly using Homebrew Bundle:

```bash
brew bundle --file=install/Brewfile
brew bundle --file=install/VscodeBrewfile
```

For GUI applications and Mac App Store apps, run these separately:

```bash
brew bundle --file=install/CaskBrewfile
brew bundle --file=install/MasBrewfile
```
