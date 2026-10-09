# Bootstrap & Helper Scripts

Shell automation libraries and helper scripts supporting repository bootstrapping, symlink management, and package installation.

## Overview

This directory provides modular shell functions and procedures called by the root `bootstrap.sh` script
to configure and provision a macOS workstation idempotently.

## Script Overview

- **`lib.sh`**: Core utility library providing:
  - `create_folder`: Safe folder creation (`mkdir -p`).
  - `link_config_files`: Idempotent symbolic link management with automated backup (`.back`) of existing
    non-symlink files/directories and override support for `-professional` file variants.
  - `unlink_config_files`: Safe symlink removal.
  - `copy_config_files`: Directory copying with existing symlink cleanup.
  - `generate_local_gitconfig`: Generates Git user identity (`user.name`, `user.email`, `user.signingkey`)
    dynamically from a local `.env` file.
  - `check_install_vscode_extensions`: Batch verification and installation of Visual Studio Code extensions.
  - `clone_github_repo`: Clones target GitHub repositories via GitHub CLI (`gh`).
  - Terminal formatting helpers (`info`, `warning`, `error`).
- **`install.sh`**: Installs base tool dependencies:
  - Homebrew package manager (if absent).
  - Oh My Zsh and community plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-defer`).
  - Packages defined in `install/Brewfile`.
  - Python tools managed via `uv tool` (e.g. `pynglish`).
  - OpenCode agent plugins via `rtk init`.
- **`prepare.sh`**: Initial macOS preparation tasks (e.g. accepting Xcode license agreement).
- **`git_repositories.sh`**: Clones personal development repositories into `$DEVELOPMENT_ROOT_FOLDER/Personal/`.
- **`update.sh`**: Updates installed language runtimes via `mise upgrade`.

## Usage & Execution Order

All scripts are orchestrated sequentially by `bootstrap.sh`. Individual scripts can also be sourced in interactive
Bash/Zsh sessions when troubleshooting.
