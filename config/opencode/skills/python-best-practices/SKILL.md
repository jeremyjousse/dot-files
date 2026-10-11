---
name: python-best-practices
description: Use when designing, writing, reviewing, or refactoring Python code in reliable, business-logic-complex projects to enforce strict typing, domain-driven architecture, and uv package management.
---

# Python Best Practices Skill

This skill provides idiomatic conventions, architecture principles, and reliability standards for mission-critical
Python applications with complex business logic, synthesizing modern Python standards (Python 3.12+), Domain-Driven
Design (DDD), Clean/Hexagonal Architecture, and the high-performance `uv` toolchain.

---

## When to Apply This Skill

- Designing, writing, reviewing, or refactoring Python applications (`*.py`, `pyproject.toml`, `uv.lock`).
- Architecting backend services, APIs, domain models, workflow engines, or transactional processing systems.
- Configuring or managing Python environments, dependencies, packaging, and execution using `uv`.
- Conducting code reviews or pre-commit checks for Python repositories.

---

## 1. Project & Dependency Management with `uv` (Universal Standard)

### Rule 1: Exclusively Standardize on `uv`
- **Single Tool Standard**: `uv` is the mandatory tool for all Python projects for environment management, dependency resolution, lockfile synchronization, and tool execution.
- **Strictly Prohibited**: Do **NOT** use `pip`, `poetry`, `pipenv`, `conda`, `virtualenv`, or manual activation scripts (`source .venv/bin/activate`).
- **Core Commands**:
  - Initialize project: `uv init --app <name>` or `uv init --lib <name>`
  - Add dependencies: `uv add <package>`
  - Add development dependencies: `uv add --dev <package>`
  - Remove dependencies: `uv remove <package>`
  - Synchronize environment: `uv sync`
  - Execute project scripts/tools: `uv run <command>` (e.g. `uv run pytest`, `uv run ruff check`)
  - Run standalone ephemeral tools: `uvx <tool>` (e.g. `uvx ruff check .`)

### Rule 2: PEP 621 Standards & Declarative `pyproject.toml`
- Keep `pyproject.toml` as the single source of truth for project metadata, dependencies, build backends (prefer `hatchling`), and tool configurations (`ruff`, `mypy`, `pytest`).
- Explicitly pin the minimum supported Python version in `.python-version` and `pyproject.toml`:
  ```toml
  [project]
  name = "billing-service"
  version = "0.1.0"
  description = "Reliable subscription and billing engine"
  readme = "README.md"
  requires-python = ">=3.12"
  dependencies = [
      "pydantic>=2.7.0",
      "sqlalchemy[asyncio]>=2.0.30",
  ]

  [dependency-groups]
  dev = [
      "mypy>=1.10.0",
      "pytest>=8.2.0",
      "pytest-asyncio>=0.23.0",
      "ruff>=0.4.0",
      "testcontainers>=4.4.0",
  ]

  [build-system]
  requires = ["hatchling"]
  build-backend = "hatchling.build"
  ```

### Rule 3: Deterministic Lockfiles & Hermetic Deployments
- **Always Commit `uv.lock`**: Application and service repositories must track `uv.lock` in source control to guarantee bit-for-bit reproducible installations across machines.
- **CI/CD and Production Containers**: Always synchronize using frozen dependencies without dev packages:
  ```bash
  uv sync --frozen --no-dev
  ```
- **Virtual Environment Hygiene**: Rely on `uv run` to automatically execute within the project virtual environment without manual shell environment mutations.

---

## 2. Strict Type Safety & Static Analysis

### Rule 4: Strict Typing as a Non-Negotiable Contract
- Configure static type checking (`mypy` or `pyright`) in strict mode:
  ```toml
  [tool.mypy]
  python_version = "3.12"
  strict = true
  disallow_untyped_defs = true
  disallow_incomplete_defs = true
  check_untyped_defs = true
  disallow_any_generics = true
  no_implicit_optional = true
  warn_redundant_casts = true
  warn_unused_ignores = true
  warn_return_any = true
  ```
- All public functions, methods, and domain properties must have explicit parameter and return type annotations.
- **Ban `Any` in Domain Logic**: Replace `Any` with `object`, bounded `TypeVar`, `typing.Generic`, or structural `typing.Protocol`. If unvalidated data enters the system, validate it at the boundary.

