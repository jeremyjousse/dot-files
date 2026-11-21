# Specialized Rust Idioms & Design Patterns Reference

Companion reference for [`rust-best-practices`](../SKILL.md), covering specialized idioms, tree/action architectures,
workspace modularity, and Foreign Function Interface (`extern "C"`) patterns from the
[Rust Design Patterns](https://rust-unofficial.github.io/patterns/) catalog.

Apply these patterns only when the problem domain genuinely warrants them (respecting YAGNI and the 6-step reuse ladder).

---

## 1. Specialized Idioms

### 1.1 Collections Are Smart Pointers (`2.5`)

- **When to use**: Designing a custom owning collection or buffer type (`RingBuffer<T>`, `SmallVec<T>`, `ArenaSlice<T>`) that manages heap/backing storage and should expose a borrowed slice or view.
- **Pattern**: Implement `std::ops::Deref` (and `DerefMut` when mutable slice access preserves invariants) targeting the borrowed view type (`[T]`, `str`, or a custom unsized/view type). Implement read-only inspection methods on the borrowed view so both owning and borrowed callers share one implementation via deref coercion:

  ```rust
  use std::ops::Deref;

  pub struct PacketBuffer {
      bytes: Vec<u8>,
  }

  impl Deref for PacketBuffer {
      type Target = [u8];

      fn deref(&self) -> &[u8] {
          &self.bytes
      }
  }
  ```

- **Trade-offs & Anti-Pattern Warning**:
  - Trait bounds do not automatically resolve through `Deref`; pair `Deref` with `AsRef<[T]>` and `Borrow<[T]>` when generic interoperability is needed.
  - **Never commit the `Deref` Polymorphism anti-pattern**: Do not implement `Deref` on a domain struct merely to emulate OOP inheritance and forward methods to an inner struct. Only implement `Deref` when the wrapper genuinely behaves as a smart pointer or owning container to its `Target`.

### 1.2 Easy Doc Initialization (`2.13`)

- **When to use**: Writing `///` `# Examples` for methods on structs that require network sockets, file handles, or multi-step setup (`TcpStream`, `DatabasePool`), where repeating initialization boilerplate obscures the example.
- **Pattern**: Wrap the example body inside a hidden rustdoc helper function (`# fn demo(...) { ... }`) taking the pre-initialized types as parameters:

  ```rust
  impl Connection {
      /// Sends a request over an active connection.
      ///
      /// # Examples
      /// ```
      /// # use my_crate::{Connection, Request, SendError};
      /// # fn example(conn: &mut Connection, req: Request) -> Result<(), SendError> {
      /// let status = conn.send(req)?;
      /// assert!(status.is_ok());
      /// # Ok(())
      /// # }
      /// ```
      pub fn send(&mut self, req: Request) -> Result<Status, SendError> {
          // ...
      }
  }
  ```

- **Trade-offs**:
  - `cargo test --doc` compiles the hidden function to guarantee API and type accuracy without needing `no_run`, though assertions inside the uncalled helper do not execute at runtime.
  - When runtime assertion execution is required, provide a `#[doc(hidden)]` test-fixture constructor instead.

---

## 2. Structural & Workspace Modularity

### 2.1 Prefer Small Crates (`3.3.2`)

- **When to use**: A subsystem has a crisp, self-contained responsibility, minimal coupling to the parent application, and independent reuse or parallel compilation value.
- **Pattern**: Extract cohesive, single-purpose capabilities into focused Cargo workspace crates rather than growing a single monolithic crate. Since the crate is Rust's compilation unit, independent workspace crates compile in parallel and enforce strict public/private visibility boundaries.
- **Trade-offs**:
  - Over-splitting tightly coupled code creates boilerplate traits/adapters, risks duplicate major versions in Cargo dependency graphs ("dependency skew" where `crate_a v0.5` and `crate_a v1.0` types become incompatible), and limits cross-crate inlining unless `#[inline]` or Link-Time Optimization (LTO) is enabled.

---

## 3. Behavioural & Creational Patterns (ASTs, Trees & Actions)

### 3.1 Visitor (`3.1.6`)

