# Universal Software Development Life Cycle (SDLC) Framework

This framework defines the mandatory 5-stage SDLC workflow across repositories. All OpenCode agents, subagents, and
automated workflows MUST strictly follow these 5 stages in sequential order during development tasks. No shortcuts or
skipped stages are permitted. Issue review and refinement is strictly confined to Stage 1 and must never automatically
cascade into development.

---

## Stage 1: User Story & Issue Refinement Gate

- **Slash Command**: `/sdlc-1-refine <issue-id>`
- **Dedicated Agent**: `sdlc-refine`
- **Permissions**: `edit: deny`, `bash: gh issue *, gh label list*`, `task: deny`, `external_directory: deny`

Before writing ANY code, creating branches, or modifying files:

1. **Inspect Issue via GitHub CLI**:
   - `rtk gh issue view <issue-id>`
2. **Verify Refinement Gate Criteria**:
   - **Language**: All GitHub Issues, Pull Requests, commit messages, and code comments MUST be written in English.
   - **Status Label**: The issue MUST have `Status: To do :computer:` (or `Status: To do 💻`). If
     `Status: Refinement :page_facing_up:` is present or `Status: To do` is missing, refinement is required.
   - **Mandatory Sections**:
     - `## context`: Max 2 lines explaining the "why".
     - `## Tasks & scope`: Clear, split tasks and explicit boundaries.
     - `## Out of Scope`: Explicitly excluded features/actions.
3. **Refinement Action**:
   - If criteria are missing: load `review-user-story` skill, ask <= 3 clarifying questions, propose refined English
     body, update issue via `gh issue edit`.
4. **Task Decoupling**:
   - A request to review or scope an issue is **STRICTLY confined to Stage 1**.
   - NEVER create a branch or write code during a refinement task.

---

## Stage 2: Strict Branch Isolation

- **Slash Command**: `/sdlc-2-develop <issue-id>`
- **Dedicated Agent**: `sdlc-develop`
- **Permissions**: `edit: allow`, scoped `bash` (development and build tools), `task: deny`

Development must NEVER occur directly on `main` or an unrelated branch.

1. **Branch Naming**:
   - `feat/<issue-id>-<short-description>`
   - `fix/<issue-id>-<short-description>`
   - `chore/<issue-id>-<short-description>`
   - `refactor/<issue-id>-<short-description>`
2. **Branch Creation Gate**:
   - NEVER create or checkout a branch automatically.
   - Propose the branch name and **wait for explicit user confirmation** before running `git checkout -b <branch>`.
3. **Issue Status Transition**:

   - Immediately upon creating the branch and starting development, update the issue label on GitHub:

     ```bash
     gh issue edit <issue-id> --remove-label "Status: To do :computer:" --remove-label "Status: To do 💻" --add-label "Status: In progress :construction:"
     ```

---

## Stage 3: Architectural Integrity & Implementation

All implementations must conform strictly to the project's architecture contract:

1. **Scope Boundaries**:
   - Strictly implement items from `## Tasks & scope`.
   - Strictly honor `## Out of Scope`; avoid scope creep or unrequested refactoring.
2. **Project Architecture Conformance (AGENTS.md)**:
   - Consult `AGENTS.md` in the project root for layer decoupling rules, bounded contexts, domain purity, and framework
     isolation.
3. **Project Synchronization Gate**:
   - If specified in `AGENTS.md` (e.g., XcodeGen via `rtk mise run generate`, database migration generators, code
     generation), regenerate project configurations whenever files are added, moved, or deleted.
4. **Testing Discipline**:
   - Write or update unit and integration tests covering all changed behavior and edge cases.
5. **No Direct Commits**:
   - Do NOT commit directly during development. Hand off to Stage 4 (`/sdlc-3-verify`).

---

## Stage 4: Local Code Review & Pre-Commit Verification

- **Slash Command**: `/sdlc-3-verify`
- **Dedicated Agent**: `sdlc-verify`
- **Permissions**: `edit: deny`, scoped verification `bash` (test/lint/check tools, read-only git), `task: deny`

Before any commit is proposed:

1. **Architectural Review**:
   - Inspect changes with `git diff`. Confirm domain purity and layer boundaries as specified in `AGENTS.md`.
2. **Test Coverage Assessment**:
   - Verify that new or modified logic is backed by corresponding tests. Confirm no stubs or dead code remain.
3. **Run Quality Verification Suite**:
   - If configured, run `rtk mise run verify` (or project task runner).
   - Otherwise, run all quality commands specified in `AGENTS.md` under `## Quality Commands`.
   - All checks must pass with zero errors.
4. **Commit Approval Rule (MANDATORY)**:
   - **NEVER** commit directly or automatically.
   - Present `git status` with the list of changed files.
   - Propose a Conventional Commit message (`feat: ...`, `fix: ...`, `chore: ...`, `refactor: ...`, `test: ...`).
   - **Wait for explicit user approval** before running `git commit`.

---

## Stage 5: Pull Request & Merge Gate

- **Slash Commands**: `/sdlc-4-pr [issue-id]`, `/sdlc-5-review-pr [pr-id]`
- **Dedicated Agent**: `sdlc-pr-review`
- **Permissions**: `edit: allow` (scoped to review fixes), `gh pr *`, `gh pr merge: deny`, `gh api *`, `git push`

1. **Push Branch**:

   ```bash
   git push -u origin HEAD
   ```

2. **Create Pull Request**:
   - Check for `.github/PULL_REQUEST_TEMPLATE.md`.
   - Reference the issue (`Closes #<id>`).
   - Return PR URL.
3. **CI Verification**:
   - Inspect status: `rtk gh pr checks` and `rtk gh pr status`.
4. **PR Review Feedback Loop**:
   - Load `review-pr` skill.
   - Fetch review threads via GraphQL.
   - Triage into **Legitimate** (fix code/test, run verify, commit with approval, push, react 👍, reply via stdin
     heredoc, resolve thread) vs **Non-Applicable** (no code change, react 👎, reply with technical rationale, resolve
     thread).
5. **Merge Gate**:
   - **NEVER** run `gh pr merge`.
   - Merging is strictly reserved for human manual action once all checks and threads are resolved.

---

## Dedicated SDLC Commands & Subagents Reference

| Slash Command            | Stage       | Agent            | File Permissions | Primary Purpose                                                                          |
| ------------------------ | ----------- | ---------------- | ---------------- | ---------------------------------------------------------------------------------------- |
| `/sdlc-1-refine <id>`    | Stage 1     | `sdlc-refine`    | `edit: deny`     | Refine issue into English with 3 mandatory sections.                                     |
| `/sdlc-2-develop <id>`   | Stage 2 & 3 | `sdlc-develop`   | `edit: allow`    | Confirm branch, set In progress label, guide implementation via `AGENTS.md`.             |
| `/sdlc-3-verify`         | Stage 4     | `sdlc-verify`    | `edit: deny`     | Architectural check, quality commands (`mise run verify` / `AGENTS.md`), propose commit. |
| `/sdlc-4-pr [id]`        | Stage 5     | `sdlc-pr-review` | `edit: allow`    | Push branch, create PR with template, inspect CI.                                        |
| `/sdlc-5-review-pr [id]` | Stage 5     | `sdlc-pr-review` | `edit: allow`    | Fetch threads via GraphQL, triage, fix, reply, and resolve. Merge denied.                |
