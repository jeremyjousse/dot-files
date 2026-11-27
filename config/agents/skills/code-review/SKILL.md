---
name: code-review
description: Inspect git diff with caller-aware analysis, run quality verification, output tiered findings, and prepare commit approval.
---

# Code Review & Verification Skill

This skill performs Stage 4 pre-commit verification and caller-aware code review on working tree diffs, paths, commits, or branches.

---

## 1. Target & Diff Resolution

Resolve the diff from the provided target (or default to the working tree):

- **Path (Directory or File)**: `rtk git diff HEAD -- "<target>"`
- **Git Ref or Range** (e.g. `main...HEAD`, `HEAD~1`, `<sha>`): `rtk git diff <target>`
- **Default (No Target)**:
  - Inspect all uncommitted staged and unstaged changes: `rtk git diff HEAD`
  - If the working tree is completely clean, inspect the latest commit: `rtk git show HEAD`

---

## 2. Automated Quality Checks (Fail-Fast)

Run the project verification suite using `rtk` before reviewing code. Stop early if compilation, linting, formatting, or tests fail:

1. **Standardized Task Runner**: Prioritize `mise` tasks:
   ```bash
   rtk mise run verify
   ```
   Or isolate failures with `rtk mise run lint` and `rtk mise run format:check`.
2. **Fallback to `AGENTS.md`**: If no `mise` verification task exists, run all quality commands defined under `## Quality Commands` in `AGENTS.md`.

---

## 3. Caller-Aware Code Review

1. **Blast Radius Analysis**:
   - Never review diffs in isolation.
   - Trace callers and callers of callers using `rtk rg` or language symbols.
   - Inspect callees, imported modules, and adjacent interfaces for contract breaks, type mismatches, or missing edge-case handling.
2. **Minimalist Quality Standard**:
   - Evaluate against the 6-step reuse ladder: Can new code be eliminated, composed with standard library features, or replaced with a 1-liner?
   - Verify safety floor: Ensure trust-boundary validation, error handling, security, and accessibility are not weakened.
   - Verify test relevance: Ensure non-trivial risky logic (branches, loops, parsers, state machines, transactions) is covered by targeted tests while honoring any `AGENTS.md` testing exemptions.
   - Check `shortcut:` conventions: Verify any deliberate compromises have concrete upgrade triggers.

---

## 4. Output Format

Organize all review findings into three strict tiers:

### 1. Must Fix (Bugs, security risks, data loss, broken contracts)
*(If none found, explicitly state "None")*

### 2. Should Fix (Caller breakage, performance cliffs, missing risky-path tests, unhandled errors)
*(If none found, explicitly state "None")*

### 3. Nice to Have (Simplification, dead code removal, readability)
*(If none found, explicitly state "None")*

### Finding Structure

Every finding MUST follow this exact schema:

```markdown
### [<Tier>] <Finding Title> (`<file>:<line>`)

- **What this is**: Concise description of the changed or introduced behavior.
- **Problem**: Technical explanation of why this fails, degrades, or introduces risk.
- **Fix**: Concrete code or architecture change to resolve the issue.
- **If we skip it**: Exact operational failure, regression, or maintenance cost if left unfixed.
- **Lean**: `-N lines possible` (or `N/A - line neutral`).
```

### Review Summary

End the review with a concise metrics block:

```markdown
### Summary
- **Target**: <Scope or ref inspected>
- **Files Inspected**: <count>
- **Diff Volume**: +<additions> / -<deletions>
- **Lean Potential**: -<lines> total possible line reduction
- **Verdict**: <Ready to Ship | Revisions Required | Blocked>
```

---

## 5. Decision Gate & Pre-Commit Protocol

1. **Evaluate Verdict**:
   - If `Must fix` or `Should fix` findings exist, verdict is `Revisions Required` (or `Blocked`). Do NOT propose a commit.
   - **Bypass Exception**: If the developer explicitly requests a bypass with a stated technical rationale, record it in the summary (`Ready to Ship (Bypassed: <rationale>)`) and proceed.
   - If only `Nice to have` findings exist (or clean), verdict is `Ready to Ship`.
2. **Pre-Commit Gate**:
   - Run `rtk git status` to inspect changed files.
   - If the working tree is clean (ad-hoc review of a commit/ref), conclude here.
   - If uncommitted changes exist and verdict is `Ready to Ship` (or bypassed):
     1. List modified, untracked, and deleted files.
     2. Propose a Conventional Commit message (`feat`, `fix`, `chore`, `refactor`, `test`) without any AI `Co-authored-by` trailer unless explicitly requested.
     3. **STOP AND WAIT** for explicit user approval before running `git commit`.
