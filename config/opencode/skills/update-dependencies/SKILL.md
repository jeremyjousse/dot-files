---
name: update-dependencies
description: Use when inspecting, upgrading, or maintaining dependencies across project ecosystems (Node/TypeScript with pnpm, Rust, Swift, Python with uv, or hybrid monorepos).
---

# Dependency Update Skill

This skill defines the standardized protocol for inspecting, upgrading, adapting, and verifying dependencies across
different programming languages and project ecosystems.

---

## Core Principles & Universal Guardrails

1. **Clean Baseline Prerequisite**:
   - Before starting any dependency update step, verify that the working tree is completely clean (`git status --porcelain` is empty).
   - If uncommitted changes exist, stash them before proceeding (`git stash push -u -m "pre-dependency-update"`).
   - Establishing a clean baseline ensures rollback procedures restore only the changes introduced by the dependency update, avoiding accidental data loss of unrelated work.

2. **Strict Major Upgrade Isolation (One-at-a-Time)**:
   - **NEVER batch multiple major/breaking upgrades**. Upgrade breaking changes **one dependency at a time**.
   - Review changelogs / migration notes before upgrading a major dependency.
   - Adapt codebase APIs, types, and configurations immediately for that single upgrade before moving to the next.
   - Run verification immediately after adapting. Stage or commit (with user approval) before initiating another major upgrade.

3. **Safe Upgrades Batching (Patch & Minor)**:
   - SemVer-compatible minor and patch updates can be inspected and updated together within the same ecosystem.
   - Run the ecosystem's verification suite immediately after applying minor/patch updates.

4. **Out of Scope / Forbidden Actions**:
   - Toolchain and runtime upgrades (`rustc`, Rust edition, `node`, `python`, `swift` versions, `.tool-versions`, `.mise.toml`, `package.json#engines`) must NEVER be bundled with dependency bumps.
   - Upgrading to pre-release, alpha, beta, release-candidate (RC), or canary versions is prohibited. Only stable releases are permitted.

5. **Immediate Rollback on Verification Failure**:
   - If verification fails and the root cause cannot be cleanly and quickly resolved, immediately revert all changes introduced by that dependency update step back to the clean baseline (`git restore . && git clean -fd`).

6. **SDLC Pre-Commit Approval Gate (Stage 4)**:
   - **NEVER commit directly or automatically.**
   - Run `git status` and present the list of changed files.
   - Propose clear Conventional Commit message(s), for example:
     - `chore(deps): update <ecosystem> dependencies (minor & patch)`
     - `chore(deps): bump <package> from <v1> to <v2>`
   - **Wait for explicit user approval** before executing `git commit`.

---

## Ecosystem Workflows & Protocols

### 1. Node & TypeScript (via pnpm)

This repository and supported projects exclusively standardize on **`pnpm`** for Node and TypeScript dependency management.

#### A. Inspection
Check for outdated packages across the workspace:

```bash
rtk pnpm outdated
```

Categorize updates:
- **Patch/Minor bumps**: Safe, SemVer-compatible updates.
- **Major bumps**: Breaking changes requiring individual isolation.

#### B. Safe Upgrades (Minor & Patch)
Apply non-breaking updates within `package.json` constraints:

```bash
pnpm update
```

Run the project verification suite immediately:

```bash
rtk mise run verify # or project verification tasks (e.g. rtk pnpm check && rtk pnpm lint && rtk pnpm test)
```

If any check fails and cannot be resolved quickly:

```bash
git checkout -- package.json pnpm-lock.yaml
pnpm install
```

#### C. Major Upgrades (One at a Time)
For each major version upgrade:

1. **Isolate**: Select **one** dependency at a time.
2. **Review Changelog**: Inspect release notes / migration guides for breaking changes and deprecations.
3. **Upgrade Dependency**:
   ```bash
   pnpm update <package-name>@latest
   ```
4. **Adapt Codebase**:
   - Update deprecated API calls, configuration files, and types.
   - Maintain architectural boundaries and module structure.
5. **Verify**:
   ```bash
   rtk mise run verify # or project test/check commands
   ```
6. **Rollback on Failure**:
   ```bash
   git restore . && git clean -fd
   pnpm install
   ```

