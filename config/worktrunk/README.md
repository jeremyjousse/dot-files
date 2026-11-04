# Worktrunk Configuration

[Worktrunk](https://github.com/max-sixty/worktrunk) is a CLI for Git worktree management, designed for
parallel AI agent workflows and quick branch switching.

## Overview

This directory provides the global configuration for `worktrunk` (`wt`). It standardizes worktree
directory paths across repositories to match the dotfiles SDLC worktree isolation convention.

## Configuration Details

- **File**: `config.toml`
- **Worktree Path**: Sets `worktree-path = ".worktrees/{{ branch | sanitize }}"` so that new worktrees
  are created in `.worktrees/<branch>` relative to the repository root.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/worktrunk` &rarr; `~/.config/worktrunk`
