---
description: Scan repository comments for shortcut markers to produce a structured debt ledger and flag rot warnings
argument-hint: '[path]'
---

# Technical Debt Command

Execute a technical debt and shortcut audit adhering to the `tech-debt` skill and `minimalist-engineering.md` rules.

## Target & Scope

Target: $ARGUMENTS

1. **Scope Selection**:
   - If `$ARGUMENTS` is provided, limit the scan to that file or directory.
   - If `$ARGUMENTS` is empty, scan the entire repository.

2. **Debt Scan Protocol**:
   - Scan for structured shortcuts:
     ```bash
     rtk rg -i "shortcut:\s*(.+)" ${ARGUMENTS:-.}
     ```
   - Scan for unstructured TODO / FIXME / HACK comments:
     ```bash
     rtk rg -i "\b(TODO|FIXME|HACK|XXX):" ${ARGUMENTS:-.}
     ```

3. **Report Output**:
   - Render the structured technical debt ledger table (`<file>:<line>`, limit, upgrade trigger, status, risk).
   - Detail any `Rot Warning (no-trigger)` or stale shortcuts.
   - Summarize unmanaged comments and recommend remediations.