#### D. TypeScript & Framework Considerations
- **TypeScript & Tooling**:
  - When upgrading `typescript`, inspect `tsconfig.json` for new strictness flags or compiler diagnostics.
  - Keep `@types/*` packages (e.g., `@types/node`) aligned with installed runtime/library versions.
  - When updating formatters or linters (`oxlint`, `oxfmt`, `eslint`, `prettier`), run them across the codebase to ensure rules and configurations remain compatible.
- **React**:
  - Keep `react`, `react-dom`, `@types/react`, and `@types/react-dom` synchronized in lockstep to identical major versions.
  - Review official React changelogs before major bumps for component prop changes, ref handling adjustments, or server component conventions.
- **Svelte**:
  - Keep core packages (`svelte`, `@sveltejs/kit`, and `@sveltejs/adapter-*`) aligned.
  - When updating `@sveltejs/kit` or Svelte, check `svelte.config.js` and `vite.config.ts` for adapter and plugin configuration requirements.
  - Review official release notes for syntax or API adjustments.

---

### 2. Rust Ecosystem (via Cargo)

#### A. Inspection

1. **Compatible Lockfile Inspection (Minor & Patch)**:
   ```bash
   cargo update --dry-run
   ```

2. **Manifest Requirements Inspection (Major & Breaking Upgrades)**:
   ```bash
   # Primary tool: cargo-edit
   cargo upgrade --dry-run

   # Alternative tool: cargo-outdated
   cargo outdated --workspace
   ```

3. **Targeted Crate Inspection**:
   ```bash
   cargo search <crate-name>
   ```

#### B. Safe Upgrades (Minor & Patch)
Update compatible dependencies in `Cargo.lock`:

```bash
cargo update
```

Run the Rust verification suite immediately:

```bash
rtk cargo clippy --all-targets --all-features && rtk cargo fmt --check && rtk cargo test --workspace
```

If verification fails:

```bash
git checkout -- Cargo.lock Cargo.toml
```

#### C. Major Upgrades (One at a Time)
For breaking crate upgrades:

1. **Isolate**: Upgrade strictly **one crate at a time**.
2. **Review Changelog**: Review breaking changes, feature flag renames, and trait changes.
3. **Upgrade in Manifest**:
   - Update the version requirement in `[workspace.dependencies]` (root `Cargo.toml`) or the relevant crate's `Cargo.toml`.
   - Run `cargo update -p <crate-name>`.
4. **Adapt Codebase**:
   - Update Rust code to accommodate new APIs and trait bounds.
   - Maintain domain purity (keep domain crates free of infrastructure/framework dependencies).
5. **Verify**:
   ```bash
   rtk cargo clippy --all-targets --all-features && rtk cargo fmt --check && rtk cargo test --workspace
   ```
6. **Rollback on Failure**:
   ```bash
   git restore . && git clean -fd
   cargo check
   ```

#### D. Rust-Specific Considerations
- **Workspace Dependencies**: In multi-crate workspaces, prioritize centralized dependencies in root `[workspace.dependencies]` to avoid version divergence across sub-crates.
- **MSRV (Minimum Supported Rust Version)**: Verify that the upgraded crate does not require a higher compiler version than the repository's configured toolchain.
- **Tauri**: Maintain version alignment between Rust `tauri` crates and frontend `@tauri-apps/api` packages.

---

### 3. Swift / Apple Platforms (via SPM & XcodeGen)

#### A. Inspection
Inspect active package dependencies:

```bash
swift package show-dependencies
```

#### B. Safe Upgrades (Minor & Patch)
Update dependencies within existing `Package.swift` or Xcode constraints:

```bash
swift package update
```

Run the Swift verification suite:

```bash
swift test
# Or for Xcode projects:
# xcodebuild test -scheme <Scheme> -destination '<Destination>'
```

If verification fails:

```bash
git checkout -- Package.resolved
```

#### C. Major Upgrades (One at a Time)
1. **Isolate**: Upgrade one package at a time.
2. **Review Changelog**: Review release notes for API breaking changes and Swift Concurrency requirements.
3. **Upgrade Manifest**:
   - Update the dependency requirement in `Package.swift` (or `project.yml` if using XcodeGen).
   - If `project.yml` is modified, execute the project synchronization gate:
     ```bash
     rtk mise run generate # or xcodegen generate
     ```
   - Resolve package dependencies:
     ```bash
     swift package resolve # or xcodebuild -resolvePackageDependencies
     ```
