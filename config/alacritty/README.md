# Alacritty Configuration

[Alacritty](https://alacritty.org/) is a fast, cross-platform, GPU-accelerated terminal emulator.

## Overview

This directory provides the default terminal configuration for Alacritty, customized for font rendering,
window padding, and shell integration.

## Configuration Details

- **File**: `alacritty.toml`
- **Font**: MesloLGS Nerd Font Mono, size 17.
- **Window**: Full decorations with padding (`x = 10`, `y = 30`).
- **Shell**: Configured to launch Nushell (`/opt/homebrew/bin/nu`).

## Symlink Location

Linked by `bootstrap.sh`:

- `config/alacritty` &rarr; `~/.config/alacritty`