- **When to use**: Running multiple independent, stateful read or validation algorithms (linting, type-checking, metrics collection) across a heterogeneous recursive data structure (such as an AST) without polluting the data types.
- **Pattern**: Define a `Visitor` trait with `visit_*` methods per node kind and factor shared recursion into standalone `walk_*` functions so concrete visitors override only the nodes they inspect:

  ```rust
  pub trait Visitor {
      fn visit_expr(&mut self, expr: &Expr) {
          walk_expr(self, expr);
      }
      fn visit_lit(&mut self, _value: i64) {}
  }

  pub fn walk_expr<V: Visitor + ?Sized>(visitor: &mut V, expr: &Expr) {
      match expr {
          Expr::Lit(n) => visitor.visit_lit(*n),
          Expr::Add(lhs, rhs) => {
              visitor.visit_expr(lhs);
              visitor.visit_expr(rhs);
          }
      }
  }
  ```

- **Trade-offs**: Adding a new AST variant requires updating `walk_*` and relevant visitors. For homogeneous sequences, use standard `Iterator` combinators instead.

### 3.2 Fold (`3.2.2`)

- **When to use**: Recursively transforming or desugaring a tree/AST into a new tree (either of the same type, such as constant folding/renaming, or lowering AST -> HIR) while preserving immutability.
- **Pattern**: Define a `Folder` trait whose `fold_*` methods consume owned nodes (`Box<Expr>` or `Expr`) and return transformed nodes, with default implementations recursively folding children:

  ```rust
  pub trait Folder {
      fn fold_name(&mut self, name: Name) -> Name {
          name
      }
      fn fold_expr(&mut self, expr: Expr) -> Expr {
          match expr {
              Expr::Var(name) => Expr::Var(self.fold_name(name)),
              Expr::Add(lhs, rhs) => {
                  Expr::Add(Box::new(self.fold_expr(*lhs)), Box::new(self.fold_expr(*rhs)))
              }
          }
      }
  }
  ```

- **Trade-offs**: Consuming `Box<Node>` reuses allocations when unchanged leaf nodes are returned directly, whereas borrowing `&Node` forces cloning unchanged subtrees (mitigated with `Arc<Node>` when structural sharing is needed). Note that this compiler-style `Folder` maps structure-to-structure, unlike `Iterator::fold` which reduces to a scalar.

### 3.3 Command (`3.1.1`)

- **When to use**: Encapsulating actions as values so operations can be queued, logged, audited, replayed, or rolled back in reverse order (migrations, editor undo/redo stacks, job queues).
- **Pattern**: Choose the lightest representation matching state requirements:
  1. **Enum of Commands** *(preferred when the command set is closed)*: Zero heap allocation per variant and exhaustive `match` dispatch.
  2. **Function Pointers (`fn() -> Result<(), Err>`)**: Zero-allocation dispatch when commands carry no captured state.
  3. **Trait Objects (`Box<dyn Command>`) or Boxed `Fn` Closures**: Best when commands carry per-instance state and open extensibility (e.g., `execute(&self)` paired with `rollback(&self)` iterated via `.iter().rev()`).
- **Trade-offs**: Dynamic trait objects incur heap allocation and vtable indirection; prefer a closed `enum` unless external callers register custom commands.

### 3.4 Interpreter (`3.1.2`)

- **When to use**: A recurring class of domain rules, query filters, or mathematical formulas is cleaner to express as a small grammar/DSL than as repetitive imperative code.
- **Pattern**:
  - **Runtime inputs**: Parse sentences into a typed AST enum and evaluate recursively.
  - **Compile-time static syntax**: Use declarative `macro_rules!` to expand concise domain notation directly into zero-overhead Rust expressions.
- **Trade-offs**: Custom parsers and macros carry maintenance and error-reporting overhead; avoid inventing a mini-language when composable Rust functions or builders suffice.

---

## 4. Foreign Function Interface (`extern "C"`) Idioms & Patterns

### 4.1 Error Handling in FFI (`2.9.1`)