4. **Adapt Codebase**:
   - Adapt Swift code for updated APIs.
   - Ensure compliance with Swift 6 and strict concurrency checking (`@Sendable`, actor isolation boundaries, and `Sendable` conformance on third-party models).
5. **Verify**:
   ```bash
   swift test
   ```
6. **Rollback on Failure**:
   ```bash
   git restore . && git clean -fd
   swift package resolve
   ```

---

### 4. Python Ecosystem (via uv)

This repository and supported projects exclusively standardize on **`uv`** for Python dependency management.

#### A. Inspection & Safe Upgrades (Minor & Patch)
Update dependencies within `pyproject.toml` constraints:

```bash
uv lock --upgrade
uv sync
```

Run the Python verification suite:

```bash
ruff check . && ruff format --check . && mypy . && uv run pytest
```

If verification fails:

```bash
git checkout -- pyproject.toml uv.lock
uv sync
```

#### B. Major Upgrades (One at a Time)
For breaking upgrades:

1. **Isolate**: Upgrade one dependency at a time.
2. **Review Changelog**: Inspect release notes for breaking API changes, parameter shifts, and deprecations.
3. **Upgrade Dependency**:
   ```bash
   uv add <package-name>@latest
   # Or for development dependencies:
   uv add --dev <package-name>@latest
   ```
4. **Adapt Codebase**:
   - Adapt source code to accommodate breaking changes.
   - Update type annotations and configuration files.
5. **Verify**:
   ```bash
   ruff check . && ruff format --check . && mypy . && uv run pytest
   ```
6. **Rollback on Failure**:
   ```bash
   git restore . && git clean -fd
   uv sync
   ```

#### C. Python-Specific Considerations
- **Lockfile Synchronization**: Always run `uv sync` after lockfile modifications to ensure the virtual environment matches `uv.lock`.
- **Type Checking**: Run static type checkers (`mypy` or `pyright`) alongside `uv run pytest` to detect type signature shifts immediately.

---

### 5. Hybrid & Polyglot Repositories (Monorepos)

Common hybrid architectures:
- **Tauri Applications**: Rust backend (`Cargo.toml`) + TypeScript/Svelte/React frontend (`package.json` with `pnpm`).
- **Fullstack Applications**: Python (`uv`) or Rust (`Cargo.toml`) backend + TypeScript frontend (`pnpm`).
- **Native Applications with Shared Core**: Swift/iOS frontend (`Package.swift` / XcodeGen) + Rust core library.

#### Sequential Phased Execution Protocol

1. **Phase 1: Backend / Systems Core First**:
   - Inspect and update backend dependencies (`cargo` or `uv`) first.
   - Run backend test and lint suites to ensure the core system remains healthy before touching client code.

2. **Phase 2: Contract & IPC Synchronization Gate**:
   - If the repository maintains shared schemas or bindings (e.g., `tauri-specta`, `ts-rs`, OpenAPI clients, GraphQL codegen, Protobuf/gRPC), regenerate and verify them immediately:
     ```bash
     rtk mise run generate # or repository schema generation command
     ```
   - Ensure the updated contract builds cleanly before proceeding to the client.

3. **Phase 3: Frontend / Client UI Second**:
   - Inspect and update frontend dependencies (`pnpm` or `swift`).
   - Adapt UI code to both the client dependency updates and any updated contracts from Phase 2.
   - Run frontend verification suite.

4. **Phase 4: Full Repository Verification**:
   - Run the complete end-to-end verification suite across all workspaces.

---

## Final Verification & SDLC Commit Gate

### 1. Full Repository Verification Suite
Execute all project verification commands (or `rtk mise run verify`). Ensure zero warnings/errors.

### 2. SDLC Commit Approval Protocol (Stage 4)
Per SDLC Stage 4 Verification Gate:
- **NEVER commit directly or automatically.**
- Run `git status` and display the list of modified files.
- Propose Conventional Commit message(s):
  - `chore(deps): update pnpm dependencies (minor & patch)`
  - `chore(deps): bump <package> from <v1> to <v2>`
  - `chore(deps): update rust dependencies (minor & patch)`
  - `chore(deps): bump <crate> from <v1> to <v2>`
  - `chore(deps): update python dependencies (minor & patch)`
  - `chore(deps): bump <python-package> from <v1> to <v2>`
  - `chore(deps): update swift dependencies (minor & patch)`
- **Wait for explicit user approval** before running `git commit`.
