# OpenCode Configuration

Centralized OpenCode configuration for agents, commands, skills, rules, and MCP servers.

## Components

- **`opencode.jsonc`**: Core settings, tool permissions, and local MCP server configurations.
- **`agents/`**: SDLC specialized agents (`sdlc-refine`, `sdlc-develop`, `sdlc-verify`, `sdlc-pr-review`).
- **`command/`**: SDLC workflow commands (`/sdlc-1-refine`, `/sdlc-2-develop`, `/sdlc-3-verify`, `/sdlc-4-pr`, `/sdlc-5-review-pr`).
- **`skills/`**: Domain and best-practice skills (e.g. `rust-best-practices`, `typescript-best-practices`, `github`, etc.).
- **`rules/`**: Operational rules including the SDLC framework guidelines.

## Integrated MCP Servers

- **CodeBurn (`codeburn mcp`)**: Exposes local AI coding token spend and savings opportunities to OpenCode agents
  through `get_usage` and `get_savings` tools. Pseudonymizes project names by default and queries local session logs.
