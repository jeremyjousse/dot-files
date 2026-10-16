# Centralized AI Agents Configuration

Single source of truth for AI coding assistant skills, slash commands, subagents, and SDLC operational rules, shared across **OpenCode**, **Pi Coding Agent**, and **GitHub Copilot CLI**.

## Directory Structure

- **`agents/`**: SDLC specialized agents (`sdlc-refine`, `sdlc-develop`, `sdlc-verify`, `sdlc-pr-review`) with dual OpenCode and GitHub Copilot CLI frontmatter.
- **`commands/`**: SDLC workflow slash commands (`/sdlc-1-refine`, `/sdlc-2-develop`, `/sdlc-3-verify`, `/sdlc-4-pr`, `/sdlc-5-review-pr`) and utility commands (`/update-dependencies`).
- **`rules/`**: Universal operational rules (`sdlc-framework.md`).
- **`skills/`**: Domain and best-practice skills following the Agent Skills specification (`SKILL.md`).

## Multi-Harness Symlink Topology (`bootstrap.sh`)

`bootstrap.sh` links this folder into `~/.agents/` and wires each AI coding harness to those canonical resources:

| Resource      | Canonical Hub (`~/.agents/`)         | OpenCode (`~/.config/opencode/`)             | Pi Coding Agent (`~/.pi/agent/`) | GitHub Copilot CLI (`~/.copilot/`) |
| ------------- | ------------------------------------ | -------------------------------------------- | -------------------------------- | ---------------------------------- |
| **Skills**    | `~/.agents/skills/<name>` (per-dir)  | Auto-discovered from `~/.agents/skills/`     | Auto-discovered (`~/.agents/skills/`) | Auto-discovered (`~/.agents/skills/`) |
| **Commands**  | `~/.agents/commands`                 | `~/.config/opencode/command`                 | `~/.pi/agent/prompts`            | Native skills / `@agent`           |
| **Subagents** | `~/.agents/agents`                   | `~/.config/opencode/agents`                  | N/A                              | `~/.copilot/agents`                |
| **Rules**     | `~/.agents/rules/sdlc-framework.md`  | `instructions` in `opencode.jsonc`           | `~/.pi/agent/AGENTS.md`          | `~/.copilot/copilot-instructions.md` |

> **Note**: Each skill directory under `config/agents/skills/*` is linked individually into `~/.agents/skills/<skill-name>` so that third-party skills installed via `npx skills` (tracked in `~/.agents/.skill-lock.json`) coexist without being overwritten.
