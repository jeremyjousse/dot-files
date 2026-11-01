# OpenCode Configuration

OpenCode harness settings and MCP server configuration, integrated with the centralized AI agent hub in [`config/agents/`](../agents/README.md).

## Components

- **`opencode.jsonc`**: Core settings, ambient `instructions` (`~/.agents/rules/sdlc-framework.md`, `~/.agents/rules/minimalist-engineering.md`), ordered `permissions`, `agents`, and local `mcp.servers` configurations.
- **Shared AI Resources (`~/.agents/`)**:
  - `commands` &rarr; `~/.agents/commands` (`config/agents/commands/`)
  - `agents` &rarr; `~/.config/opencode/agents` (`config/opencode/agents/`)
  - `skills` &rarr; Auto-discovered natively from `~/.agents/skills/` (`config/agents/skills/`)
  - `rules` &rarr; Loaded via `instructions` from `~/.agents/rules/sdlc-framework.md` and `~/.agents/rules/minimalist-engineering.md` (`config/agents/rules/`)

## Integrated MCP Servers

- **CodeBurn (`codeburn mcp`)**: Exposes local AI coding token spend and savings opportunities to OpenCode agents
  through `get_usage` and `get_savings` tools. Pseudonymizes project names by default and queries local session logs.
