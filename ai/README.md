# AI Configuration & Skills

Shared prompt commands and specialized skills for local AI coding assistants and agents.

## Overview

This directory houses cross-tool prompt commands and agent skills shared across AI assistant
environments (such as Gemini CLI and OpenCode).

## Directory Structure

- **`gemini/commands/`**: Command prompts defined in TOML for the Gemini CLI:
  - `ask-only.toml`: Query-only mode without code editing.
  - `write-changelog.toml`: Conventional changelog generation prompt.
  - `git/commit-message.toml`: Conventional commit message generator.
- **`skills/`**: Specialized skill definitions providing domain rules and execution workflows:
  - `code-quality-analyzer/`: Fast code analysis, readability score, and structural quality review.
  - `obsidian-daily-notes/`: Daily note generation and management workflow for Obsidian vaults.

## Symlink Location

Linked by `bootstrap.sh`:

- `ai/gemini/commands` &rarr; `~/.gemini/commands`
- `ai/skills` &rarr; `~/.gemini/skills`
