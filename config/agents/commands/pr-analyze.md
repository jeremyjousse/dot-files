---
description: Analyze and explain a Pull Request, audit technical quality, and sync insights to Obsidian
argument-hint: '[pr-number-or-url]'
agent: pr-analyzer
---

# Pull Request Explainer & Analyzer

Execute a conceptual, architectural, and quality analysis of the target Pull Request adhering to the `analyze-pr`
skill and engineering standards from the Obsidian vault.

## Target PR

Target: $ARGUMENTS

If `$ARGUMENTS` is empty, detect the active Pull Request for the current branch using `rtk gh pr view` or
`rtk gh pr status`.

## Operational Boundaries

- **Read-Only Workspace**: Never modify, refactor, stage, or commit project files on the target PR branch.
- **No PR Mutation**: Never run `gh pr review --approve`, `gh pr merge`, or alter the Stage 5 `/sdlc-5-review-pr`
  workflow.
- **Logical Block Synthesis**: Never produce verbose file-by-file diff narrations; group changes into cohesive
  functional, domain, or architectural blocks.
- **Obsidian Write Gate**: Never create or update vault notes without explicit user confirmation.

## Execution Protocol

1. **Load Skill**: Load the `analyze-pr` skill for the full inspection, deduplication, and reporting protocol.
2. **Gather PR & Vault Context**:
   - Inspect PR metadata and diff (`rtk gh pr view`, `rtk gh pr diff`, `rtk gh repo view`, `rtk gh issue view`).
   - Read repository `AGENTS.md` to establish architectural and quality contracts.
   - Use `~/Mon Drive/Obsidian` as the vault. Request harness-specific access when needed. Never bypass a denial.
   - Scan the vault (`title`, `aliases`, `tags`, headings) for existing notes and personal standards.
   - If the vault is unavailable or access is denied, report the reason in Section 6 and skip vault grounding and sync.
3. **Output Structured Report**: Render the 6-section markdown report defined by `analyze-pr`:
   1. Executive Summary & Intent
   2. Key Concepts & Architecture Overview (linked with `[[Obsidian Notes]]`)
   3. Functional & Component Blocks Walkthrough
   4. Quality, Security & Test Coverage Analysis
   5. Actionable Recommendations
   6. Obsidian Knowledge Base Sync (`MATCH` / `ENRICH` / `CREATE` proposals + Confirmation Gate)
4. **Confirmation Gate**: If `ENRICH` or `CREATE` proposals exist, **STOP AND WAIT** for explicit user confirmation
   before writing or updating any vault note.