### Rule 5: Modern Python Type Syntax (3.10+)
- Use native collection generics (`list[str]`, `dict[str, int]`, `tuple[int, ...]`, `set[UUID]`). Avoid legacy imports from `typing` (`List`, `Dict`, `Tuple`, `Set`, `Optional`, `Union`).
- Use the union operator `|` instead of `Optional` or `Union`:
  ```python
  # Bad
  from typing import Optional, Union, List, Dict
  def find_accounts(query: Optional[str]) -> Union[List[str], Dict[str, str]]: ...

  # Good
  def find_accounts(query: str | None) -> list[str] | dict[str, str]: ...
  ```
- Use `typing.Self` for method return types representing the instance or builder return:
  ```python
  from typing import Self

  class AccountBuilder:
      def with_limit(self, limit: int) -> Self:
          self._limit = limit
          return self
  ```

### Rule 6: Structural Subtyping with Protocols
- Prefer `typing.Protocol` over nominal base classes (`abc.ABC`) for interfaces and collaborators. Protocols enable structural subtyping (duck typing verified statically) without forcing inheritance:
  ```python
  from typing import Protocol

  class PaymentGateway(Protocol):
      async def charge(self, account_id: str, amount_cents: int) -> str: ...
  ```
- Mark protocols with `@typing.runtime_checkable` only when runtime `isinstance` checks are strictly necessary.

### Rule 7: Runtime Boundary Validation vs. Static Types
- Maintain a strict boundary between static type hints (compile-time analysis) and runtime data validation.
- Use `pydantic` v2 (or `msgspec`) exclusively at system boundaries: HTTP request/response payloads, message broker events, configuration files, and external database adapters.
- **Never pass unvalidated raw `dict` objects into domain entities or business logic functions.** Parse and validate into typed schemas first.

---

## 3. Domain Modeling & Architecture for Complex Business Logic

### Rule 8: Clean / Hexagonal Architecture (Ports & Adapters)
- **Dependency Rule**: Dependencies always point inward toward the core domain. The domain core must have ZERO dependencies on frameworks, databases, or infrastructure libraries:
  - **Domain Core**: Pure business entities, value objects, domain events, domain exceptions, and port interfaces (`Protocol`). No imports of FastAPI, SQLAlchemy, Redis, Boto3, or HTTP libraries.
  - **Application / Use Case Layer**: Orchestrates domain entities and ports to execute business scenarios (e.g., `RegisterUserUseCase`, `ProcessInvoiceUseCase`).
  - **Infrastructure Adapters**: Concrete implementations of domain ports (e.g., `PostgresOrderRepository`, `StripePaymentGateway`, `FastAPIRouter`).

