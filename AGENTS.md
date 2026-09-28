# Project Agents Contract: dot-files

This document defines the architecture contract, conventions, and operational boundaries for OpenCode agents working
within this repository.

---

## Repository Identity & Nature

This repository is **NOT an application repository** (there is no backend, frontend, microservice, or domain business
logic). Instead, it is a **dotfiles, developer environment, and machine provisioning repository** for macOS.

Key responsibilities:

- **Centralized OpenCode Configuration**: Houses the source of truth for global OpenCode configurations in
  `config/opencode/` (commands, subagents, skills, rules, and global settings).
- **Tool Configurations**: Houses dotfiles and configuration directories for daily developer tools (`zsh`, `git`,
  `nvim`, `ghostty`, `alacritty`, `zellij`, `starship`, `nushell`, `hammerspoon`, `vscode`).
- **Provisioning & Automation**: Provides reproducible bootstrapping and symlinking scripts (`bootstrap.sh`, `lib/*.sh`,
  `Makefile`) and package manifests (`install/Brewfile`).

---

## Architectural Specificities & SDLC Exemptions

Because this is a configuration and dotfiles repository, the standard application architectural gates in the SDLC
Framework must be interpreted as follows:

### 1. Hexagonal & Layered Architecture Exemption

- **Strict Exemption**: Hexagonal Architecture, Clean Architecture, DDD, domain purity, application/infrastructure layer
  decoupling, interfaces, and ports/adapters **DO NOT APPLY** to this repository.
- **SDLC Agent Directives (`sdlc-develop`, `sdlc-verify`, `sdlc-pr-review`)**:
  - Do **NOT** verify domain purity or inspect changes for architectural layer leaks during verification or reviews.
  - Do **NOT** attempt to refactor dotfile scripts into domain abstractions or layered architectures.

### 2. Dotfiles Architectural Principles

Implementations must adhere to dotfiles-specific conventions:

- **Isolated Tool Configs**: Each tool configuration lives in its designated subfolder under `config/<tool>/`.
- **Centralized OpenCode Authority**: All shared OpenCode agents, commands, skills, and rules must be maintained in
  `config/opencode/` so they can be symlinked to `~/.config/opencode/` by `bootstrap.sh`. Changes here impact the global
  OpenCode environment and require restarting OpenCode.
- **Idempotency & Safety**: All shell automation in `bootstrap.sh` or `lib/*.sh` must remain idempotent (safe to run
  multiple times) and must back up non-symlinked existing files (`.back`) rather than destructively overwriting them.
- **Portability & POSIX Compliance**: Shell scripts should adhere to standard Bash/Zsh practices and pass syntax checks.

---

## Testing Policy: Zero Automated Test Suite

- **No Unit / Integration Tests**: This repository does NOT maintain automated test suites (e.g. `npm test` or
  `pnpm test` will fail by default with `"Error: no test specified"`).
- **SDLC Agent Directives**:
  - **Stage 3 (`sdlc-develop`)**: Do **NOT** attempt to write unit tests, create test files, or configure test
    frameworks for configuration or dotfile changes.
  - **Stage 4 (`sdlc-verify`)**: The Test Coverage Assessment step is **NOT APPLICABLE (N/A)**. Agents must **NEVER**
    run `npm test` or `pnpm test`, and must never reject or block verification due to the absence of tests.
  - **Stage 5 (`sdlc-pr-review`)**: Do not request or expect unit tests during PR reviews.

---

## Quality Commands

SDLC verification (`/sdlc-3-verify` / `sdlc-verify`) must execute the following commands when verifying working tree
changes:

- **Format Check**:

  ```bash
  pnpm prettier --check .
  ```

- **Lint Check** (JavaScript / repository root):

  ```bash
  pnpm eslint .
  ```

- **Shell Syntax Validation** (run on any new or modified `.sh` scripts):

  ```bash
  bash -n <script.sh>
  ```

- **Typecheck**: `None (N/A)`
- **Test**: `None (N/A - dotfiles repository, do not run test suites)`
- **Build**: `None (N/A)`

---

## Project Synchronization Gate

Whenever new configuration files or directories are introduced under `config/`:

1. **Bootstrap Symlinking**: Ensure `bootstrap.sh` contains the corresponding `link_config_files` or `copy_config_files`
   entry to link the file/folder to its expected location under `$HOME`.
2. **OpenCode Configuration**: When files under `config/opencode/` are created or modified, inform the user to restart
   OpenCode so the loaded global runtime refreshes.

---

## Git & Commit Conventions

- **Conventional Commits**: Commit messages must follow Conventional Commits format, enforced via Husky and commitlint.
  - Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`.
  - Recommended scopes: `opencode`, `zsh`, `git`, `nvim`, `ghostty`, `alacritty`, `brew`, `install`, `scripts`.
  - Example: `feat(opencode): introduce centralized agents and commands`
- **Pre-Commit Gate**: Agents must **NEVER** commit directly. Always propose the commit message and require explicit
  human approval before executing `git commit`.
