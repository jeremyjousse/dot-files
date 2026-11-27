# OpenCode Configuration

OpenCode harness settings, slash commands, capability-tier agents, and MCP server configuration, integrated with the centralized AI hub in [`config/agents/`](../agents/README.md).

## Components

- **`opencode.jsonc`**: Core settings, ambient `instructions` (`~/.agents/instructions/sdlc-framework.instructions.md`, `~/.agents/instructions/minimalist-engineering.instructions.md`), ordered `permissions`, `agents`, and local `mcp.servers`.
- **`commands/`**: Minimal slash command wrappers (`~/.config/opencode/commands`) delegating to shared skills in `~/.agents/skills/` and routing to capability-tier agents:
  - `sdlc-0-discover`, `sdlc-1-refine`, `sdlc-3-review` &rarr; `sdlc-readonly`
  - `sdlc-2-develop`, `sdlc-4-pr`, `sdlc-5-review-pr` &rarr; `sdlc-worker`
  - `pr-analyze` &rarr; `pr-analyzer`
  - `repo-audit`, `tech-debt`, `update-dependencies` &rarr; active session agent
- **`agents/`**: Thin guardrail-only agent definitions (`~/.config/opencode/agents`) for `sdlc-readonly`, `sdlc-worker`, `pr-analyzer`, and `yolo`. Permissions are enforced per agent in `opencode.jsonc`.
- **Skills (`~/.agents/skills/`)**: Auto-discovered natively from `config/agents/skills/`.

## Integrated MCP Servers

- **CodeBurn (`codeburn mcp`)**: Exposes local AI coding token spend and savings opportunities to OpenCode agents
  through `get_usage` and `get_savings` tools. Pseudonymizes project names by default and queries local session logs.

## Standalone Agent (`yolo`)

- **Definition (`agents/yolo.md`)**: Opt-in primary agent (`mode: primary`) for quick ad-hoc tasks that explicitly bypasses all `sdlc-framework.instructions.md` stage gates.
- **Permissions (`opencode.jsonc`)**: `agents.yolo` sets `edit`, `shell`, and `external_directory` to `allow`, overriding global `ask` prompts for unrestricted execution.
- **Isolation Behavior**: Because `mode: primary` restricts `yolo` to direct user selection in the session switcher, other agents cannot invoke or delegate tasks to `yolo` as a subagent.
