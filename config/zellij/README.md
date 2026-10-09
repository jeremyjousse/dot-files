# Zellij Configuration

[Zellij](https://zellij.dev/) is a terminal workspace and multiplexer with batteries included, written in Rust.

## Overview

This directory provides a customized Zellij configuration with modal keybindings (pane, tab, resize,
scroll, search, session, tmux modes) and plugin settings.

## Configuration Details

- **File**: `config.kdl`
- **Keybindings**: Customized modal keybindings with dedicated modes (`Ctrl p` for pane, `Ctrl t` for tab,
  `Ctrl n` for resize, `Ctrl s` for scroll, `Ctrl o` for session, `Ctrl b` for tmux-compatible shortcuts).
- **Plugins**: Pre-configured plugin aliases including `tab-bar`, `status-bar`, `strider`, `compact-bar`,
  `session-manager`, and `plugin-manager`.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/zellij` &rarr; `~/.config/zellij`
