# OpenCode Configuration

OpenCode harness settings and MCP server configuration, integrated with the centralized AI agent hub in [`config/agents/`](../agents/README.md).

## Components

- **`opencode.jsonc`**: Core settings, ambient `instructions` (`~/.agents/rules/sdlc-framework.md`), tool permissions, and local MCP server configurations.
- **Shared AI Resources (`~/.agents/`)**:
  - `command` &rarr; `~/.agents/commands` (`config/agents/commands/`)
  - `agents` &rarr; `~/.agents/agents` (`config/agents/agents/`)
  - `skills` &rarr; Auto-discovered natively from `~/.agents/skills/` (`config/agents/skills/`)
  - `rules` &rarr; Loaded via `instructions` from `~/.agents/rules/sdlc-framework.md` (`config/agents/rules/`)

## Integrated MCP Servers

- **CodeBurn (`codeburn mcp`)**: Exposes local AI coding token spend and savings opportunities to OpenCode agents
  through `get_usage` and `get_savings` tools. Pseudonymizes project names by default and queries local session logs.
