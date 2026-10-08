---
name: rust-best-practices
description: Use when designing, writing, reviewing, or refactoring Rust code to ensure idiomatic patterns, memory safety, error handling, API design, and performance.
---

# Rust Best Practices Skill

This skill provides idiomatic conventions, safety guidelines, and architectural patterns for Rust development,
synthesizing standards from the Rust API Guidelines, Apollo GraphQL Codex rules, and community best practices.

---

## When to Apply This Skill

- Writing, modifying, or reviewing Rust code (`*.rs`, `Cargo.toml`).
- Architecting Rust libraries, binary crates, workspaces, and modules.
- Refactoring existing Rust code for memory efficiency, safety, and performance.
- Conducting code reviews or pre-commit checks for Rust projects.

---

## 1. Ownership, Borrowing & Memory Management

### Rule 1: Borrow by Default
- Prefer references (`&T`, `&mut T`) over taking ownership. Avoid cloning unless an independent owned copy is genuinely required.
- Public functions should accept borrowed slices rather than owned collections when ownership is not needed:
  - Prefer `&str` over `String` or `&String`.
  - Prefer `&[T]` over `Vec<T>` or `&Vec<T>`.
  - Prefer `&Path` over `PathBuf` or `&PathBuf`.
- Pass small `Copy` types (integers, floats, small structs) by value. Avoid marking large, heap-backed structs as `Copy`.

### Rule 2: Prevent Eager Allocations
- Defer conversions and allocations until consumed.
- Pass iterators through pipelines instead of collecting intermediate collections (`collect()`) and reprocessing.
- Use lazy evaluation combinators (`unwrap_or_else()`, `ok_or_else()`, `or_else()`) rather than eager alternatives (`unwrap_or()`) when computing default values involves allocations or work.

### Rule 3: Smart Pointers and Concurrency Primitives
- Use `Rc<T>` and `RefCell<T>` strictly in single-threaded contexts when interior mutability or multiple ownership is required.
- Use `Arc<T>` with `Mutex<T>` or `RwLock<T>` for shared state across thread boundaries.
- Treat raw pointers (`*const T`, `*mut T`) and `unsafe` blocks as exceptional. Any `unsafe` block must be accompanied by a `// SAFETY:` comment establishing the verified invariants.

---

## 2. Robust Error Handling

### Rule 4: Clear Separation Between Recoverable and Fatal Errors
- Use `Result<T, E>` for recoverable errors.
- Reserve `panic!` strictly for unrecoverable errors, corrupted invariants, or contract violations (e.g. out-of-bounds indexing in internal invariants).
- **Zero `unwrap()` / `expect()` in shipping library code**:
  - Replace `.unwrap()` and `.expect()` with proper error propagation (`?`) or pattern matching.
  - In unit tests or documented impossibility proofs, `.expect("invariant description")` is acceptable when an explanatory message is provided.

