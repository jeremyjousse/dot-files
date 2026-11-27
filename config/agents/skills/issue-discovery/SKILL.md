---
name: issue-discovery
description:
  Use before Stage 1 refinement when exploring a raw idea or ambiguous GitHub issue to analyze codebase constraints,
  compare approaches, and shape a draft User Story.
---

# Guided Issue Discovery Skill

This skill guides **Stage 0 (Optional Pre-Refinement Discovery)**: an interactive, read-only thinking phase that helps
explore problem space, codebase constraints, and implementation trade-offs before locking scope in `/sdlc-1-refine`.

---

## Strict Scope Boundary: Discovery & Pre-Refinement ONLY

- **Read-Only Workspace (`edit: deny`)**: NEVER modify, create, stage, or commit repository files.
- **No Branch or Worktree Creation**: NEVER run `git checkout -b`, `git switch -c`, `git branch <name>`, or
  `git worktree add`.
- **No Premature Gate Bypass**: NEVER apply `Status: To do :computer:` (or `Status: To do 💻`). Passing the Refinement
  Gate belongs exclusively to Stage 1 (`/sdlc-1-refine`).
- **GitHub Write Confirmation Gate**: NEVER run `gh issue create` or `gh issue edit` without explicit user approval of
  the selected approach and proposed issue draft.

---

## 4-Phase Guided Discovery Protocol

### Phase 1: Seed & Context Grounding

1. **Resolve Input**:
   - **Existing GitHub Issue** (numeric ID, `#<id>`, or issue URL): inspect details and discussion via
     `rtk gh issue view <id> --comments`.
   - **Raw Idea or Problem Statement**: treat the text directly as the discovery seed and check related open issues via
     `rtk gh issue list --search "<keywords>"` when helpful.
   - **Empty Input**: prompt the user for the idea, problem, or target issue ID.
2. **Ground in Repository Reality**:
   - Read `AGENTS.md` to establish architectural boundaries, conventions, and SDLC exemptions.
   - Inspect relevant entry points, modules, callers, and git history (`read`, `glob`, `grep`, `rtk rg`, `rtk git log`,
     `rtk git show`).
   - Query external documentation or upstream specs via web search/fetch when platform or third-party behavior matters.
3. **Traverse the 6-Step Reuse Ladder (`minimalist-engineering.instructions.md`)**:
   - Check in order: (1) Does it need to exist? (2) Already in codebase? (3) Standard library / native platform
     feature? (4) Already installed dependency? (5) Readable one-liner? (6) Minimum working code.

### Phase 2: Interactive Problem & Approach Exploration

Act as a collaborative thinking partner rather than jumping straight to an issue template:

1. **Surface Grounded Constraints**:
   - Concisely summarize relevant codebase touchpoints, caller blast radius, architectural rules, and hidden edge cases.
2. **Compare Viable Approaches (2–3 Options)**:
   - Lead with the **recommended option first** (`Option A: <Name> (Recommended)`).
   - For each option, state concisely:
     - **Mechanism & Touchpoints**: How it works and which areas/files it affects.
     - **Trade-offs**: Complexity, maintenance footprint, and lean impact (reuse vs new code).
     - **Risks / Shortcuts**: Operational limits or deliberate `shortcut:` candidates with upgrade triggers.
3. **Iterative Clarifying Questions (`<= 3` per turn)**:
   - Ask at most three targeted questions per turn to challenge assumptions, narrow boundaries, and resolve trade-offs.
   - Continue iterating across turns if the user wants to explore alternatives or refine constraints before deciding.

### Phase 3: Draft User Story Synthesis

Once the user converges on an approach, synthesize an English draft aligned with Stage 1 criteria:

- **Proposed Title**: Plain imperative English (`Add ...`, `Fix ...`, `Refine ...`, `Update ...`), sentence-cased,
  typo-free, without trailing punctuation or Conventional Commit prefixes.
- **Proposed Body** (3 mandatory sections):
  - `## context`: Maximum 2 lines explaining the "why" and chosen direction.
  - `## Tasks & scope`: Clear, split tasks and explicit boundaries respecting `AGENTS.md`.
  - `## Out of Scope`: Explicitly excluded features, edge cases, or deferred abstractions.

Present the proposed title and body clearly, then **STOP AND WAIT** for explicit user confirmation.

### Phase 4: GitHub Draft Persistence & Stage 1 Handoff

After explicit user validation:

1. **Inspect Repository Labels**:
   - Run `rtk gh label list` to verify whether `Status: Refinement :page_facing_up:` (and optional `Type: *` labels)
     exist in the repository before passing `--label` / `--add-label`.
2. **Create or Update Draft via Stdin Heredoc**:
   - Always pass the Markdown body via single-quoted stdin heredoc (`--body-file - <<'EOF'`) to prevent shell backtick
     expansion.
   - If the repository lacks `Status: Refinement :page_facing_up:`, omit `--label` or `--add-label` from the command.
   - **New Issue (from raw idea)**:

     ```bash
     gh issue create --title "<proposed_title>" --label "Status: Refinement :page_facing_up:" --body-file - <<'EOF'
     <proposed_body>
     EOF
     ```

   - **Existing Issue**:

     ```bash
     gh issue edit <issue-id> --title "<proposed_title>" --add-label "Status: Refinement :page_facing_up:" --body-file - <<'EOF'
     <proposed_body>
     EOF
     ```

3. **Handoff**:
   - Return the created or updated GitHub issue URL/number.
   - Instruct the user to run `/sdlc-1-refine <issue-id>` when ready to validate and transition the issue to
     `Status: To do :computer:`.
   - Stop here. Do NOT propose branch creation or start implementation.
