---
description: Inspect, upgrade, adapt, and verify project dependencies across ecosystems
---

# Dependency Update Workflow

You are executing the standardized dependency update protocol. You must strictly adhere to the instructions and
guardrails defined in the `update-dependencies` skill.

## Target & Scope

Target: $ARGUMENTS

- If `$ARGUMENTS` specifies an ecosystem (e.g. `pnpm`, `node`, `rust`, `swift`, `python`) or a specific package name,
  limit operations to that scope.
- If `$ARGUMENTS` is empty, inspect and manage dependencies across all detected ecosystems in the repository.

---

## Execution Protocol

### 1. Establish Clean Baseline (Prerequisite)

Before modifying any files or running package managers:

1. Run `git status --porcelain`.
2. If uncommitted changes exist:
   - **STOP IMMEDIATELY**.
   - Inform the user that a clean baseline is required for safe rollback.
   - Offer to stash the changes (`git stash push -u -m "pre-dependency-update"`).
   - Do NOT proceed until the working directory is clean.

### 2. Ecosystem Detection

Inspect the repository root and subdirectories to identify active ecosystems:

- **Node / TypeScript**: `package.json`, `pnpm-lock.yaml` -> use **`pnpm`**.
- **Rust**: `Cargo.toml`, `Cargo.lock` -> use **`cargo`**.
- **Swift / Apple Platforms**: `Package.swift`, `Package.resolved`, `project.yml` -> use **`swift`** / **XcodeGen**.
- **Python**: `pyproject.toml`, `uv.lock` -> use **`uv`**.

If multiple ecosystems are detected (e.g. Tauri apps, Fullstack services), follow the **Sequential Phased Execution
Protocol** from the `update-dependencies` skill:
1. Systems / Backend core first (`cargo` / `uv`).
2. Schema & IPC synchronization gate (e.g. `rtk mise run generate`).
3. Frontend / UI client second (`pnpm` / `swift`).
4. Full cross-ecosystem verification.

### 3. Safe Upgrades (Minor & Patch)

1. Inspect available updates:
   - Node: `rtk pnpm outdated`
   - Rust: `rtk cargo update --dry-run`
   - Swift: `swift package show-dependencies`
   - Python: `uv lock --upgrade` (dry run / inspect)
2. Apply SemVer-compatible minor and patch updates:
   - Node: `pnpm update`
   - Rust: `cargo update`
   - Swift: `swift package update`
   - Python: `uv lock --upgrade && uv sync`
3. Run the verification suite immediately:
   - Prefer `rtk mise run verify` if available, or ecosystem-specific lint and test suites.
4. **Rollback on Failure**: If any check fails and cannot be quickly fixed, immediately revert modified lockfiles/manifests
   back to the clean baseline.

### 4. Major Upgrades (Strictly One at a Time)

For each breaking/major upgrade:

1. **Isolate**: Upgrade strictly **one dependency at a time**. Never batch multiple breaking changes.
2. **Review Changelog**: Check official release notes for breaking changes and deprecations.
3. **Upgrade Dependency**:
   - Node: `pnpm update <package>@latest`
   - Rust: update root `[workspace.dependencies]` or crate `Cargo.toml`, then `cargo update -p <crate>`
   - Swift: update version requirement in `Package.swift` (or `project.yml`), resolve dependencies
   - Python: `uv add <package>@latest` (or `uv add --dev <package>@latest`)
4. **Project Synchronization Gate**:
   - If using XcodeGen or code generation, run `rtk mise run generate` whenever manifests or schemas change.
5. **Adapt Codebase**:
   - Update deprecated APIs, types, and configurations in the codebase.
   - For React: ensure `react`, `react-dom`, `@types/react`, and `@types/react-dom` stay synchronized.
   - For Svelte: ensure `@sveltejs/kit`, adapters, and vite plugins stay aligned.
   - For Swift: ensure compliance with Swift 6 / strict concurrency checks.
6. **Verify**:
   - Run `rtk mise run verify` or the project test/lint suite.
7. **Rollback on Failure**:
   - If verification fails and cannot be cleanly resolved, run `git restore . && git clean -fd`.

### 5. Pre-Commit Approval Gate (Stage 4)

1. Run `rtk git status` (or `git status`).
2. Present a clear summary of all updated dependencies and changed files.
3. Propose Conventional Commit message(s), for example:
   - `chore(deps): update pnpm dependencies (minor & patch)`
   - `chore(deps): bump <package> from <v1> to <v2>`
4. **STOP AND WAIT**: Await explicit user confirmation before executing `git commit`. Never commit automatically.
