---
name: svelte-best-practices
description: Use when developing, reviewing, or refactoring Svelte 5 and SvelteKit applications with modern runes reactivity, component design, and state management.
---

# Svelte Best Practices Skill

This skill provides modern architectural patterns, runes-based reactivity standards, and full-stack SvelteKit
conventions for Svelte 5 applications.

---

## When to Apply This Skill

- Developing, modifying, or reviewing Svelte 5 components (`*.svelte`) and SvelteKit modules (`+page.svelte`, `+page.server.ts`, `+server.ts`).
- Migrating legacy Svelte 3/4 code (`export let`, reactive declarations `$:`, writable stores) to Svelte 5 runes.
- Designing component hierarchies, shared state stores, and context providers.
- Reviewing UI performance, accessibility (a11y), and SSR hydration boundaries.

---

## 1. Svelte 5 Runes Reactivity System

### Rule 1: Master the Core Runes
- **Local State (`$state`)**: Use `$state()` for reactive variables and objects. Svelte 5 proxies provide fine-grained, deep reactivity:
  ```svelte
  <script lang="ts">
    let count = $state(0);
    let user = $state({ name: 'Ada', preferences: { theme: 'dark' } });
  </script>
  ```
- **Derived State (`$derived` / `$derived.by`)**:
  - Always use `$derived()` for computed values that depend on other state.
  - Use `$derived.by(() => { ... })` for multi-statement or complex calculations.
  - **Never use `$effect()` to synchronize or compute derived state.**
- **Component Props (`$props`)**:
  - Declare props via destructured `$props()` with TypeScript interfaces:
    ```svelte
    <script lang="ts">
      interface Props {
        title: string;
        initialCount?: number;
        onchange?: (val: number) => void;
      }
      let { title, initialCount = 0, onchange }: Props = $props();
    </script>
    ```
- **Two-Way Binding (`$bindable`)**:
  - Prop bindings are opt-in. Mark bindable props explicitly using `$bindable()`:
    ```svelte
    <script lang="ts">
      let { value = $bindable('') }: { value?: string } = $props();
    </script>
    ```

### Rule 2: Disciplined Effect Management
- Use `$effect()` **strictly for side effects** (DOM manipulation, logging, syncing with external non-Svelte libraries, timers).
- Return a cleanup function from `$effect()` whenever creating subscriptions, timers, intervals, or DOM event listeners to prevent memory leaks:
  ```svelte
  <script lang="ts">
    $effect(() => {
      const timer = setInterval(tick, 1000);
      return () => clearInterval(timer);
    });
  </script>
  ```
- Use `$effect.pre()` when operations must execute *before* DOM mutations (e.g. capturing scroll positions).
- Use `untrack()` to read reactive values inside an effect without establishing unwanted reactivity subscriptions.

---

## 2. Modern Component Architecture & Composition

### Rule 3: Snippets over Legacy Slots
- Svelte 5 replaces slots (`<slot />`, `let:prop`) with first-class `{#snippet}` blocks and the `{@render}` tag.
- Accept children and template fragments as typed `Snippet` props:
  ```svelte
  <!-- Card.svelte -->
  <script lang="ts">
    import type { Snippet } from 'svelte';

    interface Props {
      header?: Snippet;
      children?: Snippet;
      footer?: Snippet<[{ status: string }]>;
    }
    let { header, children, footer }: Props = $props();
  </script>

  <div class="card">
    {#if header}
      <header>{@render header()}</header>
    {/if}
    <main>{@render children?.()}</main>
    {#if footer}
      <footer>{@render footer({ status: 'ready' })}</footer>
    {/if}
  </div>
  ```

### Rule 4: Dynamic Components
- In Svelte 5, components are dynamic by default. `<svelte:component this={...}>` is deprecated.
- Assign the imported component reference directly to a capitalized variable and render `<CurrentComponent />`.

### Rule 5: DOM Integration & Actions
- Prefer attachments (`{@attach}`, Svelte 5.29+) or actions (`use:action`) to encapsulate imperative DOM integrations.
- Always provide destruction/teardown handlers in actions to clean up event listeners and third-party instances.

---

## 3. State Management & SSR Safety

### Rule 6: Context API for Shared Tree State
- Avoid global mutable module state (e.g. `export const shared = $state(...)`) for state that varies per session in SSR applications, as it leaks data between concurrent HTTP requests.
- Use Svelte's Context API (`setContext`, `getContext`) encapsulated in type-safe helper functions:
  ```typescript
  // context.ts
  import { getContext, setContext } from 'svelte';

  const CONTEXT_KEY = Symbol('user-session');

  export function setUserContext(session: UserSession) {
    setContext(CONTEXT_KEY, session);
  }

  export function getUserContext(): UserSession {
    const ctx = getContext<UserSession>(CONTEXT_KEY);
    if (!ctx) throw new Error('UserContext not found in component ancestor hierarchy');
    return ctx;
  }
  ```

### Rule 7: SvelteKit State
- Read SvelteKit application and navigation state from `$app/state` (`page`, `navigating`, `updated`) rather than the legacy `$app/stores`.

---

## 4. SvelteKit Full-Stack Patterns

### Rule 8: Data Loading and Form Actions
- Use `+page.server.ts` or `+layout.server.ts` for secure backend data fetching (credentials, database, internal APIs).
- Use universal `+page.ts` only when fetching public data or when client-side navigation caching is desired.
- Handle mutations via SvelteKit **Form Actions** in `+page.server.ts` with progressive enhancement (`use:enhance`):
  ```svelte
  <form method="POST" action="?/updateProfile" use:enhance>
    <input name="displayName" bind:value={name} required />
    <button type="submit">Save</button>
  </form>
  ```

### Rule 9: Error Boundaries
- Implement route-level `+error.svelte` for unhandled route errors.
- Use `<svelte:boundary>` to catch and isolate component subtree rendering errors gracefully with a fallback snippet without breaking the entire page.

---

## 5. Performance, Accessibility & Styling

### Rule 10: Performance Optimization
- **Keyed `{#each}`**: Always provide a unique identifier key to `{#each items as item (item.id)}` to avoid inefficient DOM diffing and DOM recycling bugs.
- **Tree-shaking**: Prefer granular imports over importing entire component libraries.

### Rule 11: Accessibility (a11y) First
- Do not suppress Svelte compiler a11y warnings with `svelte-ignore` comments without documented architectural justification.
- Ensure interactive elements are keyboard accessible, have appropriate ARIA attributes (`aria-label`, `aria-expanded`), and respect semantic HTML hierarchy.

---

## 6. Pre-Commit & Review Quality Checklist

Before submitting Svelte code for review or commit, verify:

- [ ] **Typecheck**: Passes `svelte-check --tsconfig ./tsconfig.json` with zero errors.
- [ ] **Runes Usage**: No legacy `export let` or `$:`; all reactivity uses `$state`, `$derived`, `$props`.
- [ ] **Effects**: No `$effect()` used for derived calculations; cleanup handlers present on effects that allocate resources or subscriptions.
- [ ] **Snippets**: Uses `{#snippet}` and `{@render}` instead of legacy slots.
- [ ] **SSR Safety**: No global mutable state in module scope for SSR projects.
- [ ] **Accessibility**: Zero unhandled compiler a11y warnings.
