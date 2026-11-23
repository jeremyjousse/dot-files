---
description: Stage 0 Guided Discovery - Explore problem space, codebase constraints, and approaches before refinement
argument-hint: '[idea-or-issue-id]'
agent: sdlc-discover
---

# Stage 0: Guided Problem & Approach Discovery

You are executing **Stage 0 (Optional Guided Problem & Approach Discovery)** of the SDLC, preceding `/sdlc-1-refine`.

## Target Seed

Target: $ARGUMENTS

- If `$ARGUMENTS` is a numeric issue ID, `#<id>`, or GitHub issue URL, inspect that existing issue via
  `rtk gh issue view <issue-id> --comments`.
- If `$ARGUMENTS` is free-form text, treat it as the raw idea or problem statement to explore.
- If `$ARGUMENTS` is empty, prompt the user for the idea, problem, or GitHub issue they want to think through.

## Operational Boundaries

- **Strictly Read-Only Workspace**: Do NOT edit files, stage changes, create branches (`git checkout -b`), or start
  implementation.
- **Strictly Pre-Stage 1**: Do NOT stamp `Status: To do :computer:` (or `Status: To do 💻`). Issues created or updated
  in Stage 0 remain in `Status: Refinement :page_facing_up:` until `/sdlc-1-refine` validates them.
- **Explicit GitHub Write Gate**: Do NOT run `gh issue create` or `gh issue edit` until the user selects an approach
  and explicitly approves the proposed title and body.

## Execution Protocol

1. **Load Skill**: Load the `issue-discovery` skill and follow its 4-phase guided discovery workflow.
2. **Ground in Codebase & Docs**:
   - Read repository `AGENTS.md` to establish architectural rules, conventions, and SDLC exemptions.
   - Perform targeted read-only reconnaissance across relevant files, callers (`rtk rg`), git history (`rtk git log`,
     `rtk git show`), open issues (`rtk gh issue list`), and external docs (web search/fetch) when relevant.
   - Evaluate the 6-step reuse ladder (`minimalist-engineering.md`) to avoid unnecessary abstractions.
3. **Think Through Approaches Together**:
   - Share concise, grounded findings (touchpoints, constraints, blast radius, edge cases).
   - Compare **2–3 concrete implementation options** (leading with `(Recommended)`), highlighting trade-offs, affected
     files, and lean impact.
   - Ask at most three (`<= 3`) focused questions per turn to clarify constraints and converge on a direction. Iterate
     across turns if needed before drafting.
4. **Synthesize Draft & Confirm**:
   - Once an approach is selected, propose a plain imperative English title (sentence-cased, no trailing punctuation or
     Conventional Commit prefix) and a 3-section body (`## context` `<= 2` lines, `## Tasks & scope`,
     `## Out of Scope`).
   - **STOP AND WAIT** for explicit user approval before writing to GitHub.
5. **Persist Draft & Hand Off to Stage 1**:
   - Check available labels with `rtk gh label list`.
   - Create (`gh issue create`) or update (`gh issue edit`) the issue using a single-quoted stdin heredoc
     (`--body-file - <<'EOF'`) and attach `Status: Refinement :page_facing_up:` when defined in the repository.
   - Output the issue URL/ID and instruct the user to run `/sdlc-1-refine <issue-id>` when ready for Stage 1 gate
     sign-off. Stop here.
