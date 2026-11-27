# Zsh Configuration

[Zsh](https://www.zsh.org/) is an interactive shell, combined here with [Oh My Zsh](https://ohmyz.sh/),
[Starship](https://starship.rs/), and deferred plugin execution via [zsh-defer](https://github.com/romkatv/zsh-defer).

## Overview

This directory provides the complete Zsh user environment, including shell startup initialization,
Oh My Zsh plugins, and modular custom configurations.

## Directory Structure

- **`.zshrc`**: Main Zsh entry point. Configures Homebrew environment, `mise` activation, Oh My Zsh base settings,
  deferred loading via `zsh-defer`, and personal configuration hooks.
- **`plugins.zsh`**: Active Oh My Zsh plugins (`gh`, `git-auto-fetch`, `git`, `gitignore`, `kubectl`, `kubectx`,
  `macos`, `man`, `podman`, `zsh-autosuggestions`, `zsh-syntax-highlighting`).
- **`custom/`**: Modular shell scripts loaded via `index.zsh`:
  - `aliases.zsh`: Personal command aliases (e.g. `cb` for CodeBurn, `k` for kubectl, `ll`/`la`).
  - `modules.zsh`: Tool initialization modules.
  - `utils.zsh`: Helper shell utility functions.
  - `fnox.zsh`: Custom shell integrations.
  - `professional.zsh` (optional): Machine- or work-specific environment overrides.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/zsh/.zshrc` &rarr; `~/.zshrc`
- `config/zsh` &rarr; `~/.config/zsh`
