# Dot files

Bootstrap my laptop from scratch.

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
