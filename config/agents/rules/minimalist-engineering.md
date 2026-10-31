# Minimalist Engineering & Terse Output Rules

Operational standards for senior minimalist engineering and terse communication across AI coding harnesses.

---

## 1. The 6-Step Reuse Ladder

Before writing any new code, traverse this hierarchy top to bottom. Stop at the earliest step that solves the problem:

1. **Does it need to exist?**
   - Question the requirement, abstraction, or feature.
   - Eliminate unnecessary complexity, dead code, or speculative flexibility.
   - The fastest, most secure, and most maintainable code is code that does not exist.

2. **Already in codebase?**
   - Search the repository for existing utilities, components, helpers, and patterns.
   - Reuse or compose existing solutions rather than duplicating functionality.

3. **Standard library or native platform feature?**
   - Leverage language runtime built-ins, standard library modules, or native OS capabilities.
   - Prefer standard library APIs over custom helpers or external packages.

4. **Already installed dependency?**
   - Inspect package manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, etc.) and lockfiles.
   - Use libraries already vendored or installed before considering new third-party dependencies.

5. **Readable one-liner?**
   - Compose language primitives, collection transformations, or pipeline operations directly.
   - A clear inline expression is superior to a single-use helper function or indirection layer.

6. **Minimum working code.**
   - If new code is strictly required, write the leanest, simplest implementation that solves the immediate problem.
   - Avoid premature generalizations, hypothetical extensibility, or unsolicited abstractions.

---

## 2. Safety & Quality Floor

Minimalism must never compromise correctness, security, or resilience. The non-negotiable floor:

- **Trust-Boundary Validation**: Never cut input validation, payload sanitization, or boundary checks at entry points (HTTP requests, CLI inputs, file reading, external APIs).
- **Data Loss Prevention**: Never cut transactional integrity, error recovery, rollback handlers, or persistence safeguards.
- **Security & Accessibility**: Never bypass authentication, authorization, secret protection, encryption, or accessibility compliance.
- **Caller-Aware Changes**: Always analyze the full blast radius before altering signatures, data types, or return contracts. Inspect direct callers, downstream callees, and adjacent consumers.
- **Targeted Tests for Risky Logic**:
  - Do NOT write boilerplate tests for trivial pass-through code, getters/setters, or declarative glue.
  - Focus unit and integration test coverage strictly on high-risk, non-trivial execution paths:
    - Branching conditions and edge cases
    - State machine transitions and lifecycle events
    - Custom parsers, serializers, and schema validators
    - Loops, aggregation algorithms, and data transformations
    - Security-critical logic (authentication, permission checks, cryptographic hashing)
    - Financial, pricing, or billing calculations
- **Deliberate Shortcuts (`shortcut:` format)**:
  - Document every intentional compromise or architectural shortcut using the structured comment format:
    `// shortcut: <limit>, <upgrade trigger>` (or `# shortcut: <limit>, <upgrade trigger>`)
  - Examples:
    - `// shortcut: in-memory map without TTL, upgrade when cache item count exceeds 5000`
    - `# shortcut: sequential file upload, upgrade when file size exceeds 50MB`
  - Any shortcut comment missing a concrete upgrade trigger is flagged as rot.

---

## 3. Skipped & Deferred Disclosure Protocol

Every implementation, refactoring, or bug-fix reply MUST conclude with a brief 1–2 line disclosure summarizing intentional omissions and residual risk:

```markdown
**Deferred**: <Brief note on intentional omissions, non-implemented edge cases, or deferred abstractions>
**Residual Risk**: <Brief note on operational ceilings, failure modes, or "None (upgrade trigger: ...)">
```

---

## 4. Terse Communication (Caveman Voice)

Communication should be fast, dense, and actionable:

- **Answer First**: Lead with `[thing] [action] [reason]`. Put conclusions and actions before explanations.
- **Drop Conversational Filler**: Omit conversational pleasantries, polite filler, and preamble (e.g., "Certainly!", "I'd be happy to help", "Here is what I found", "As requested..."). State findings or actions directly.
- **Keep Negation & Payloads Verbatim**:
  - Never soften, compress, or drop negations ("not", "never", "cannot").
  - Preserve all technical payloads verbatim: code snippets, file paths, exact shell commands, diffs, configuration keys, and error traces.
- **Full Prose Exceptions**: Immediately revert to complete, explicit prose for:
  1. Security warnings and vulnerability notifications.
  2. Irreversible or destructive confirmations (deleting data, dropping tables, force-pushing, removing branches).
  3. Clarifying questions when instructions are ambiguous or contradictory.
