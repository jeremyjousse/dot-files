# Dot files

Bootstrap and manage a macOS developer workstation from scratch.

## Quick Start

1. Clone this repository into `~/Development/Personal/dot-files`.
2. Configure optional environment variables in `.env` (e.g. `GIT_USER_NAME`, `GIT_USER_EMAIL`, `GIT_SIGNING_KEY`).
3. Run the default setup:

```bash
make
```

This installs the Homebrew and VS Code packages, then runs `bootstrap.sh` to install the configuration. To also install
Homebrew Casks and Mac App Store apps, run:

```bash
make brew-gui-packages
```

Run `make update` to update Homebrew formulae without upgrading GUI applications.

## Repository Directory Map

Each key folder contains a dedicated `README.md` documenting its configuration and usage:

- **[`ai/`](ai/README.md)**: AI agent skills and prompt commands (Gemini CLI, OpenCode).
- **[`config/`](config/)**: Tool and application configurations symlinked into `$HOME`:
  - **[`alacritty/`](config/alacritty/README.md)**: Fast GPU-accelerated terminal emulator configuration.
  - **[`gemini/`](config/gemini/README.md)**: Google Gemini Code Assist and CLI settings.
  - **[`gh-dash/`](config/gh-dash/README.md)**: GitHub CLI terminal dashboard for PRs and issues.
  - **[`ghostty/`](config/ghostty/README.md)**: Ghostty terminal emulator configuration.
  - **[`git/`](config/git/README.md)**: Git configuration, aliases, and Delta syntax-highlighting pager.
  - **[`hammerspoon/`](config/hammerspoon/README.md)**: macOS window management and automation with Hammerspoon.
  - **[`mise/`](config/mise/README.md)**: Multi-language runtime version manager (`mise-en-place`).
  - **[`nix-darwin/`](config/nix-darwin/README.md)**: Nix-darwin system configuration.
  - **[`nushell/`](config/nushell/README.md)**: Nushell configuration and scripts.
  - **[`nvim/`](config/nvim/README.md)**: Neovim configuration using `lazy.nvim`.
  - **[`opencode/`](config/opencode/README.md)**: Centralized OpenCode configuration, SDLC agents, and rules.
  - **[`starship/`](config/starship/README.md)**: Starship cross-shell prompt configuration.
  - **[`vscode/`](config/vscode/README.md)**: Visual Studio Code settings, extensions, and snippets.
  - **[`zellij/`](config/zellij/README.md)**: Terminal workspace and multiplexer configuration.
  - **[`zsh/`](config/zsh/README.md)**: Zsh configuration, Oh My Zsh plugins, and custom aliases.
- **[`install/`](install/README.md)**: Homebrew bundle manifests (`Brewfile`, `CaskBrewfile`, `MasBrewfile`, `VscodeBrewfile`) for CLI tools, runtimes, casks, and extensions.
- **[`lib/`](lib/README.md)**: Shell automation libraries, symlink helpers, and dependency installers.
- **[`macOs-defaults/`](macOs-defaults/README.md)**: macOS system preferences and sensible defaults scripts.

## AI & Developer Tooling

This environment includes tooling and configurations for local AI coding assistants:

- **[CodeBurn](https://codeburn.app/)**: Local AI token consumption and cost tracking across coding assistants
  (OpenCode, Claude Code, Copilot, Gemini CLI).
  - Shell alias: `cb` (e.g. `cb status`, `cb overview`, `cb models`).
  - OpenCode MCP server: configured in `config/opencode/opencode.jsonc` (`codeburn mcp`) providing `get_usage`
    and `get_savings` tools for agent queries.
  - Package: installed via Homebrew (`install/Brewfile`).
- **[rtk](https://www.rtk-ai.app/)**: CLI proxy reducing LLM token consumption for shell commands.

## Inspirations

- [macOS defaults list](https://macos-defaults.com/)
- [dotfiles of Omer Hamerman](https://github.com/omerxx/dotfiles)
- [dotfiles of Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [dotfiles of Lars Kappert](https://github.com/webpro/dotfiles)
- [tones of macOS system setup](https://github.com/joeyhoer/starter)
