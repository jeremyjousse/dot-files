---
name: tech-debt
description: Scan repository comments for shortcut markers to produce a structured debt ledger and flag unmanaged debt or rot warnings.
---

# Technical Debt Skill

This skill scans a codebase to discover, inventory, and assess intentional technical shortcuts and technical debt.

---

## Debt Discovery Protocol

1. **Structured Shortcut Scan**:
   - Search the repository for structured shortcut annotations using `rtk rg`:
     - Pattern: `shortcut:\s*(.+)`
   - Capture:
     - File path and line number (`<file>:<line>`)
     - Stated limit / ceiling
     - Explicit upgrade trigger

2. **Rot Warning Assessment**:
   - Flag any `shortcut:` marker lacking an explicit upgrade trigger as **`Rot Warning (no-trigger)`**.
   - Flag any `shortcut:` marker where the trigger condition has already been met or exceeded.
   - Flag vague triggers (e.g., "upgrade later", "fix soon", "TODO") as **`Rot Warning (vague)`**.

3. **Unmanaged Debt Audit**:
   - Optionally scan for unstructured comments: `TODO:`, `FIXME:`, `HACK:`, `XXX:`.
   - Distinguish actionable deferred items from obsolete or rotting comments.

---

## Output Format

### 1. Structured Technical Debt Ledger

Present all structured shortcuts in a Markdown table:

| Location | Limit / Ceiling | Upgrade Trigger | Status | Risk Level |
| :--- | :--- | :--- | :--- | :--- |
| `src/auth.ts:42` | In-memory token store | User base > 10,000 | Active | Low |
| `lib/sync.sh:88` | Synchronous loop | `no-trigger` | **Rot Warning** | High |

### 2. Rot Warnings & Urgent Debt

Detail any shortcuts flagged with rot warnings:

```markdown
#### [Rot Warning] <Issue Title> (`<file>:<line>`)
- **Limit**: <Described ceiling or shortcut>
- **Problem**: Missing explicit upgrade trigger or condition already exceeded.
- **Remediation**: Either formalize with a measurable trigger (`shortcut: <limit>, <upgrade trigger>`) or implement the full solution.
```

### 3. Unmanaged Debt Overview (TODO / FIXME / HACK)
- Total unstructured comments found.
- Top candidate items to formalize into `shortcut:` markers, convert into GitHub issues, or delete.

### 4. Debt Health Score & Recommendations
- **Debt Health**: `<Healthy | Needs Maintenance | Critical Rot>`
- **Total Debt Items**: `<count>`
- **Rot Count**: `<count>`
- **Immediate Recommended Actions**: Prioritized steps to address high-risk debt.
