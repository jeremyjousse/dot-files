---
description: Inspect git diff with caller-aware analysis and output lean, prioritized review findings
argument-hint: '[ref-or-branch]'
---

# Code Review Command

Execute a caller-aware, minimalist code review adhering to the `code-review` skill and `minimalist-engineering.md` rules.

## Target & Scope

Target: $ARGUMENTS

1. **Identify Target Diff**:
   - If `$ARGUMENTS` is provided (e.g. `main`, `origin/main`, `HEAD~1`, `<commit-sha>`), inspect changes between that ref and HEAD:

     ```bash
     rtk git diff $ARGUMENTS...HEAD
     ```

   - If `$ARGUMENTS` is empty, inspect uncommitted changes (both staged and unstaged):

     ```bash
     rtk git diff HEAD
     ```

   - If working tree is clean and no ref provided, inspect the latest commit:

     ```bash
     rtk git show HEAD
     ```

2. **Execute Caller-Aware Review**:
   - Trace callers and dependents of modified functions or contracts (`rtk rg`).
   - Group findings strictly into `Must fix`, `Should fix`, and `Nice to have`.
   - Adhere to the standard finding structure (`What this is`, `Problem`, `Fix`, `If we skip it`, `Lean: -N lines possible`).
   - Conclude with review metrics and verdict.