### Rule 5: Error Strategy by Crate Type
- **Library crates (`lib.rs`)**:
  - Use typed, domain-specific error enums using [`thiserror`](https://docs.rs/thiserror).
  - Implement `std::error::Error` for public error types.
  - Avoid leaking third-party internal error types into public APIs; translate them at boundaries.
- **Binary/Application crates (`main.rs`, CLI, services)**:
  - Use [`anyhow`](https://docs.rs/anyhow) or `eyre` for flexible error handling with contextual reporting (`.context("Failed to load configuration")`).

### Rule 6: Idiomatic Control Flow with Option & Result
- Prefer `let PATTERN = EXPR else { ... }` (guard pattern) for early exit when a value is absent or an error occurs.
- Use `if let ... else` when both branches contain meaningful logic.
- Never silently discard errors (`let _ = ...`) unless explicitly justified and documented.

---

## 3. Idiomatic API Design & Type System

### Rule 7: Leverage Strong Typing & Type-State Pattern
- **Newtype Pattern**: Wrap primitive types to enforce static domain guarantees (e.g., `struct UserId(Uuid);` instead of raw `Uuid`).
- **Enums over Booleans**: Replace boolean configuration flags (`is_active: bool`, `use_cache: bool`) with explicit domain enums (`CachePolicy::Enabled`, `CachePolicy::Bypass`).
- **Type-State Pattern**: Model state transitions in the type system to make illegal transitions impossible to compile:
  ```rust
  struct Draft;
  struct Published;
  struct Article<State> { state: std::marker::PhantomData<State> }

  impl Article<Draft> {
      pub fn publish(self) -> Article<Published> { ... }
  }
  ```

### Rule 8: Trait Implementation Best Practices
- **Standard Traits**: Eagerly implement common traits where applicable:
  - `Debug`, `Clone`, `PartialEq`, `Eq`, `Default`, `Hash`.
- **Conversions**: Implement standard conversion traits:
  - `From<T>` (which automatically provides `Into<T>`).
  - `TryFrom<T>` for fallible conversions.
  - `AsRef<T>` and `AsMut<T>` for reference-to-reference conversions.
- **Dispatch Selection**:
  - Prefer static dispatch (`impl Trait` or generic type parameters `fn process<T: Trait>(item: T)`) for zero-cost abstraction.
  - Use dynamic dispatch (`Box<dyn Trait>` or `&dyn Trait`) only when heterogeneous collections or dynamic runtime polymorphism are strictly necessary.

### Rule 9: Builder Pattern for Complex Construction
- When constructing structs with many optional parameters or complex validation, implement the Builder pattern with fluent method chaining.
- Keep struct fields `pub(crate)` or `private` unless direct struct modification without invariants is intentional.

---

## 4. Code Organization, Style & Documentation

### Rule 10: Standard Project Structure
- Split binary and library code into `src/lib.rs` and `src/main.rs`. Keep `main.rs` as a thin orchestration layer.
- Group imports logically:
  1. Standard library (`std::*`, `core::*`, `alloc::*`)
  2. External third-party crates (`serde::*`, `tokio::*`)
  3. Workspace crates
  4. Current crate modules (`crate::*`, `super::*`)
- Adhere to [RFC 430](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md) naming conventions:
  - `UpperCamelCase` for types, traits, and enum variants.
  - `snake_case` for functions, methods, modules, and variables.
  - `SCREAMING_SNAKE_CASE` for constants and statics.

### Rule 11: Comprehensive Rustdoc
- Document all public items (`pub`) using `///` doc comments.
- Include the standard sections:
  - `# Examples`: Executable doc-tests illustrating usage.
  - `# Errors`: Detailing conditions under which the function returns `Err`.
  - `# Panics`: Documenting any circumstances that may trigger a panic.
  - `# Safety`: Mandatory for every `unsafe fn`.
- Use `//!` at the top of files for module-level and crate-level documentation.

---

## 5. Performance & Concurrency

### Rule 12: Measurement-Driven Optimization
- Do not optimize prematurely based on intuition; verify with profiling (e.g. `flamegraph`, `criterion` benchmarks) on release builds (`--release`).
- Use `rayon` for CPU-bound data parallelism across collections.
- Use `tokio` or async runtimes for I/O-bound concurrency; avoid blocking the async runtime with long-running synchronous code (use `tokio::task::spawn_blocking`).

---

## 6. Pre-Commit & Review Quality Checklist

Before submitting Rust code for review or commit, verify:

- [ ] **Formatting**: Passes `cargo fmt --all --check`.
- [ ] **Linting**: Passes `cargo clippy --workspace --all-targets --all-features -- -D warnings` with zero warnings.
- [ ] **Ownership**: No unnecessary `.clone()` calls or premature collections.
- [ ] **Safety**: No undocumented `unsafe`, no production `unwrap()` / `expect()`.
- [ ] **Errors**: Errors use `thiserror` (libraries) or `anyhow` (binaries) and preserve context.
- [ ] **Documentation**: Public APIs have `///` rustdoc with examples and error descriptions.
- [ ] **Tests**: Unit tests under `#[cfg(test)]` and integration tests under `tests/` pass cleanly.
