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

## Standalone Agent (`yolo`)

- **Definition (`agents/yolo.md`)**: Opt-in primary agent (`mode: primary`) for quick ad-hoc tasks that explicitly bypasses all `sdlc-framework.md` stage gates (refinement, branch isolation, pre-commit review, and PR gates).
- **Permissions (`opencode.jsonc`)**: `agents.yolo` sets `edit`, `shell`, and `external_directory` to `allow`, overriding global `ask` prompts for unrestricted execution.
- **Isolation Behavior**: Because `mode: primary` restricts `yolo` to direct user selection in the session switcher, other agents (`sdlc-*`, `pr-analyzer`, or built-ins) cannot invoke or delegate tasks to `yolo` as a subagent. All existing SDLC agent permissions remain unchanged.
