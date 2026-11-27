# Centralized AI Agents Configuration

Single source of truth for shared AI coding assistant skills and universal operational instructions, shared across **OpenCode**, **Pi Coding Agent**, and **GitHub Copilot CLI**.

## Directory Structure

- **`instructions/`**: Universal operational rules formatted with `applyTo: "**"` (`*.instructions.md`):
  - `sdlc-framework.instructions.md`: 5-stage SDLC workflow lifecycle (plus optional Stage 0 discovery) from issue refinement to pull request review.
  - `minimalist-engineering.instructions.md`: Senior minimalist engineering standards (6-step reuse ladder, safety floor, `shortcut:` tracking, skipped/deferred disclosure, terse communication).
- **`skills/`**: Domain and workflow skills following the Agent Skills specification (`SKILL.md`), auto-discovered natively by OpenCode, Pi, and GitHub Copilot CLI:
  - **SDLC & Review**: `issue-discovery/`, `review-user-story/`, `sdlc-develop/`, `code-review/`, `sdlc-pr/`, `review-pr/`, `analyze-pr/`.
  - **Audit & Maintenance**: `repo-audit/`, `tech-debt/`, `update-dependencies/`.
  - **Language & Craft**: `documentation-best-practices/`, `github/`, `obsidian-daily-notes/`, `python-best-practices/`, `rust-best-practices/`, `rust-senior-review/`, `svelte-best-practices/`, `tailwind-best-practices/`, `typescript-best-practices/`, `code-quality-analyzer/`.

## Multi-Harness Symlink Topology (`bootstrap.sh`)

`bootstrap.sh` links this folder into `~/.agents/` and wires each AI coding harness to canonical resources and harness-specific extensions:

| Resource | Canonical Hub (`~/.agents/`) | OpenCode (`~/.config/opencode/`) | Pi Coding Agent (`~/.pi/agent/`) | GitHub Copilot CLI (`~/.copilot/`) |
| --- | --- | --- | --- | --- |
| **Skills** | `~/.agents/skills/<name>` | Auto-discovered from `~/.agents/skills/` | Auto-discovered (`~/.agents/skills/`) | Auto-discovered (`~/.agents/skills/`) |
| **Instructions** | `~/.agents/instructions/` | `instructions` in `opencode.jsonc` | `AGENTS.md` + `APPEND_SYSTEM.md` | `~/.copilot/instructions/*.instructions.md` |
| **Commands / Prompts** | N/A | `~/.config/opencode/commands` (`config/opencode/commands/`) | `~/.pi/agent/prompts` (`config/pi/prompts/`) | Native skills (`/<skill-name>`) |
| **Agents** | N/A | `~/.config/opencode/agents` (`config/opencode/agents/`) | N/A | `~/.copilot/agents` (`config/copilot/agents/*.agent.md`) |

> **Note**: Each skill directory under `config/agents/skills/*` should remain compatible with third-party skills installed via `npx skills` in `~/.agents/`.

## Capability-Tier Agents

Agents are consolidated into four capability tiers (`config/opencode/agents/` and `config/copilot/agents/`):

- **`sdlc-readonly`**: Read-only workspace tier (`edit: deny`) for Stage 0 discovery, Stage 1 refinement, and Stage 4 verification.
- **`sdlc-worker`**: Execution tier (`edit: allow`, `gh pr merge: deny`) for Stage 2/3 development and Stage 5 PR workflows.
- **`pr-analyzer`**: Read-only workspace tier with gated access to `~/Mon Drive/Obsidian` for conceptual PR analysis (`/pr-analyze`).
- **`yolo`**: Standalone `mode: primary` agent (`user-invocable: true`, `disable-model-invocation: true` in Copilot) with unrestricted tool access and explicit SDLC gate bypass.

`/pr-analyze` reads `~/Mon Drive/Obsidian` when access is available and asks for confirmation before writing notes. Copilot requires its own authorization for vault access; OpenCode currently denies vault writes.
