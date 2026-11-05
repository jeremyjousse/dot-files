# Universal Software Development Life Cycle (SDLC) Framework

This framework defines the mandatory 5-stage SDLC workflow across repositories. All OpenCode agents, subagents, and
automated workflows MUST strictly follow these 5 stages in sequential order during development tasks. No shortcuts or
skipped stages are permitted. Issue review and refinement is strictly confined to Stage 1 and must never automatically
cascade into development.

---

## Stage 1: User Story & Issue Refinement Gate

- **Slash Command**: `/sdlc-1-refine <issue-id>`
- **Dedicated Agent**: `sdlc-refine`
- **Permissions**: `edit: deny`, `shell: gh issue *, rtk gh issue *, gh label list *, rtk gh label list *, gh repo view *, rtk gh repo view *`, `subagent: deny`, `external_directory: deny`

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
- **Permissions**: `edit: allow`, scoped `shell` (development and build tools), `subagent: deny`, `external_directory: deny`

Development must NEVER occur directly on `main` or an unrelated branch.

1. **Branch Naming**:
   - `feat/<issue-id>-<short-description>`
   - `fix/<issue-id>-<short-description>`
   - `chore/<issue-id>-<short-description>`
   - `refactor/<issue-id>-<short-description>`
2. **Branch Creation Gate**:
   - NEVER create or checkout a branch automatically.
   - Propose the branch name and **wait for explicit user confirmation** before running `git checkout -b <branch>` or creating a worktree.
3. **Isolation Strategy**:
   - **Default (Standard Branch Isolation)**: `git checkout -b <branch>`. Keeps the workspace root aligned with the active OpenCode session, preserves existing dependency caches (`node_modules/`, virtualenvs), and avoids cleanup overhead.
   - **Opt-in (Worktree Isolation)**: `git worktree add .worktrees/<branch> -b <branch>`. Intended for concurrent sessions or complete filesystem isolation. Follows the standard directory convention `.worktrees/<branch>`.
4. **Issue Status Transition**:

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
4. **Minimalist Engineering Discipline (6-Step Reuse Ladder)**:
   - Follow `minimalist-engineering.md` before writing code: (1) Does it need to exist? (2) Already in codebase?
     (3) Standard library / native platform feature? (4) Already installed dependency? (5) Readable 1-liner?
     (6) Minimum working code.
   - Maintain caller-aware changes: inspect direct callers, callees, and adjacent consumers before altering contracts.
   - Never compromise trust-boundary validation, data loss error handling, security, or accessibility.
   - Document deliberate limits using structured comments: `// shortcut: <limit>, <upgrade trigger>` (flag `no-trigger` as rot).
5. **Testing Discipline & Code Quality**:
   - Write targeted tests for non-trivial/risky logic (branches, loops, edge-case parsers, state machines, security, transactions).
   - Avoid tests for trivial glue code.
   - Format modified code using standard tasks (`rtk mise run format` or repository formatter).
6. **Implementation Disclosure & Terse Output**:
   - Conclude implementation replies with a 1–2 line summary of what was intentionally deferred and residual risk.
   - Adopt terse communication: answer first (`[thing] [action] [reason]`), drop conversational filler, preserve payloads and negations verbatim, and revert to full prose for security, irreversible actions, or clarifications.
7. **No Direct Commits**:
   - Do NOT commit directly during development. Hand off to Stage 4 (`/sdlc-3-review`).

---

## Stage 4: Local Code Review & Pre-Commit Verification Gate

- **Slash Command**: `/sdlc-3-review [target-or-path]`
- **Dedicated Agent**: `sdlc-review`
- **Permissions**: `edit: deny`, scoped verification `shell` (test/lint/check tools, read-only git, issue inspection), `subagent: deny`, `external_directory: deny`

Before any commit is proposed:

1. **Target & Scope Resolution**:
   - By default, inspect all uncommitted working tree changes (`rtk git diff HEAD`).
   - When run with an argument (`[target-or-path]`), inspect the specified directory, file, or git ref/range (`rtk git diff HEAD -- <path>` or `rtk git diff <ref>`).
2. **Run Quality Verification Suite (Fail-Fast)**:
   - **Standardized Task Runner Interface**: Prioritize `rtk mise run verify` to execute all verification checks in one
     step (or individual tasks `rtk mise run lint` and `rtk mise run format:check`).
   - **Fallback**: If no `mise` tasks are configured, run all quality commands specified in `AGENTS.md` under `## Quality Commands`.
   - All checks must pass with zero errors. If checks fail, stop early.
