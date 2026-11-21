---
name: rust-senior-review
description: Use when reviewing Rust PRs or diffs to find the highest-priority pattern from rust-best-practices applicable to the modified code that is not yet in the codebase, and record it in AGENTS.md once implemented.
---

# Rust Senior Pattern Review Skill

Perform a targeted senior Rust review on Pull Request or working-tree changes to surface the **first (highest-priority)
idiom or design pattern** from [`rust-best-practices`](../rust-best-practices/SKILL.md) that directly improves the
modified code and is **not yet adopted in the target codebase**, then synchronize `AGENTS.md` once implemented.

---

## Core Guardrails & SDLC Rules

1. **Proposal & Rationale Confirmation Gate (MANDATORY)**:
   - **NEVER** modify code, edit `AGENTS.md`, stage changes, or create commits without explicit user confirmation.
   - Present a structured assessment containing an explicit **Rationale** (justifying why the pattern is applicable to
     the diff, why higher-priority catalog items were skipped or already adopted, and what trade-offs apply) alongside
     the **Proposed Action**, and **STOP AND WAIT** for human approval.
2. **Mandatory `AGENTS.md` Sync on Implementation**:
   - Whenever the user approves and the recommended pattern is implemented in the target repository, **always update
     `AGENTS.md`** in that repository root to record the newly adopted pattern so future reviews and agents treat it as
     an established convention.
3. **Commit Approval Rule (SDLC Stage 4 - MANDATORY)**:
   - **NEVER** commit directly or automatically after implementing the pattern and updating `AGENTS.md`.
   - Run the verification suite (`rtk mise run verify` or `cargo` checks), present `rtk git status` + changed files,
     propose a Conventional Commit message (`refactor(<scope>): ...`), and wait for explicit user approval before
     running `git commit`.
4. **Single Highest-Priority Finding & YAGNI Floor**:
   - Report **at most one** pattern—the first entry in the Ordered Pattern Catalog below that is both relevant to the
     modified Rust code and absent from the existing codebase.
   - Never force a pattern onto trivial code where plain Rust is clearer; every recommendation must eliminate a concrete
     allocation, `.clone()`, borrow-checker workaround, `unsafe` exposure, error-handling gap, or API hazard.
5. **Token-Optimized Commands**:
   - Route all Git, GitHub, Cargo, Mise, and search commands through `rtk` (`rtk gh pr diff`, `rtk git diff`, `rtk rg`,
     `rtk cargo`, `rtk mise`).

---

## Review & Adoption Workflow

Execute these five steps in strict sequence:

### 1. Inspect `AGENTS.md` for Adopted Patterns
- Read `AGENTS.md` in the target repository root (plus any linked Rust architecture or convention docs).
- Extract any Rust idioms, error crates, or design patterns already documented as established standards or explicitly
  excluded by the project.

### 2. Inspect Modified Rust Code (PR or Diff)
- If a PR number or URL is provided:
  ```bash
  rtk gh pr diff <pr-number-or-url>
  ```
- If reviewing the current branch PR or local working tree:
  ```bash
  rtk gh pr diff          # or: rtk git diff / rtk git diff main...HEAD -- '*.rs'
  ```
- Focus strictly on added or modified hunks in `*.rs` (and `Cargo.toml` for crate/workspace boundaries). If no Rust
  code is modified, stop and report that no Rust changes are present.

### 3. Walk the Ordered Pattern Catalog (`#1` -> `#28`)
Traverse the catalog below in strict numerical priority order (`#1` first, `#28` last):

1. **Check Relevance to Modified Code**: Does an added or modified function, type, or module in the diff match the
   pattern's **Diff Signal** with a genuine clarity, safety, or performance gain?
   - If **No**, move immediately to the next rank without running codebase searches.
