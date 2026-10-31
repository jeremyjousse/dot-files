---
name: code-review
description: Inspect git diff with caller-aware analysis and output lean, prioritized findings (Must fix, Should fix, Nice to have).
---

# Code Review Skill

This skill performs a rigorous, minimalist, caller-aware code review on working tree diffs, commits, or pull requests.

---

## Review Methodology

1. **Diff Inspection**:
   - Inspect the target diff using `rtk git diff` (or compare against a target branch/commit, e.g. `main`).
   - If no specific ref is provided, inspect unstaged and staged changes in the working tree.

2. **Caller-Aware Blast Radius Analysis**:
   - Do not review diffs in isolation.
   - Trace callers and callers of callers using `rtk rg` or language symbols.
   - Inspect callees, imported modules, and adjacent interfaces to detect subtle contract breaks, type mismatches, or missing edge-case handling.

3. **Minimalist Quality Standard**:
   - Evaluate against the 6-step reuse ladder: Can new code be eliminated, composed with standard library features, or replaced with a 1-liner?
   - Verify safety floor: Ensure trust-boundary validation, error handling, security, and accessibility are not weakened.
   - Verify test relevance: Ensure non-trivial risky logic (branches, loops, parsers, state machines, transactions) is covered by targeted tests, while avoiding tests for trivial glue code.
   - Check `shortcut:` conventions: Verify any deliberate compromises have concrete upgrade triggers.

---

## Output Format

Organize all review findings into three strict tiers:

### 1. Must Fix (Bugs, security risks, data loss, broken contracts)
*(If none found, explicitly state "None")*

### 2. Should Fix (Caller breakage, performance cliffs, missing risky-path tests, unhandled errors)
*(If none found, explicitly state "None")*

### 3. Nice to Have (Simplification, dead code removal, readability)
*(If none found, explicitly state "None")*

---

## Finding Structure

Every finding MUST follow this exact schema:

```markdown
### [<Tier>] <Finding Title> (`<file>:<line>`)

- **What this is**: Concise description of the changed or introduced behavior.
- **Problem**: Technical explanation of why this fails, degrades, or introduces risk.
- **Fix**: Concrete code or architecture change to resolve the issue.
- **If we skip it**: Exact operational failure, regression, or maintenance cost if left unfixed.
- **Lean**: `-N lines possible` (or `N/A - line neutral`).
```

---

## Review Summary

End the review with a concise metrics block:

```markdown
### Summary
- **Files Inspected**: <count>
- **Diff Volume**: +<additions> / -<deletions>
- **Lean Potential**: -<lines> total possible line reduction
- **Verdict**: <Ready to Ship | Revisions Required | Blocked>
```
