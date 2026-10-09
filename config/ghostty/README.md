# Ghostty Configuration

[Ghostty](https://ghostty.org/) is a fast, feature-rich, and cross-platform terminal emulator that uses GPU acceleration.

## Overview

This directory provides the base configuration for Ghostty, tailored for macOS navigation and custom theme colors.

## Configuration Details

- **File**: `config`
- **Colors**: Dark theme with `#1A1A1A` background and `#ffffff` foreground.
- **Keybindings**: Binds the left Option key to act as `Alt` (`macos-option-as-alt = left`) for smooth
  command-line navigation and shell shortcuts.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/ghostty` &rarr; `~/.config/ghostty`
