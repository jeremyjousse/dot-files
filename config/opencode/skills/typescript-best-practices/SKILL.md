---
name: typescript-best-practices
description: Use when designing, writing, reviewing, or refactoring TypeScript code to enforce Clean Code principles, strict typing conventions, and maintainability.
---

# TypeScript Best Practices Skill

This skill provides Clean Code principles, robust typing conventions, and maintainable software architecture patterns
for TypeScript development, adapted from *Clean Code TypeScript* and modern enterprise engineering standards.

---

## When to Apply This Skill

- Writing, modifying, or refactoring TypeScript code (`*.ts`, `*.tsx`, `*.mts`, `*.cts`).
- Architecting frontend or backend application layers, APIs, domain modules, and shared libraries.
- Establishing or reviewing type safety, interface contracts, and module boundaries.
- Conducting code reviews or pre-commit assessments for TypeScript projects.

---

## 1. Clean Naming & Variables

### Rule 1: Meaningful, Searchable & Pronounceable Names
- **Intention-Revealing Names**: Names must describe what a variable, function, or class represents and why it exists.
  ```typescript
  // Bad
  function between<T>(a1: T, a2: T, a3: T): boolean { return a2 <= a1 && a1 <= a3; }

  // Good
  function between<T>(value: T, min: T, max: T): boolean { return min <= value && value <= max; }
  ```
- **No Magic Values**: Extract numbers and repeated strings into named constants:
  ```typescript
  // Bad
  setTimeout(restart, 86400000);

  // Good
  const MILLISECONDS_PER_DAY = 24 * 60 * 60 * 1000;
  setTimeout(restart, MILLISECONDS_PER_DAY);
  ```
- **Consistent Vocabulary**: Use the same noun or verb for the same concept throughout the codebase (`getUser()` vs mixing `getUserData()`, `fetchUserRecord()`, `retrieveUserInfo()`).
- **Avoid Redundant Context**: If an object or class already specifies context, do not duplicate it in property names:
  ```typescript
  // Bad: car.carModel
  type Car = { carMake: string; carModel: string; };

  // Good: car.model
  type Car = { make: string; model: string; };
  ```

---

## 2. Functions & Composition

### Rule 2: Limit Function Parameters (2 or Fewer Ideally)
- When a function requires more than two arguments, consolidate them into a typed configuration object with destructuring:
  ```typescript
  // Bad
  function createMenu(title: string, body: string, buttonText: string, cancellable: boolean) { ... }

  // Good
  interface MenuOptions {
    title: string;
    body: string;
    buttonText: string;
    cancellable?: boolean;
  }
  function createMenu({ title, body, buttonText, cancellable = true }: MenuOptions) { ... }
  ```

### Rule 3: Single Responsibility & One Level of Abstraction
- A function should do exactly **one thing** and do it well.
- Split orchestration logic from low-level transformations, parsing, or I/O.
- **Do Not Use Boolean Flags as Arguments**: A boolean argument indicates the function performs two divergent branches. Split into two dedicated functions instead:
  ```typescript
  // Bad
  function createFile(name: string, isTemp: boolean) { ... }

  // Good
  function createFile(name: string) { ... }
  function createTempFile(name: string) { ... }
  ```

### Rule 4: Purity & Immutability
- Avoid side effects: do not mutate parameters passed by reference (arrays, objects). Return a new instance:
  ```typescript
  // Bad: mutates input
  function addItemToCart(cart: CartItem[], item: CartItem): void {
    cart.push(item);
  }

  // Good: pure transformation
  function addItemToCart(cart: readonly CartItem[], item: CartItem): CartItem[] {
    return [...cart, item];
  }
  ```
- Encapsulate conditional expressions into descriptive helper predicates:
  ```typescript
  // Bad
  if (subscription.isTrial && account.balance > 0 && !account.isFrozen) { ... }

  // Good
  if (canAccessFeature(subscription, account)) { ... }
  ```

---

## 3. Strict Type Safety & Modeling

