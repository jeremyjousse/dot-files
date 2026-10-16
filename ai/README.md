# AI Configuration (Gemini CLI)

Custom prompt commands for the Gemini CLI. Shared agent skills, slash commands, subagents, and SDLC rules live in [`config/agents/`](../config/agents/README.md).

## Directory Structure

- **`gemini/commands/`**: Command prompts defined in TOML for the Gemini CLI:
  - `ask-only.toml`: Query-only mode without code editing.
  - `write-changelog.toml`: Conventional changelog generation prompt.
  - `git/commit-message.toml`: Conventional commit message generator.
