---
description: Stage 2 & 3 Development - Branch isolation and architecture-guided implementation
agent: sdlc-develop
---

# Stage 2 & 3: Development & Implementation

You are executing **Stage 2 (Strict Branch Isolation)** and **Stage 3 (Architectural Integrity & Implementation
Principles)** of the SDLC.

## Target Issue

Target: $ARGUMENTS

If no issue number or URL was provided above, prompt the user for the target GitHub issue number.

## Stage 2: Strict Branch Isolation

1. **Extract Issue ID & Inspect**:

   - Parse numeric issue ID from `$ARGUMENTS`.
   - Run `rtk gh issue view <issue-id>` to inspect the issue state, labels, and scope.
   - Verify that the issue has `Status: To do :computer:` (or `Status: To do 💻`). If not, warn the user that Stage 1
     Refinement must be completed first (`/sdlc-1-refine <id>`).

2. **Propose Branch Name**:

   - Features: `feat/<issue-id>-<short-description>`
   - Bug fixes: `fix/<issue-id>-<short-description>`
   - Tooling / Maintenance: `chore/<issue-id>-<short-description>`
   - Refactoring: `refactor/<issue-id>-<short-description>`

3. **Wait for User Confirmation (MANDATORY)**:

   - Propose the branch name clearly to the user.
   - **STOP AND WAIT**: Do NOT run `git checkout -b` until the user explicitly confirms the branch name.

4. **Checkout Branch & Transition Status**:

   - Once confirmed, checkout the new branch:

     ```bash
     git checkout -b <branch-name>
     ```

   - Immediately transition the issue label on GitHub:

     ```bash
     gh issue edit <issue-id> --remove-label "Status: To do :computer:" --remove-label "Status: To do 💻" --add-label "Status: In progress :construction:"
     ```

## Stage 3: Architectural Integrity & Implementation

1. **Scope Boundaries**:

   - Read and follow `## Tasks & scope` from the issue.
   - Strictly honor `## Out of Scope`; do not touch excluded areas or introduce scope creep.

2. **Project Architecture Conformance (AGENTS.md Contract)**:

   - Strictly conform to the architectural guidelines, layer boundaries, and file conventions defined in the project's
     `AGENTS.md` (or project instructions).
   - Ensure layer decoupling: do not leak infrastructure/data details into domain logic, and do not bypass architectural
     boundaries.

3. **Project Synchronization Gate**:

   - If `AGENTS.md` defines a project generation or synchronization gate (e.g. `rtk mise run generate` for XcodeGen,
     code-generators, database schema sync), execute it whenever files are added, moved, renamed, or deleted.

4. **Testing & Output Optimization**:

   - Add or update corresponding unit/integration tests for any changed logic.
   - Always route supported terminal commands through `rtk` (`rtk git *`, `rtk mise *`, `rtk cargo *`, `rtk pnpm *`,
     `rtk rg *`).

5. **Handoff to Verification**:
   - Do NOT commit directly.
   - Once implementation and tests are complete, tell the user to run `/sdlc-3-verify` to execute pre-commit
     verification.