```
┌────────────────────────────────────────────────────────┐
│ Infrastructure (FastAPI, SQLAlchemy, Redis, CLI)      │
│   ┌──────────────────────────────────────────────────┐ │
│   │ Application Services / Use Cases                │ │
│   │   ┌────────────────────────────────────────────┐ │ │
│   │   │ Pure Domain Core (Entities, Value Objects) │ │ │
│   │   └────────────────────────────────────────────┘ │ │
│   └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

### Rule 9: Rich Domain Models vs. Anemic Data Models
- **Encapsulate Behavior**: Place business rules, validation invariants, and state transitions inside entities and aggregates—not in procedural service functions.
- **Make Illegal State Unrepresentable**: Prevent entities from ever existing in an invalid state. Validate invariants in constructors and guard state changes:
  ```python
  # Bad: Anemic model with external logic
  class Order:
      status: str
      items: list[Item]

  def cancel_order(order: Order) -> None:
      if order.status == "shipped":
          raise ValueError("Cannot cancel shipped order")
      order.status = "cancelled"

  # Good: Rich domain model encapsulating invariants
  class Order:
      def __init__(self, order_id: OrderId, items: list[OrderItem]) -> None:
          if not items:
              raise EmptyOrderError("An order must contain at least one item")
          self._id = order_id
          self._items = list(items)
          self._status = OrderStatus.PENDING

      def cancel(self, reason: str) -> None:
          if self._status is OrderStatus.SHIPPED:
              raise OrderCancellationError(f"Cannot cancel order {self._id} because it is already shipped")
          self._status = OrderStatus.CANCELLED
  ```

### Rule 10: Value Objects & Primitive Obsession Prevention
- Replace raw primitive types (`str`, `int`, `float`, `UUID`) with dedicated Value Objects or `NewType`:
  - **Value Objects**: Immutable, identityless concepts compared strictly by value:
    ```python
    from dataclasses import dataclass

    @dataclass(frozen=True, slots=True)
    class Money:
        amount_cents: int
        currency: str

        def __post_init__(self) -> None:
            if self.amount_cents < 0:
                raise NegativeAmountError("Amount cannot be negative")

        def add(self, other: "Money") -> "Money":
            if self.currency != other.currency:
                raise CurrencyMismatchError(f"Cannot add {self.currency} and {other.currency}")
            return Money(self.amount_cents + other.amount_cents, self.currency)
    ```
  - **NewType**: Use `NewType` when wrapping an identifier to prevent accidental transposition:
    ```python
    from typing import NewType
    from uuid import UUID

    UserId = NewType("UserId", UUID)
    OrderId = NewType("OrderId", UUID)
    ```
- Use `enum.StrEnum` (Python 3.11+) or `enum.Enum` for discrete sets of domain states instead of arbitrary string literals.

### Rule 11: Unit of Work & Transactional Boundaries
- Encapsulate database transactions with an asynchronous Unit of Work pattern (`async with uow:`).
- Repositories should operate within the transaction managed by the Unit of Work. Do not commit transactions inside individual repository methods:
  ```python
  class UnitOfWork(Protocol):
      orders: OrderRepository
      customers: CustomerRepository

      async def __aenter__(self) -> Self: ...
      async def __aexit__(self, exc_type: object, exc_val: object, exc_tb: object) -> None: ...
      async def commit(self) -> None: ...
      async def rollback(self) -> None: ...
  ```

---

## 4. Robust Error Handling & Defensive Programming

### Rule 12: Explicit Domain Exception Hierarchies
- Create custom domain exception hierarchies inheriting from a base `DomainError(Exception)`.
- Distinguish business invariant violations from unexpected infrastructure failures:
  ```python
  class DomainError(Exception):
      """Base error for all domain rule violations."""

  class EntityNotFoundError(DomainError):
      """Raised when an aggregate root is not found."""

  class InsufficientFundsError(DomainError):
      def __init__(self, required_cents: int, available_cents: int) -> None:
          super().__init__(
              f"Insufficient funds: required {required_cents} cents, but only {available_cents} available"
          )
          self.required_cents = required_cents
          self.available_cents = available_cents
  ```

### Rule 13: Exception Translation & Traceback Preservation
- Translate low-level infrastructure exceptions (e.g. `asyncpg.PostgresError`, `httpx.HTTPError`) into domain or application exceptions at adapter boundaries.
- **Always preserve original exceptions with `from exc`**:
  ```python
  # Bad: Drops context and original stack trace
  try:
      await db.execute(...)
  except DatabaseConnectionError:
      raise RepositoryUnavailableError("Database unavailable")

  # Good: Preserves root cause and diagnostic traceback
  try:
      await db.execute(...)
  except DatabaseConnectionError as err:
      raise RepositoryUnavailableError("Failed to persist order") from err
  ```
- **Never swallow exceptions**: Avoid bare `except:` or `except Exception: pass`. Catch specific exceptions and log or re-raise appropriately.

### Rule 14: Result Patterns for Expected Business Outcomes
- For expected business branching where failure is a standard alternative path (e.g. form validation failure, credit limit reached), consider returning an explicit `Result[T, E]` type rather than throwing heavy exceptions for normal control flow.

---

## 5. Asynchronous Concurrency & Resilience

### Rule 15: Structured Concurrency with `asyncio.TaskGroup`
- Always use `asyncio.TaskGroup` (Python 3.11+) instead of unmanaged `asyncio.create_task()` or `asyncio.gather()`. If any child task fails, the remaining tasks are automatically cancelled:
  ```python
  # Bad: Unhandled task failure leaves tasks dangling
  tasks = [asyncio.create_task(fetch_a()), asyncio.create_task(fetch_b())]
  results = await asyncio.gather(*tasks)

  # Good: Structured concurrency with automatic cleanup on failure
  async with asyncio.TaskGroup() as tg:
      task1 = tg.create_task(fetch_a())
      task2 = tg.create_task(fetch_b())

  result1 = task1.result()
  result2 = task2.result()
  ```

### Rule 16: Non-Blocking Event Loop Hygiene
- **Never run blocking I/O inside async functions**: File system access, synchronous database drivers, or synchronous HTTP clients (`requests`) freeze the event loop.
- Offload unavoidable synchronous or CPU-intensive operations using `asyncio.to_thread()`:
  ```python
  result = await asyncio.to_thread(cpu_intensive_hashing, password)
  ```
- Always set explicit timeouts on external asynchronous I/O calls:
  ```python
  async with asyncio.timeout(5.0):
      response = await client.get(url)
  ```

### Rule 17: Resource Lifecycle & Cancellation Safety
- Acquire and release connections, pools, and locks exclusively using asynchronous context managers (`async with`).
- Allow `asyncio.CancelledError` to propagate cleanly. Perform cleanup in `finally:` blocks or context managers rather than catching and suppressing cancellation.

---

## 6. Code Quality, Tooling & Formatting (Ruff Standard)

### Rule 18: Standardize on `ruff` for Linting & Formatting
- Use `ruff` exclusively to replace `flake8`, `black`, `isort`, `pylint`, and `pyupgrade`.
- Standard configuration in `pyproject.toml`:
  ```toml
  [tool.ruff]
  target-version = "py312"
  line-length = 120

  [tool.ruff.lint]
  select = [
      "E",    # pycodestyle errors
      "W",    # pycodestyle warnings
      "F",    # pyflakes
      "I",    # isort (import ordering)
      "B",    # flake8-bugbear (common bug patterns)
      "N",    # pep8-naming
      "UP",   # pyupgrade (modern python syntax)
      "SIM",  # flake8-simplify
      "TCH",  # flake8-type-checking (imports in TYPE_CHECKING)
      "RUF",  # ruff-specific rules
  ]
  ignore = ["E501"] # Line length handled by formatter

  [tool.ruff.format]
  quote-style = "double"
  indent-style = "space"
  ```

### Rule 19: Import Organization & Type Guarding
- Place type-only imports inside `if TYPE_CHECKING:` guards to prevent circular imports and optimize runtime startup performance:
  ```python
  from typing import TYPE_CHECKING

  if TYPE_CHECKING:
      from billing.domain.models import Invoice
  ```

---

## 7. Testing Strategy for Business-Critical Systems

### Rule 20: The Testing Pyramid for Complex Business Logic
- **Pure Domain Unit Tests**:
  - Test domain entities, value objects, and business rules without mocks, databases, or network calls.
  - Execute in milliseconds under `uv run pytest`.
- **Integration Tests**:
  - Test repository and adapter implementations against real backing services (e.g., PostgreSQL, Redis) using `testcontainers-python`.
  - Avoid using SQLite as a test surrogate for PostgreSQL to eliminate dialect discrepancies.
- **End-to-End / API Contract Tests**:
  - Verify complete use case flows through HTTP test clients with database transactions rolled back after each test.

### Rule 21: Table-Driven Testing & Invariant Verification
- Use `@pytest.mark.parametrize` for table-driven edge case verification:
  ```python
  @pytest.mark.parametrize(
      ("amount", "rate", "expected"),
      [
          (1000, Decimal("0.20"), 200),
          (0, Decimal("0.20"), 0),
          (1500, Decimal("0.05"), 75),
      ],
  )
  def test_calculate_tax(amount: int, rate: Decimal, expected: int) -> None:
      tax = calculate_tax(Money(amount, "EUR"), rate)
      assert tax.amount_cents == expected
  ```
- Use property-based testing with `hypothesis` for financial formulas and mission-critical invariants to catch unforeseen edge cases across large input spaces.

---

## 8. Pre-Commit & Code Review Checklist

Before submitting Python code for review or commit, verify:

- [ ] **Package Management**: Standardized exclusively on `uv`; dependencies managed via `uv add` and committed in `uv.lock`.
- [ ] **Formatting**: Passes `uv run ruff format --check .` cleanly.
- [ ] **Linting**: Passes `uv run ruff check .` with zero errors or unhandled warnings.
- [ ] **Type Safety**: Passes `uv run mypy .` (or `pyright`) in strict mode with zero `Any` in domain logic.
- [ ] **Domain Purity**: Domain core entities and value objects have no imports of infrastructure or external frameworks.
- [ ] **Invariants Encapsulated**: Business logic is encapsulated in rich domain models; value objects are immutable (`frozen=True`).
- [ ] **Error Handling**: Domain exceptions inherit from a base domain error; low-level errors are chained with `from err`.
- [ ] **Concurrency**: Async functions avoid blocking I/O; timeouts bound all network operations; tasks use `TaskGroup`.
- [ ] **Tests**: Unit and integration test suites pass cleanly under `uv run pytest`.
