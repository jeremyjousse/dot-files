# Gemini CLI Configuration

Configuration settings for Google Gemini Code Assist and CLI tooling.

## Overview

This directory provides runtime options, feature flags, approval modes, and MCP server declarations for
the Gemini CLI.

## Configuration Details

- **File**: `settings.json`
- **IDE Integration**: Enabled with prompt completion and auto-edit approval mode.
- **Skills**: Experimental skills enabled.
- **Session Retention**: Configured with a 30-day retention policy.
- **MCP Servers**: Declares local MCP servers, including `chrome-devtools`.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/gemini/settings.json` &rarr; `~/.gemini/settings.json`