2. **Verify Absence in `AGENTS.md` and Codebase**: When a pattern matches the diff:
   - Check whether `AGENTS.md` already lists the pattern as adopted in the repository.
   - Run a targeted `rtk rg` search across existing `*.rs` files (ignoring the newly added diff lines) using the
     catalog's **Codebase Check** command.
   - If the pattern is **already documented in `AGENTS.md` OR already implemented in existing `*.rs` files**, record it
     as already adopted and continue to the next rank.
3. **Select First Un-Adopted Match & Stop**: Stop at the **first** rank that applies to the diff and is absent from both
   `AGENTS.md` and the existing codebase.
   - Consult [`../rust-best-practices/SKILL.md`](../rust-best-practices/SKILL.md) (for Ranks `#1`–`#22`) or
     [`../rust-best-practices/references/patterns.md`](../rust-best-practices/references/patterns.md) (for Ranks
     `#23`–`#28`) to ground edge cases and trade-offs before writing the rationale and refactoring snippet.

### 4. Present Proposal, Rationale & Await User Confirmation (MANDATORY)
Before modifying any code or `AGENTS.md`, present the structured assessment using the **Required Output Format** below
(including the explicit technical **Rationale**, Before/After code proposal, and exact `AGENTS.md` entry) and prompt the
user for confirmation.

**STOP AND WAIT**: Do NOT modify code, edit `AGENTS.md`, or create commits until the user explicitly confirms the
proposal.

### 5. Implement Pattern, Sync `AGENTS.md` & Verify (After User Confirmation)
Once the user explicitly approves the proposal:

1. **Refactor Target Code**: Apply the approved pattern in the target Rust file(s), preserving caller contracts and
   adding targeted tests if non-trivial branching or invariants changed.
2. **Update `AGENTS.md` (Mandatory)**:
   - Open `AGENTS.md` in the target repository root (create it if missing).
   - Locate the existing Rust conventions / patterns section, or add an `## Adopted Rust Patterns` section if none exists.
   - Append a concise, deduplicated entry recording the implemented pattern:
     `- **<Pattern Name>** (<Ref>): <1-line usage rule in this codebase>.`
3. **Run Local Quality Verification (Stage 4)**:
   - Run `rtk mise run verify` (or `rtk cargo clippy --workspace --all-targets -- -D warnings` and
     `rtk cargo test --workspace` if `mise.toml` is absent).
4. **Propose Conventional Commit & Await Human Approval (Stage 4 Commit Gate)**:
   - Run `rtk git status`, list changed files, propose a Conventional Commit message (`refactor(<scope>): adopt <pattern> in <module>`), and **wait for explicit user approval** before running `git commit`.

---

## Ordered Pattern Catalog (Priority `#1` -> `#28`)

### Tier 1: Ownership, Borrowing & Resource Safety

1. **Use Borrowed Types for Arguments** (`2.1` / Rule 1)
   - **Diff Signal**: Function parameters accept `&String`, `&Vec<T>`, `&PathBuf`, or `&Box<T>` (or needless owned containers) instead of `&str`, `&[T]`, `&Path`, or `&T`.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'fn \w+\([^)]*(&str|&\[[^\]]+\]|&Path\b)' -g '*.rs'`
2. **`mem::{take, replace}` in Mutated Enums/Structs** (`2.7` / Rule 3)
   - **Diff Signal**: Mutating `&mut Enum` or `&mut Struct` clones owned fields or uses dummy `Option` swaps to satisfy the borrow checker instead of `mem::take` / `mem::replace`.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'mem::(take|replace)\b' -g '*.rs'`
3. **Temporary Mutability** (`2.14` / Rule 3)
   - **Diff Signal**: `let mut x` is mutated only during setup or sorting at the top of a function and remains needlessly mutable across the rest of the scope.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg -U -P 'let \w+\s*=\s*\{\s*let mut |let (\w+)\s*=\s*\1;' -g '*.rs'`
4. **Struct Decomposition for Independent Borrowing** (`3.3.1` / Rule 7)
   - **Diff Signal**: Methods on a large struct clone fields or split arguments awkwardly because `&mut self` blocks simultaneous access to disjoint fields.
   - **Codebase Check**: Check `AGENTS.md`; inspect parent struct definitions in `src/` for composed sub-state structs borrowed independently.
5. **Contain Unsafety in Small Modules** (`3.3.3` / Rule 6)
   - **Diff Signal**: `unsafe` blocks or raw pointers sit inside a broad module alongside safe logic that can mutate private fields and break `unsafe` invariants.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg '\bunsafe\b' -g '*.rs'` and verify whether existing `unsafe` code is isolated inside minimal private submodules.