3. **Caller-Aware Code Review**:
   - Inspect changes using the `code-review` skill and `minimalist-engineering.md` standards.
   - Trace callers, callees, and contract blast radius using `rtk rg`.
   - Evaluate against the 6-step reuse ladder, safety floor, risky-path test coverage, and `shortcut:` convention upgrade triggers.
   - Classify findings into three strict tiers: `[Must fix]`, `[Should fix]`, and `[Nice to have]`.
   - Output summary metrics (`Files Inspected`, `Diff Volume`, `Lean Potential`) and verdict (`Ready to Ship` | `Revisions Required` | `Blocked`).
4. **Decision Gate & Pre-Commit Approval Rule (MANDATORY)**:
   - If `Must fix` or `Should fix` findings exist, verdict is `Revisions Required` and commit proposal is blocked.
   - **Bypass Exception**: The developer may explicitly bypass blocking findings by providing a stated technical rationale, which must be documented in the review summary.
   - If verdict is `Ready to Ship` (or explicitly bypassed) and uncommitted changes exist:
     - Present `git status` with the list of changed files.
     - Propose a Conventional Commit message (`feat: ...`, `fix: ...`, `chore: ...`, `refactor: ...`, `test: ...`).
     - **Wait for explicit user approval** before running `git commit`.
     - **Authorship and Attribution (ALL HARNESSes)**: Do NOT add `Co-authored-by` or any other
       authorship/attribution trailer naming an AI assistant, model, or harness unless the user explicitly
       requests it. This applies across all harnesses and commit workflows, including amend/rebase
       operations; never add such trailers by default.

---

## Stage 5: Pull Request & Merge Gate

- **Slash Commands**: `/sdlc-4-pr [issue-id]`, `/sdlc-5-review-pr [pr-id]`
- **Dedicated Agent**: `sdlc-pr-review`
- **Permissions**: `edit: allow` (scoped to review fixes), `shell: gh pr *, rtk gh pr *, gh repo view *, rtk gh repo view *, gh issue *, rtk gh issue *, gh pr merge *: deny, rtk gh pr merge *: deny, gh api *, rtk gh api *, git push *`, `subagent: deny`, `external_directory: deny`

1. **Push Branch**:

   ```bash
   git push -u origin HEAD
   ```

2. **Create Pull Request**:
   - Check for `.github/PULL_REQUEST_TEMPLATE.md`.
   - Reference the issue (`Closes #<id>`).
   - Return PR URL.
3. **CI Verification**:
   - Inspect status: `rtk gh pr checks` and `rtk gh pr status` (or `rtk gh repo view` for repo inspection).
4. **PR Review Feedback Loop**:
   - Load `review-pr` skill.
   - Fetch review threads via GraphQL.
   - **Triage Assessment & User Confirmation**: Explain triage classification (Legitimate vs Non-Applicable),
     rationale, and proposed actions to the user; await explicit human confirmation before modifying code or taking
     action.
   - **Execute Legitimate**: Fix code/test, run verify, commit with approval, push, react 👍, reply via stdin heredoc,
     resolve thread.
   - **Execute Non-Applicable**: No code change, react 👎, reply with technical rationale via stdin heredoc, resolve
     thread.
5. **Merge Gate**:
   - **NEVER** run `gh pr merge`.
   - Merging is strictly reserved for human manual action once all checks and threads are resolved.
6. **Worktree Cleanup (Opt-in Workflow)**:
   - If worktree isolation was used, remove the worktree directory once the branch is merged:

     ```bash
     git worktree remove .worktrees/<branch>
     git worktree prune
     ```

---

## Dedicated SDLC Commands & Subagents Reference

| Slash Command            | Stage       | Agent            | File Permissions | Primary Purpose                                                                          |
| ------------------------ | ----------- | ---------------- | ---------------- | ---------------------------------------------------------------------------------------- |
| `/sdlc-1-refine <id>`    | Stage 1     | `sdlc-refine`    | `edit: deny`     | Refine issue into English with 3 mandatory sections.                                     |
| `/sdlc-2-develop <id>`   | Stage 2 & 3 | `sdlc-develop`   | `edit: allow`    | Confirm branch, set In progress label, guide implementation via `AGENTS.md`.             |
| `/sdlc-3-review [path]`   | Stage 4     | `sdlc-review`    | `edit: deny`     | Quality suite (mise verify), caller-aware review (3 tiers), propose commit. |
| `/sdlc-4-pr [id]`        | Stage 5     | `sdlc-pr-review` | `edit: allow`    | Push branch, create PR with template, inspect CI.                                        |
| `/sdlc-5-review-pr [id]` | Stage 5     | `sdlc-pr-review` | `edit: allow`    | Fetch threads via GraphQL, explain triage & confirm, fix, reply, and resolve.           |
