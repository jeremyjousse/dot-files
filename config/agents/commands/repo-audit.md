---
description: Map repository entry points, data flows, and expected load to output a ranked audit report
argument-hint: '[subpath-or-scope]'
---

# Repository Audit Command

Execute an architectural, risk, and minimalism audit adhering to the `repo-audit` skill and `minimalist-engineering.md` rules.

## Target & Scope

Target: $ARGUMENTS

1. **Scope Selection**:
   - If `$ARGUMENTS` is provided, limit the audit analysis to the specified directory, module, or package.
   - If `$ARGUMENTS` is empty, perform a holistic audit of the repository root.

2. **Audit Execution**:
   - Map key entry points, data flows, and concurrency/load characteristics.
   - Scan for untested risky logic, complex branches, and unhandled failure modes.
   - Locate dead code, redundant helpers, and over-engineered abstractions.
   - Output structured findings across all 4 tiers with line impact estimates and an action checklist.
