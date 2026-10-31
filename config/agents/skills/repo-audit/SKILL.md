---
name: repo-audit
description: Map repository entry points, data flows, and expected load to output a ranked report of bugs, untested risky paths, and dead or duplicate abstractions.
---

# Repository Audit Skill

This skill performs a systematic architectural audit and risk assessment across a repository or bounded subsystem.

---

## Audit Methodology

1. **Architecture & Topology Mapping**:
   - Identify system entry points: CLI commands, HTTP handlers, background workers, IPC boundaries, or configuration hooks.
   - Trace core data flows from ingest to persistence or external consumption.
   - Identify expected operational load and concurrency characteristics.

2. **Risky Logic Discovery**:
   - Search for high-risk constructs requiring targeted test coverage:
     - Complex branching, nested conditionals, and boundary conditions.
     - State machines, lifecycle hooks, and asynchronous race points.
     - Custom parsers, schema validators, serializers, and regexes.
     - Security-critical logic (authentication, token parsing, privilege escalation).
     - Financial calculations or critical data mutations.
   - Assess test coverage specifically across these risky paths.

3. **Dead Code & Duplication Detection**:
   - Locate unused exports, orphaned files, duplicate utility helpers, or obsolete adapters.
   - Identify over-engineered layers or premature abstractions that can be collapsed into standard library calls or readable 1-liners.

---

## Output Format

The audit report MUST include the following sections:

### 1. System Map & Entry Points
- **Entry Points**: Key ingress points mapped to their handlers.
- **Data Pipelines**: High-level ingest -> transform -> persist/egress flows.
- **Load Profile**: Operational scale, concurrency model, and bottleneck areas.

### 2. Ranked Findings Report

#### Tier 1: Critical Bugs & Latent Risks
- Real or potential runtime crashes, data corruption, uncaught exceptions, security vulnerabilities.

#### Tier 2: Untested Risky Execution Paths
- Complex paths lacking targeted unit/integration tests with concrete failure scenarios.

#### Tier 3: Dead & Duplicate Abstractions
- Unused code, duplicate helpers, or single-use abstractions that should be deleted or merged. Include estimated line reductions (`-N lines`).

#### Tier 4: Lean / Minimalism Opportunities
- Over-engineered abstractions that can be replaced with standard library features, existing dependencies, or direct compositions.

---

## Finding Schema

Each finding in Tiers 1-4 should follow this schema:

```markdown
- **Item**: `<title>` (`<file>:<line>`)
  - **Risk / Waste**: What makes this dangerous or unnecessary.
  - **Remediation**: Concrete refactoring, deletion, or test to add.
  - **Lean Impact**: `-N lines` or `+N targeted test lines`.
```

---

## Prioritized Action Plan

Conclude with a prioritized checklist of immediate actions:
- [ ] 1. <Highest-priority remediation>
- [ ] 2. <Next remediation>
- [ ] 3. <Cleanup / deletion>
