# Installation & Package Manifests

Package manifests and installation bundles for bootstrapping developer tools and applications on macOS.

## Overview

This directory contains Homebrew bundle manifests defining all CLI tools, development runtimes, GUI applications,
fonts, and Visual Studio Code extensions needed for a complete developer environment.

## Files

- **`Brewfile`**: Primary Homebrew bundle containing:
  - **Taps**: Third-party tap repositories (e.g. Databricks, FluxCD, Manaflow AI).
  - **Shell Tools & Utilities**: Modern CLI tools (`bat`, `delta`, `diffnav`, `dust`, `fd`, `jq`, `lsd`,
    `ripgrep`, `starship`, `tailspin`, `zellij`, `zoxide`).
  - **AI & Optimization**: Local AI coding assistants and proxies (`codeburn`, `rtk`).
  - **Languages & Frameworks**: Runtime managers and build tools (`mise`, `pnpm`, `uv`, `ruff`, `xcodegen`).
  - **Containers & Cloud**: Container runtimes and Kubernetes tools (`podman`, `podman-compose`, `kubectl`,
    `kubectx`, `helm`, `flux`, `gh`).
  - **GUI Applications (Casks)**: Developer applications (`ghostty`, `cmux`, `visual-studio-code`, `hammerspoon`,
    `bruno`, `obsidian`, `1password@7`).
  - **Nerd Fonts**: Patched fonts for terminal glyphs (`font-meslo-lg-nerd-font`, `font-fira-code-nerd-font`).
  - **Mac App Store**: Mac App Store packages managed via `mas`.
  - **VS Code Extensions**: Curated Visual Studio Code extensions.
- **`ProfessionalBrewfile`** *(optional, uncommitted)*: Supplementary Homebrew bundle for work-specific or proprietary tools.

## Installation Procedure

### Automated Installation

Executed automatically during machine bootstrap via:

```bash
./bootstrap.sh
```

### Manual Installation

To install or synchronize packages directly using Homebrew Bundle:

```bash
brew bundle --file=install/Brewfile
```