6. **RAII with Guards & Destructor Finalisation** (`3.1.4`, `2.6` / Rule 5)
   - **Diff Signal**: Cleanup, state reset, or resource release is duplicated across early returns or `?` paths instead of bound to a guard implementing `Drop`.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'impl(<[^>]+>)?\s+Drop\s+for\b' -g '*.rs'`

### Tier 2: Error Handling & Control Flow Idioms

7. **Typed Error Strategy (`thiserror` / `anyhow`)** (Rules 8–9)
   - **Diff Signal**: Non-test code uses `.unwrap()`, `.expect()`, `String` errors, or `Box<dyn Error>` instead of `thiserror` (libraries) or `anyhow::Context` (binaries).
   - **Codebase Check**: Check `AGENTS.md` and `Cargo.toml`; `rtk rg 'thiserror::Error|anyhow::(Context|Result)' -g '*.rs'`
8. **Guard `let ... else` Control Flow** (Rule 10)
   - **Diff Signal**: Deeply nested `match` or `if let` blocks exist solely to unwrap `Some`/`Ok` and diverge (`return`/`continue`/`break`) on failure.
   - **Codebase Check**: Check `AGENTS.md`; `rtk rg '\blet\s+.+\s*=\s*.+\s+else\s*\{' -g '*.rs'`
9. **Return Consumed Argument on Error** (`2.15` / Rule 9)
   - **Diff Signal**: Fallible function consumes an owned value (`fn send(v: T) -> Result<..., E>`) and drops `v` on `Err`, forcing callers to `.clone()` before retrying.
   - **Codebase Check**: Check `AGENTS.md`; inspect custom error types and `into_inner` recovery methods in `*.rs`.
10. **Iterating over `Option`** (`2.10` / Rule 10)
    - **Diff Signal**: Imperative `if let Some(x) = opt { vec.push(x); }` or manual conditional iterator branches replace `.extend(opt)` or `.chain(opt)`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '\.(extend|chain)\(' -g '*.rs'` and check whether `Option` values are passed directly.
11. **Lazy Combinators & Iterator Pipelines** (Rule 2)
    - **Diff Signal**: Eager `.unwrap_or(alloc())` / `.ok_or(format!(...))` or intermediate `.collect::<Vec<_>>()` followed immediately by `.iter()` / `.into_iter()`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '\.(unwrap_or_else|ok_or_else|or_else)\(' -g '*.rs'`
12. **String Assembly (`format!` vs Pre-Allocated Buffer)** (`2.2` / Rule 2)
    - **Diff Signal**: Chained `+` / `push_str` builds a one-off mixed string (prefer `format!`), OR `format!` allocates repeatedly inside a tight loop (prefer `String::with_capacity` + `push_str`).
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'String::with_capacity\b|format!\(' -g '*.rs'` (matching the relevant sub-idiom).
13. **Scoped Variable Rebinding for `move` Closures** (`2.11` / Rule 4)
    - **Diff Signal**: Outer scope defines `foo_clone`, `bar_clone` temporaries before `move || ...` instead of rebinding inside a block `{ let foo = Arc::clone(&foo); move || ... }`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg -U '\{\s*let \w+\s*=\s*(\w+\.clone\(\)|Arc::clone|Rc::clone)[\s\S]{0,160}move\s*\|' -g '*.rs'`

### Tier 3: Type System, Constructors & API Extensibility

14. **Newtype Pattern** (`3.1.3` / Rule 11)
    - **Diff Signal**: Raw primitives (`String`, `u64`, `Uuid`, `f64`) represent distinct domain IDs, units, or validated values (risking swapped parameters), or orphan rules block trait impls.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '(pub\s+)?struct\s+\w+\((pub(\([^)]+\))?\s+)?\w+\);' -g '*.rs'`
