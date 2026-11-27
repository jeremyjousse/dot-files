---
name: sdlc-develop
description: Execute SDLC Stage 2 (branch isolation with confirmation) and Stage 3 (architecture-guided implementation and testing).
---

# SDLC Development Skill (Stage 2 & 3)

Use this skill when implementing an approved GitHub issue under Stage 2 (Strict Branch Isolation) and Stage 3 (Architectural Integrity & Implementation).

---

## Stage 2: Strict Branch Isolation

1. **Extract Issue ID & Inspect**:
   - Parse numeric issue ID from the target argument or prompt for it if missing.
   - Run `rtk gh issue view <issue-id>` to inspect state, labels, and scope.
   - Verify the issue has `Status: To do :computer:` (or `Status: To do 💻`). If not, warn that Stage 1 refinement (`review-user-story`) must complete first.
2. **Propose Branch Name**:
   - Features: `feat/<issue-id>-<short-description>`
   - Bug fixes: `fix/<issue-id>-<short-description>`
   - Tooling / Maintenance: `chore/<issue-id>-<short-description>`
   - Refactoring: `refactor/<issue-id>-<short-description>`
3. **Wait for User Confirmation (MANDATORY)**:
   - Propose the branch name clearly and **STOP AND WAIT**.
   - NEVER run `git checkout -b` or `git worktree add` until the user explicitly confirms.
4. **Branch Isolation & Status Transition**:
   - **Default (Standard Branch)**:
     ```bash
     git checkout -b <branch-name>
     ```
   - **Opt-in (Worktree Isolation)** when explicitly requested:
     ```bash
     git worktree add .worktrees/<branch-name> -b <branch-name>
     ```
   - Immediately transition the GitHub issue label:
     ```bash
     gh issue edit <issue-id> --remove-label "Status: To do :computer:" --add-label "Status: In progress :construction:"
     ```
     *(If the repository uses the emoji variant `Status: To do 💻`, remove that label instead.)*

---

## Stage 3: Architectural Integrity & Implementation

1. **Scope Boundaries**:
   - Strictly implement items from `## Tasks & scope`.
   - Strictly honor `## Out of Scope`; avoid scope creep or unrequested refactoring.
2. **Project Architecture Conformance (`AGENTS.md`)**:
   - Read and follow `AGENTS.md` in the project root for layer boundaries, conventions, and exemptions.
3. **Project Synchronization Gate**:
   - If `AGENTS.md` defines a generation or sync command (e.g. `rtk mise run generate`, schema sync), run it whenever files are added, moved, renamed, or deleted.
4. **Minimalist Engineering & Testing**:
   - Traverse the 6-step reuse ladder (`minimalist-engineering.instructions.md`), uphold the safety floor, and document deliberate limits with `// shortcut: <limit>, <upgrade trigger>`.
   - Add or update targeted tests for non-trivial/risky logic (unless `AGENTS.md` exempts automated tests).
   - Route supported terminal commands through `rtk` (`rtk git *`, `rtk mise *`, `rtk cargo *`, `rtk pnpm *`, `rtk rg *`).
5. **Handoff to Verification**:
   - Do NOT run `git commit` directly.
   - Conclude with the Skipped & Deferred disclosure and hand off to Stage 4 verification (`code-review` skill).
