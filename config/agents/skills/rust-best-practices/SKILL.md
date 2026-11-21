---
name: rust-best-practices
description: Use when designing, writing, reviewing, or refactoring Rust code to ensure idiomatic patterns, memory safety, error handling, API design, and performance.
---

# Rust Best Practices Skill

Idiomatic conventions, safety guidelines, and design patterns for Rust development, synthesizing the Rust API Guidelines,
the [Rust Design Patterns](https://rust-unofficial.github.io/patterns/) catalog, Apollo GraphQL rules, and community
standards.

For specialized architectural, AST/tree, and FFI patterns, consult [`references/patterns.md`](./references/patterns.md).

---

## When to Apply This Skill

- Writing, modifying, or reviewing Rust code (`*.rs`, `Cargo.toml`).
- Architecting Rust libraries, binary crates, workspaces, and modules.
- Refactoring existing Rust code for memory efficiency, borrow-checker ergonomics, safety, and performance.
- Conducting code reviews or pre-commit checks for Rust projects.

---

## 1. Ownership, Borrowing & Resource Lifecycle

### Rule 1: Use Borrowed Types for Arguments (`2.1`)
- Prefer shared or mutable references (`&T`, `&mut T`) over taking ownership. Never `.clone()` solely to appease the borrow checker.
- Accept borrowed deref targets rather than references to owned containers to avoid double indirection and widen caller compatibility via deref coercion:
  - Prefer `&str` over `String` or `&String`.
  - Prefer `&[T]` over `Vec<T>` or `&Vec<T>`.
  - Prefer `&Path` over `PathBuf` or `&PathBuf`.
  - Prefer `&T` over `&Box<T>`.
- Pass small `Copy` types (primitives, small value structs) by value. Do not mark large, heap-backed structs as `Copy`.

### Rule 2: Prevent Eager Allocations & Format Idiomatically (`2.2`)
- Defer allocations and conversions until consumed. Chain iterators instead of collecting intermediate `Vec<T>` values.
- Prefer lazy combinators (`unwrap_or_else`, `ok_or_else`, `or_else`) over eager alternatives (`unwrap_or`, `ok_or`) whenever fallback computation allocates or performs work.
- **String concatenation (`2.2`)**: Prefer `format!` for readable one-off assembly mixing literals and variables. Use `String::with_capacity` with `push` / `push_str` inside hot loops to avoid repeated allocations.

### Rule 3: Temporary Mutability & In-Place State Extraction (`2.14`, `2.7`)
- **Temporary mutability (`2.14`)**: Restrict `mut` bindings to their initialization phase using a nested block or immutable rebinding so the compiler prevents accidental later mutation:
  ```rust
  let items = {
      let mut items = load_items();
      items.sort_unstable();
      items
  };
  ```
- **`mem::{take, replace}` in mutated enums and structs (`2.7`)**: When transitioning `&mut` enum variants or mutating fields in place, extract owned values with `std::mem::take` (for `Default` types), `std::mem::replace`, or `Option::take` instead of `.clone()`:
  ```rust
  use std::mem;

  enum State {
      Pending { name: String, retries: u8 },
      Failed { name: String },
  }

  fn mark_failed(state: &mut State) {
      if let State::Pending { name, retries: 0 } = state {
          *state = State::Failed { name: mem::take(name) };
      }
  }
  ```

### Rule 4: Scoped Variable Rebinding for Closures (`2.11`)
- When a `move` closure needs a mix of cloned handles, borrowed references, and moved values, rebind them in a dedicated lexical block instead of polluting the outer scope with `*_clone` variables:
  ```rust
  let worker = {
      let cache = Arc::clone(&cache);
      let config = config.as_ref();
      move || process(&cache, config, owned_job)
  };
  ```

### Rule 5: RAII Guards & Destructor Finalisation (`3.1.4`, `2.6`)
- Bind resource cleanup, lock release, and state restoration to guard types implementing `Drop` so finalisation runs across `?` early returns and stack unwinding.
- Mediate access to protected resources through lifetime-bound methods or `Deref` on the guard struct (like `MutexGuard<'a, T>`) so borrowed references cannot outlive the guard.
- Bind standalone scope-exit guards to a named `_guard` binding (`let _guard = ScopeExit;`). Never use bare `let _ = ScopeExit;`, which drops the guard immediately.
- **Never panic inside `Drop::drop`**, as double panics during stack unwinding abort the process immediately, and keep in mind destructors are not guaranteed to run on `std::mem::forget`, process abort, or infinite loops.

### Rule 6: Concurrency Primitives & Unsafe Module Containment (`3.3.3`)
- Use `Rc<T>` and `RefCell<T>` strictly in single-threaded contexts; use `Arc<T>` with `Mutex<T>` or `RwLock<T>` across threads.
- **Contain unsafety in small modules (`3.3.3`)**: Isolate `unsafe` blocks and raw pointers inside the smallest possible private module that upholds all representation invariants and exposes a safe API to the surrounding module. Remember that safe code inside the same module can mutate private fields and break `unsafe` assumptions.
- Accompany every `unsafe` block with a `// SAFETY:` comment proving its invariants, and document caller preconditions under `# Safety` on every `unsafe fn`.

### Rule 7: Struct Decomposition for Independent Borrowing (`3.3.1`)
- When `&mut self` methods conflict with simultaneous borrows of unrelated fields on a large struct, decompose the struct into smaller cohesive sub-structs composed into the parent. The borrow checker tracks disjoint field borrows (`&mut self.pool`, `&self.config`) independently without cloning.

---

## 2. Robust Error Handling & Control Flow

### Rule 8: Clear Separation Between Recoverable and Fatal Errors
- Use `Result<T, E>` for recoverable errors; reserve `panic!` strictly for unrecoverable invariant violations.
- **Zero `unwrap()` / `expect()` in shipping library code**: Propagate errors with `?` or pattern matching. Use `.expect("verified invariant")` only in tests or documented impossibility proofs.

### Rule 9: Error Strategy by Crate Type & Consumed Arguments (`2.15`)
- **Library crates (`lib.rs`)**: Define typed, domain-specific error enums with [`thiserror`](https://docs.rs/thiserror) implementing `std::error::Error`. Translate third-party internal errors at public API boundaries rather than leaking them.
- **Binary/Application crates (`main.rs`, CLI, services)**: Use [`anyhow`](https://docs.rs/anyhow) or `eyre` with `.context("...")` for rich operational diagnostics.
- **Return consumed argument on error (`2.15`)**: When a fallible function takes ownership of an argument (such as sending a message or converting a buffer like `String::from_utf8`), embed the unconsumed value inside the error type (`Err(SendError(value))`) so callers can retry or recover ownership without defensive `.clone()` calls.

### Rule 10: Idiomatic Control Flow & `Option` Iteration (`2.10`)
- Prefer `let PATTERN = EXPR else { ... };` (guard `let-else`) for early exits when a value is absent or invalid.
- Use `if let ... else` when both branches carry meaningful domain logic. Never silently discard errors (`let _ = ...`) unless explicitly justified.
- **Iterating over `Option` (`2.10`)**: `Option<T>` implements `IntoIterator` yielding 0 or 1 item. Pass options directly to `.extend(opt)` or `.chain(opt)` instead of manual `if let Some(v) = opt { list.push(v); }` branches. Keep `if let Some(...)` for standalone conditionals and `std::iter::once(v)` when a single item is unconditionally present.

---

## 3. Idiomatic API Design & Type System

### Rule 11: Strong Typing, Newtypes & Type-State (`3.1.3`)
- **Newtype Pattern (`3.1.3`)**: Wrap primitive or foreign types in single-field tuple structs (`pub struct UserId(Uuid);`, `pub struct Meters(f64);`) to prevent primitive transposition, enforce construction invariants, hide representation details, or implement traits across orphan-rule boundaries.
- **Enums over Booleans**: Replace boolean parameters and flags (`use_cache: bool`) with self-documenting enums (`CachePolicy::Enabled`, `CachePolicy::Bypass`).
- **Type-State Pattern**: Encode lifecycle states as type parameters so illegal transitions fail at compile time:
  ```rust
  pub struct Draft;
  pub struct Published;
  pub struct Article<State> {
      body: String,
      _state: std::marker::PhantomData<State>,
  }

  impl Article<Draft> {
      pub fn publish(self) -> Article<Published> {
          Article { body: self.body, _state: std::marker::PhantomData }
      }
  }
  ```

### Rule 12: Constructors (`new`) & The `Default` Trait (`2.3`, `2.4`)
- Provide a conventional `pub fn new(...) -> Self` associated function as the primary constructor.
- Implement or `#[derive(Default)]` whenever a type has a sensible initial or empty value. `Default` unlocks generic containers, `Option::unwrap_or_default()`, `mem::take`, and partial struct initialization (`Config { timeout, ..Default::default() }`).
- When `new()` takes no arguments, implement both `pub fn new() -> Self` and `Default`.

### Rule 13: Builder Pattern & API Extensibility (`3.2.1`, `2.12`)
- **Builder Pattern (`3.2.1`)**: Provide a dedicated `*Builder` with fluent methods for structs with multiple optional configurations or cross-field validation.
- **`#[non_exhaustive]` and private fields (`2.12`)**:
  - Apply `#[non_exhaustive]` to public library structs, enums, and enum variants whose fields or variants may grow without a major SemVer bump (requiring downstream callers to match with `..` or `_ =>`).
  - Keep at least one struct field private (or add `_priv: ()` when all data fields are public) to prevent direct struct literal construction or exhaustive destructuring within or across crates when invariants must be preserved.

### Rule 14: Traits, Dispatch, Strategy & Custom Bound Traits (`2.8`, `3.1.5`, `3.3.4`)
- **Standard & Conversion Traits**: Eagerly implement `Debug`, `Clone`, `PartialEq`, `Eq`, `Default`, and `Hash` where applicable, alongside `From<T>` (providing `Into<T>`), `TryFrom<T>`, `AsRef<T>`, and `AsMut<T>`.
- **On-Stack Dynamic Dispatch (`2.8`)**: Prefer static dispatch (`impl Trait` or generics) on hot paths. When selecting polymorphically between concrete types within a function, bind `&dyn Trait` or `&mut dyn Trait` on the stack (leveraging temporary lifetime extension) before allocating `Box<dyn Trait>`:
  ```rust
  let reader: &mut dyn std::io::Read = if path == "-" {
      &mut std::io::stdin()
  } else {
      &mut std::fs::File::open(path)?
  };
  ```
- **Strategy / Policy Pattern (`3.1.5`)**: Inject interchangeable algorithms (formatting, retry, scoring) via generic trait bounds (`fn generate<F: Formatter>(...)`) or closures (`Fn`) to decouple workflow skeletons from concrete implementations.
- **Custom Traits to Avoid Complex Type Bounds (`3.3.4`)**: When higher-order bounds (especially `Fn` / `FnMut` returning `Result<T, E>` with constrained output types) repeat across types and `impl` blocks, define a focused domain trait with an associated output type and a blanket `impl`:
  ```rust
  trait Probe {
      type Value: std::fmt::Display;
      fn sample(&mut self) -> Result<Self::Value, ProbeError>;
  }

  impl<F, T> Probe for F
  where
      F: FnMut() -> Result<T, ProbeError>,
      T: std::fmt::Display,
  {
      type Value = T;
      fn sample(&mut self) -> Result<Self::Value, ProbeError> {
          self()
      }
  }
  ```

---

## 4. Code Organization, Style, Documentation & Tooling

### Rule 15: Standard Project Structure
- Split binary and library code into `src/lib.rs` and a thin `src/main.rs` orchestration entrypoint.
- Group imports consistently: (1) `std` / `core` / `alloc`, (2) external crates, (3) workspace crates, (4) `crate::` / `super::` modules.
- Follow [RFC 430](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md) naming: `UpperCamelCase` for types/traits/variants, `snake_case` for functions/methods/modules/variables, and `SCREAMING_SNAKE_CASE` for constants/statics.

### Rule 16: Comprehensive Rustdoc
- Document public items (`pub`) with `///` comments covering `# Examples`, `# Errors`, `# Panics`, and `# Safety` (mandatory on `unsafe fn`), and use `//!` for crate/module overview docs.
- For types requiring heavy setup in doc-tests, use the Easy Doc Initialization idiom in [`references/patterns.md`](./references/patterns.md#12-easy-doc-initialization-213).

### Rule 17: Mandatory Task Automation with `mise.toml`
- Every Rust repository **MUST** define standard verification tasks in `mise.toml` for SDLC Stage 4 (`rtk mise run verify`):
  ```toml
  [tasks.lint]
  description = "Lint Rust code with clippy"
  run = "cargo clippy --workspace --all-targets --all-features -- -D warnings"

  [tasks."format:check"]
  description = "Check Rust formatting"
  run = "cargo fmt --all --check"

  [tasks.format]
  description = "Format Rust code"
  run = "cargo fmt --all"

  [tasks.test]
  description = "Run Rust test suite"
  run = "cargo test --workspace"

  [tasks.verify]
  description = "Run all verification checks (lint, format:check, test)"
  depends = ["lint", "format:check", "test"]
  ```

---

## 5. Performance & Concurrency

### Rule 18: Measurement-Driven Optimization
- Profile release builds (`--release`) with `criterion` or `flamegraph` before optimizing hot paths.
- Use `rayon` for CPU-bound data parallelism and `tokio` for async I/O concurrency; offload blocking work in async contexts via `tokio::task::spawn_blocking`.

---

## 6. Specialized & FFI Patterns Reference

Read [`references/patterns.md`](./references/patterns.md) when designing or reviewing any of the following specialized scenarios:

- **Custom Owning Containers & Rustdoc Ergonomics**:
  - *Collections Are Smart Pointers (`2.5`)* — Implementing `Deref` to expose borrowed slice/view types (without falling into `Deref` polymorphism).
  - *Easy Doc Initialization (`2.13`)* — Wrapping complex setup in hidden helper functions inside `///` examples.
- **Crate Modularity, AST Traversal & Action Reification**:
  - *Prefer Small Crates (`3.3.2`)* — Workspace modularization vs dependency skew and LTO trade-offs.
  - *Visitor (`3.1.6`)* & *Fold (`3.2.2`)* — Stateful inspection vs immutable recursive transformation of heterogeneous trees/ASTs.
  - *Command (`3.1.1`)* & *Interpreter (`3.1.2`)* — Undoable/queued operations and compact DSL/AST or `macro_rules!` evaluators.
- **Foreign Function Interface (`extern "C"`)**:
  - *FFI Idioms (`2.9.1`–`2.9.3`)* — C return-code/struct error mapping, zero-copy `CStr` input validation, and `CString` / `Vec<u8>` lifetime safety.
  - *FFI Patterns (`3.4.1`–`3.4.2`)* — Opaque object-based C handles and wrapper type consolidation preventing cross-FFI aliasing UB.

---

## 7. Pre-Commit & Review Quality Checklist

- [ ] **Mise Verification Tasks**: `mise.toml` defines `verify`, `lint`, `format:check`, `format`, and `test`.
- [ ] **Unified Verification**: Passes `rtk mise run verify` (`cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`) with zero warnings.
- [ ] **Ownership & Mutability**: Uses borrowed slice/deref arguments (`&str`, `&[T]`, `&Path`, `&T`), scopes `mut` bindings tightly, and uses `mem::take` / `mem::replace` instead of borrow-checker `.clone()` workarounds.
- [ ] **Safety & Resources**: Isolates `unsafe` inside minimal private modules with `// SAFETY:` proofs, never panics in `Drop`, and uses RAII guards for multi-exit cleanup.
- [ ] **Errors**: Uses `thiserror` (libraries) or `anyhow` (binaries), avoids production `unwrap()` / `expect()`, and returns consumed arguments inside `Err` where retry/recovery matters.
- [ ] **API & Types**: Applies Newtypes/enums/builders where invariants warrant, implements `new` + `Default` consistently, and protects SemVer boundaries with `#[non_exhaustive]` or private fields.
- [ ] **Documentation & Tests**: Public APIs include `///` rustdoc (`# Examples`, `# Errors`, `# Safety`), and risky execution paths have targeted unit/integration tests.