15. **Domain Enums over Booleans & Type-State** (Rule 11)
    - **Diff Signal**: Functions or structs pass `bool` mode flags or check runtime lifecycle booleans (`if !self.connected`) instead of domain enums or `PhantomData<State>` type-states.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'PhantomData<' -g '*.rs'` (for Type-State) or inspect domain mode enums.
16. **Constructors (`new`) & `Default` Trait** (`2.3`, `2.4` / Rule 12)
    - **Diff Signal**: Structs use ad-hoc factory names (`create`, `make`) or repeat full struct literals without `pub fn new(...) -> Self` and `Default` (`#[derive(Default)]` / `..Default::default()`).
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '#\[derive\([^)]*Default|impl\s+Default\s+for\b' -g '*.rs'`
17. **Builder Pattern** (`3.2.1` / Rule 13)
    - **Diff Signal**: Constructor takes 4+ optional parameters (`Option<T>`) or telescopic `new_with_*` variants instead of a fluent `*Builder`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'struct\s+\w+Builder\b|derive\([^)]*Builder' -g '*.rs'`
18. **`#[non_exhaustive]` & Private Fields for Extensibility** (`2.12` / Rule 13)
    - **Diff Signal**: Public library structs or enums expose all fields/variants without `#[non_exhaustive]` or a private field where future additions or invariants are expected.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '#\[non_exhaustive\]' -g '*.rs'`
19. **Standard Conversion Traits (`From`, `TryFrom`, `AsRef`)** (Rule 14)
    - **Diff Signal**: Custom `from_*`, `to_*`, or `as_*` helpers duplicate standard `From<T>`, `TryFrom<T>`, or `AsRef<T>` contracts.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'impl(<[^>]+>)?\s+(From|TryFrom|AsRef)<' -g '*.rs'`
20. **On-Stack Dynamic Dispatch** (`2.8` / Rule 14)
    - **Diff Signal**: Local conditional branching allocates `Box<dyn Trait>` solely to unify concrete types within one function scope where `&dyn Trait` / `&mut dyn Trait` works on the stack.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg ':\s*&(mut\s+)?dyn\s+\w+' -g '*.rs'`
21. **Strategy / Policy Pattern** (`3.1.5` / Rule 14)
    - **Diff Signal**: Core workflow hardcodes growing `match` branches for interchangeable formatting, retry, or routing algorithms instead of accepting a policy trait (`P: Policy`) or closure.
    - **Codebase Check**: Check `AGENTS.md`; inspect trait definitions injected as generic algorithm/policy parameters in `src/`.
22. **Custom Traits to Avoid Complex Type Bounds** (`3.3.4` / Rule 14)
    - **Diff Signal**: Complex bounds (e.g., `FnMut() -> Result<T, E>` + output bounds) repeat across structs and `impl` blocks instead of collapsing into a custom trait with a blanket `impl`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'impl<[^>]*Fn(Mut|Once)?\(' -g '*.rs'`

### Tier 4: Specialized Structural, AST & FFI Patterns ([`references/patterns.md`](../rust-best-practices/references/patterns.md))

23. **Collections Are Smart Pointers (`Deref`)** (`2.5` / Ref `1.1`)
    - **Diff Signal**: Custom owning buffer or collection manually forwards slice methods instead of implementing `Deref<Target = [T]>` (never suggest `Deref` for OOP struct inheritance).
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'impl(<[^>]+>)?\s+Deref\s+for\b' -g '*.rs'`
24. **Easy Doc Initialization** (`2.13` / Ref `1.2`)
    - **Diff Signal**: Public methods on complex structs skip `/// # Examples` or repeat heavy setup boilerplate instead of wrapping compile-checked examples in `# fn helper(...)`.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg '///\s*#\s*fn\s+\w+\(' -g '*.rs'`