- **When to use**: Exposing fallible Rust functions across C ABIs (`extern "C"`), where Rust `Result<T, E>` and unwinding panics cannot cross the boundary safely (`panic` across `extern "C"` is UB).
- **Pattern**:
  1. **Flat Enums**: Map variants explicitly to `libc::c_int` return codes (`0` for success, non-zero codes via `From<MyError> for libc::c_int`).
  2. **Structured Enums**: Return an integer status code and provide an opaque error-inspection function (`db_error_message`) for diagnostic strings.
  3. **Transparent Records**: Provide a dedicated `#[repr(C)]` struct conversion (`From<ParseError> for c_parse_error`) when C callers inspect structured fields (`line`, `column`).

### 4.2 Accepting Foreign Strings (`2.9.2`)

- **When to use**: Reading `*const libc::c_char` pointers passed from C into Rust.
- **Pattern**: Keep foreign strings borrowed via `std::ffi::CStr::from_ptr` and validate UTF-8 with `.to_str()` instead of manually calling `strlen` and copying raw buffers:

  ```rust
  use std::ffi::{c_char, c_int, CStr};

  /// # Safety
  /// `msg` must be non-null, point to a valid NUL-terminated buffer, and remain
  /// unmutated for the duration of this call.
  #[unsafe(no_mangle)]
  pub unsafe extern "C" fn mylib_log(msg: *const c_char) -> c_int {
      if msg.is_null() {
          return -1;
      }
      // SAFETY: Caller upholds `msg` validity and NUL termination per `# Safety`.
      let Ok(text) = unsafe { CStr::from_ptr(msg) }.to_str() else {
          return -2;
      };
      log_message(text);
      0
  }
  ```

- **Trade-offs**: Zero-copy and minimal `unsafe` surface; requires strict null check and documented `# Safety` contract.

### 4.3 Passing Strings to FFI (`2.9.3`)

- **When to use**: Passing Rust strings into C functions (`*const c_char`) or receiving C-written text into a mutable buffer (`*mut c_char`).
- **Pattern**:
  1. **Bind `CString` to a named local variable** so its lifetime spans the entire `unsafe` FFI call:

     ```rust
     let c_msg = std::ffi::CString::new(message)?;
     // SAFETY: `c_msg` outlives `c_set_error`, which only reads the pointer.
     unsafe { c_set_error(c_msg.as_ptr()) };
     ```

     **Critical Bug to Avoid**: Never write `unsafe { c_set_error(CString::new(message)?.as_ptr()) }`—the temporary `CString` drops before or during use, passing a dangling pointer!
  2. **Use `Vec<u8>` when C mutates the buffer**: Never pass `CString::into_raw` or cast `*const c_char` to `*mut c_char` if C modifies the length in place (violates `CString` invariants -> UB). Allocate `let mut buf = vec![0u8; cap];`, let C write into `buf.as_mut_ptr()`, truncate to written bytes, and convert via `CStr::from_bytes_until_nul` / `CString::new`.

### 4.4 Object-Based FFI APIs (`3.4.1`)

- **When to use**: Exporting stateful Rust subsystems to C, Python, Swift, or Go via C ABI.
- **Pattern**:
  - **Encapsulated State**: Keep stateful Rust structs **opaque** and **owned by Rust** on the heap (`Box::into_raw(Box::new(State::new()))`), exposing lifecycle functions (`mylib_open() -> *mut Handle`, `mylib_close(*mut Handle)` via `Box::from_raw`) and action functions taking `*mut Handle`.
  - **Transactional Payloads**: Keep input/output data transfer structs **transparent (`#[repr(C)]`)** and caller-managed with explicit ownership transfer rules.

### 4.5 Type Consolidation into Wrappers (`3.4.2`)

- **When to use**: Exporting Rust APIs with lifetime-coupled helper objects (such as collection iterators `Iter<'a>`) across FFI where C has no borrow checker.
- **Pattern**: Never export a separate raw-pointer iterator whose hidden lifetime borrows a parent handle—if the C caller mutates or closes the parent while the iterator exists, Rust's `&mut` aliasing exclusivity is violated (immediate UB). Instead, consolidate iteration or cursor state directly inside a wrapper struct (`struct SetHandle { set: MySet, cursor: usize }`) exposing `handle_first` / `handle_next` on the single opaque handle.
- **Trade-offs**: Limits the C API to one active cursor per wrapper (or explicit cursor IDs managed safely inside the wrapper), trading expressiveness for soundness against use-after-free and aliasing UB.
