# Git Configuration

[Git](https://git-scm.com/) version control configuration, command aliases, and syntax-highlighted diffing via [Delta](https://github.com/dandavison/delta).

## Overview

This directory provides the global Git configuration for personal and professional development workflows,
with SSH commit signing and delta paging.

## Key Configuration & Features

### Pager & Diffing

- **Delta**: Uses `delta` as the default Git pager with line numbers enabled (`[delta] line-numbers = true`).
- **Diff Algorithm**: Uses `patience` algorithm for cleaner, more readable patches.

### SSH Commit Signing

- Commits are signed by default (`commit.gpgsign = true`) using SSH key format (`gpg.format = ssh`)
  pointing to `~/.ssh/jeremyjousse.pub`.

### Core Settings & Defaults

- **Default branch**: `main`
- **Editor**: Visual Studio Code (`code --wait`)
- **Pull**: Automatically rebases (`pull.rebase = true`)
- **Push**: Automatically sets upstream tracking (`push.autoSetupRemote = true`)
- **Conditional Configuration**: Includes `~/.gitconfig-professional` for repositories under `~/Development/Decathlon/`.

### Common Aliases

| Alias | Command / Description |
| --- | --- |
| `git st` | `status` |
| `git ci` | `commit -m` |
| `git co` | `checkout` |
| `git br` | `branch` |
| `git ft` | `fetch` |
| `git df` | `diff -w` (ignore whitespace changes) |
| `git tree` | `log --graph --oneline --all` |
| `git lg` | Visual tree log with author and relative timestamps |
| `git pf` | `push --force-with-lease` |
| `git pr` | `pull --rebase` |
| `git undo` | Soft reset previous commit (`reset --soft HEAD^`) |
| `git cb` | Prune and delete local branches whose tracking branch is gone |
| `git purge` | Delete local branches merged into main or develop |
| `git la` | List all configured aliases |

## Symlink Location

Linked by `bootstrap.sh`:

- `config/git/.gitconfig` &rarr; `~/.gitconfig`