25. **Prefer Small Crates** (`3.3.2` / Ref `2.1`)
    - **Diff Signal**: PR adds a large, self-contained, reusable subsystem with independent dependencies into a monolithic crate instead of a Cargo workspace member.
    - **Codebase Check**: Check `AGENTS.md` and root `Cargo.toml` for `[workspace]`.
26. **Visitor / Fold** (`3.1.6`, `3.2.2` / Ref `3.1`–`3.2`)
    - **Diff Signal**: Recursive AST/tree passes tangle node traversal with stateful inspection (`Visitor` + `walk_*`) or immutable tree rewriting (`Folder`).
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'trait\s+\w*(Visitor|Folder)\b|fn\s+(visit|walk|fold)_\w+' -g '*.rs'`
27. **Command / Interpreter** (`3.1.1`, `3.1.2` / Ref `3.3`–`3.4`)
    - **Diff Signal**: Action sequences need undo/rollback/queueing (`Command`), or repetitive rule evaluation warrants a small AST evaluator or `macro_rules!` DSL (`Interpreter`).
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'fn\s+(undo|rollback)\b|macro_rules!' -g '*.rs'`
28. **FFI Idioms & Wrappers** (`2.9`, `3.4` / Ref `4.1`–`4.5`)
    - **Diff Signal**: `extern "C"` code copies C strings manually, risks dangling `CString::new(...)?.as_ptr()`, leaks Rust panics/errors, or exports raw borrowed iterators instead of opaque consolidated handles.
    - **Codebase Check**: Check `AGENTS.md`; `rtk rg 'extern\s+"C"|CStr::from_ptr|CString::new' -g '*.rs'`

---

## Required Output Format

### Case A: Applicable Un-Adopted Pattern Found

````markdown
## Rust Senior Pattern Review

- **Recommended Pattern**: `<Pattern Name>` (Catalog `#<Rank>` — `<Ref>`)
- **Target Location**: `<file_path>:<line_number>`
- **Codebase Adoption Check**:
  - `AGENTS.md`: <Not listed / Checked summary>
  - Existing `*.rs` search: `<rtk rg query summary>` -> 0 prior occurrences in codebase
  - Skipped higher-priority candidates: <None, or `#Rank Name (already in codebase / AGENTS.md)`>
- **Rationale**:
  - **Problem in Diff**: <Technical explanation of the concrete risk, needless allocation/clone, borrow-checker workaround, `unsafe` exposure, or API hazard in the modified code.>
  - **Why This Pattern**: <Why `<Pattern Name>` is the right idiomatic fix here, why it passes the YAGNI floor, and what trade-off or constraint applies.>
- **Proposed Action**:
  1. **Code Refactoring** (`<file_path>:<line_number>`):
     **Current**:
     ```rust
     // <concise excerpt from diff>
     ```
     **Proposed (`<Pattern Name>`)**:
     ```rust
     // <idiomatic refactored implementation tailored to the diff>
     ```
  2. **`AGENTS.md` Update** (`## Adopted Rust Patterns` or existing Rust conventions section):
     ```markdown
     - **<Pattern Name>** (<Ref>): <1-line usage rule in this codebase>.
     ```

### User Confirmation Gate
> *"Please review the pattern assessment and rationale above. Confirm if you approve proceeding with this implementation and `AGENTS.md` update (yes/no), or specify any adjustments."*
````

### Case B: No Missing Pattern Applicable

````markdown
## Rust Senior Pattern Review

- **Verdict**: No un-adopted pattern recommended
- **Rationale**: <Clear technical justification explaining why either all patterns applicable to the modified Rust hunks are already established in `AGENTS.md` / existing `*.rs` files (listing matched ranks), or introducing remaining catalog patterns would violate YAGNI.>
````
