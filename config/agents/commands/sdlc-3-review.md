---
description: Stage 4 Code Review & Verification Gate - Caller-aware review, quality suite, and commit approval
argument-hint: '[target-or-path]'
agent: sdlc-review
---

# Stage 4: Local Code Review & Pre-Commit Verification Gate

You are executing **Stage 4 (Local Code Review & Pre-Commit Verification Gate)** of the SDLC.
This command can also be used ad-hoc outside the SDLC lifecycle by specifying an argument (`$ARGUMENTS`: folder, file, branch, or ref).

## Operational Boundaries

- **Strictly No Direct Commits**: You must NEVER commit code without explicit human confirmation.
- **Strictly No Code Edits**: The review agent does not edit code (`edit: deny`). If checks or review criteria fail, report the exact issues back to the user or development agent.

## Execution Flow

### 1. Target & Diff Resolution

Resolve the target diff based on `$ARGUMENTS`:

1. **Ad-hoc / Targeted Mode (Argument Provided)**:
   - **Path (Directory or File)**: If `$ARGUMENTS` points to an existing file or directory, inspect uncommitted changes within that scope:
     ```bash
     rtk git diff HEAD -- "$ARGUMENTS"
     ```
   - **Git Ref or Range**: If `$ARGUMENTS` is a git ref or range (e.g. `main...HEAD`, `HEAD~1`, `<commit-sha>`):
     ```bash
     rtk git diff $ARGUMENTS
     ```
2. **Default SDLC Mode (No Argument)**:
   - Inspect all uncommitted staged and unstaged changes against HEAD:
     ```bash
     rtk git diff HEAD
     ```
   - If the working tree is completely clean and no argument was provided, inspect the latest commit:
     ```bash
     rtk git show HEAD
     ```

### 2. Run Automated Quality Checks (Fail-Fast)

Execute the project verification suite using `rtk` before reviewing code. If compilation, linting, or formatting fails, stop early to avoid reviewing broken code:

1. **Standardized Task Runner Check**: Prioritize running `mise` tasks:
   ```bash
   rtk mise run verify
   ```
   Or run granular checks when isolating failures:
   ```bash
   rtk mise run lint
   rtk mise run format:check
   ```
2. **Fallback to Project Commands**: If no `mise` verification tasks exist, run all quality commands specified in `AGENTS.md` under `## Quality Commands` (typecheck, lint, build, test).

If any automated check fails, report the failure details and stop.

### 3. Caller-Aware Code Review

Apply the methodology defined in the `code-review` skill (`config/agents/skills/code-review/SKILL.md`) and `minimalist-engineering.md`:

1. **Caller-Aware Blast Radius Analysis**:
   - Do not review the diff in isolation.
   - Trace callers and dependents of modified functions, interfaces, or types using `rtk rg`.
   - Inspect callees, imported modules, and adjacent contracts to detect subtle breakages or unhandled edge cases.
2. **Minimalist Quality Standard**:
   - Evaluate against the 6-step reuse ladder: Can new code be eliminated, composed with standard library features, or replaced with a readable one-liner?
   - Verify safety floor: Ensure trust-boundary validation, data loss prevention, security, and accessibility are never compromised.
   - Verify test relevance: Ensure non-trivial risky logic (branches, loops, parsers, state machines, transactions) is covered by targeted tests, while avoiding tests for trivial glue code.
   - Audit `shortcut:` conventions: Verify every deliberate compromise has a concrete upgrade trigger (flag `no-trigger` as rot).
3. **Structured Review Findings**:
   Organize all review findings into three strict tiers:
   - **### [Must fix] <Title> (`<file>:<line>`)**: Bugs, security risks, data loss, broken contracts.
   - **### [Should fix] <Title> (`<file>:<line>`)**: Caller breakage, performance cliffs, missing risky-path tests, unhandled errors.
   - **### [Nice to have] <Title> (`<file>:<line>`)**: Simplification, dead code removal, readability improvements.
   *(If none found in a tier, explicitly output "None")*

   Each finding MUST follow this schema:
   - **What this is**: Concise description of the changed or introduced behavior.
   - **Problem**: Technical explanation of why this fails, degrades, or introduces risk.
   - **Fix**: Concrete code or architecture change to resolve the issue.
   - **If we skip it**: Exact operational failure, regression, or maintenance cost if left unfixed.
   - **Lean**: `-N lines possible` (or `N/A - line neutral`).

4. **Review Metrics & Verdict**:
   Output the summary metrics block:
   ```markdown
   ### Summary
   - **Target**: <Scope or ref inspected>
   - **Files Inspected**: <count>
   - **Diff Volume**: +<additions> / -<deletions>
   - **Lean Potential**: -<lines> total possible line reduction
   - **Verdict**: <Ready to Ship | Revisions Required | Blocked>
   ```

### 4. Decision Gate & Pre-Commit Protocol

1. **Evaluate Verdict**:
   - If **Must fix** or **Should fix** findings exist:
     - The default verdict is **Revisions Required** (or **Blocked**).
     - **DO NOT** propose a commit. Report the corrective actions back to the user/developer.
     - **Bypass Exception**: If the developer explicitly requests to bypass with a stated technical rationale, record the bypass in the summary (e.g. `Verdict: Ready to Ship (Bypassed: <rationale>)`) and proceed to the commit protocol.
   - If only **Nice to have** findings exist (or clean):
     - Verdict is **Ready to Ship**.
2. **Pre-Commit Gate (If Uncommitted Changes Exist)**:
   - Run `rtk git status` (or `git status`) to inspect all changed files.
   - If the working tree is clean (e.g. ad-hoc review of an existing commit or remote branch), conclude the review here.
   - If uncommitted changes exist and the verdict is **Ready to Ship** (or explicitly bypassed):
     1. Present the list of modified, untracked, and deleted files.
     2. Propose a Conventional Commit message adhering to standard types:
        - `feat(<scope>): <description>` (new capability)
        - `fix(<scope>): <description>` (bug fix)
        - `chore(<scope>): <description>` (tooling, configuration, or dependency updates)
        - `refactor(<scope>): <description>` (code restructuring)
        - `test(<scope>): <description>` (tests only)
     3. **STOP AND WAIT**: Ask the user for explicit confirmation before executing `git commit`. Never commit directly.