### Rule 5: Strict Typing — Ban `any`
- Configure `tsconfig.json` with `"strict": true` (enforces `strictNullChecks`, `noImplicitAny`).
- Never use `any`. Use `unknown` when incoming data is unverified, and narrow using type guards, assertion functions, or schema validators (e.g., Zod, Valibot):
  ```typescript
  function parsePayload(input: unknown): UserPayload {
    if (isUserPayload(input)) {
      return input;
    }
    throw new ValidationError("Invalid payload structure");
  }
  ```
- Explicitly declare return types for public functions, exported APIs, and service methods to prevent unintended API drift.

### Rule 6: Discriminated Unions over Optional Soup
- Avoid wide types with numerous mutually exclusive optional properties. Model states explicitly with discriminated unions:
  ```typescript
  // Bad
  type AsyncState<T> = {
    isLoading: boolean;
    data?: T;
    error?: Error;
  };

  // Good
  type AsyncState<T> =
    | { status: 'idle' }
    | { status: 'loading' }
    | { status: 'success'; data: T }
    | { status: 'error'; error: Error };
  ```

### Rule 7: Immutability by Default
- Prefer `readonly` modifiers on properties and `ReadonlyArray<T>` (or `readonly T[]`) for arrays.
- Use `as const` assertions for literal configurations and tuple definitions:
  ```typescript
  const HTTP_METHODS = ['GET', 'POST', 'PUT', 'DELETE'] as const;
  type HttpMethod = (typeof HTTP_METHODS)[number];
  ```

### Rule 8: Type vs Interface Selection
- Use `interface` when defining object shapes intended for class implementation (`implements`) or public library contracts that may require declaration merging.
- Use `type` for unions, intersections, mapped types, tuples, primitive wrappers, and utility type expressions.

---

## 4. Object-Oriented & SOLID Principles

### Rule 9: SOLID Architecture
- **Single Responsibility (SRP)**: Each class or module should have one reason to change.
- **Open/Closed (OCP)**: Design modules open for extension, closed for modification (use polymorphic strategies or pluggable adapters).
- **Liskov Substitution (LSP)**: Subtypes must be substitutable for their base types without altering system correctness.
- **Interface Segregation (ISP)**: Clients should not be forced to depend upon methods they do not consume. Design focused, granular interfaces.
- **Dependency Inversion (DIP)**: High-level business logic must depend on abstractions (interfaces), not concrete implementations (database or HTTP clients).

### Rule 10: Prefer Composition over Inheritance
- Avoid deep inheritance hierarchies. Compose specialized collaborators via constructor dependency injection.
- Use TypeScript access modifiers (`private`, `protected`, `public`, `readonly`) to enforce encapsulation.

---

## 5. Asynchronous Operations & Error Strategy

### Rule 11: Async/Await & Robust Error Handling
- Use `async` / `await` instead of nested raw Promise callbacks (`.then()`, `.catch()`).
- Always handle errors explicitly. Never swallow errors in empty catch blocks:
  ```typescript
  // Bad
  try { await fetchData(); } catch (e) {}

  // Good
  try {
    await fetchData();
  } catch (error) {
    logger.error("Failed to fetch data", { cause: error });
    throw new ServiceUnavailableError("Upstream service is unreachable", { cause: error });
  }
  ```
- Create custom domain error classes extending `Error` to permit precise `instanceof` checks:
  ```typescript
  export class DomainError extends Error {
    constructor(message: string, options?: ErrorOptions) {
      super(message, options);
      this.name = this.constructor.name;
    }
  }
  ```

---

## 6. Pre-Commit & Review Quality Checklist

Before submitting TypeScript code for review or commit, verify:

- [ ] **Typecheck**: Runs cleanly under `tsc --noEmit` with zero errors.
- [ ] **No `any`**: Zero usage of `any`; all dynamic data is validated with `unknown` and type guards.
- [ ] **Immutability**: Readonly parameters and `as const` used for immutable structures.
- [ ] **Function Design**: Functions are small, pure where feasible, and have at most 2 parameters (or use an options object).
- [ ] **Error Handling**: No empty catch blocks; domain errors preserve error causes.
- [ ] **Lint & Format**: Passes the project linter (`oxlint` / `eslint`) and formatter (`oxfmt` / `prettier`).
