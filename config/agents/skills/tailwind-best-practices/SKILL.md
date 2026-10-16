---
name: tailwind-best-practices
description: Use when styling, designing, reviewing, or refactoring user interfaces with Tailwind CSS (especially v4+), including modern theme tokens, responsive layouts, and utility architecture.
---

# Tailwind CSS Best Practices Skill

This skill provides guidelines, design system patterns, and architectural conventions for modern Tailwind CSS (v4+)
development across frontend applications.

---

## When to Apply This Skill

- Authoring, refactoring, or reviewing markup and styles using Tailwind CSS in modern web frameworks (React, Svelte, Vue, Astro, HTML).
- Configuring or migrating projects to Tailwind CSS v4+ using `@tailwindcss/vite` or modern bundler integrations.
- Structuring design tokens, typography scales, color palettes, and theme variables.
- Ensuring responsive layouts, accessibility (a11y), dark mode, and fluid user interfaces.

---

## 1. Tailwind CSS v4 Architecture & Configuration

### Rule 1: Embrace CSS-First Configuration
- **Modern Import**: Use `@import "tailwindcss";` to import Tailwind CSS instead of legacy directives (other valid CSS or font imports may still accompany it as needed).
  - ❌ Do **not** use deprecated `@tailwind base; @tailwind components; @tailwind utilities;` directives.
  - ❌ Do **not** create `tailwind.config.js` or `postcss.config.js` when using modern Vite / framework plugins unless strictly required for legacy integrations.
- **Theme Customization via `@theme`**: Define custom tokens, colors, fonts, and dimensions directly in CSS:
  ```css
  @import "tailwindcss";

  @theme {
    --color-brand-50: #eff6ff;
    --color-brand-500: #3b82f6;
    --color-brand-600: #2563eb;
    --font-sans: 'Inter', system-ui, sans-serif;
    --radius-card: 0.75rem;
  }
  ```

### Rule 2: Custom Utilities & Variants in CSS
- Define custom utility classes using the `@utility` directive:
  ```css
  @utility content-auto {
    content-visibility: auto;
  }

  @utility scrollbar-none {
    scrollbar-width: none;
    &::-webkit-scrollbar {
      display: none;
    }
  }
  ```
- Define composite or custom variants using `@custom-variant`:
  ```css
  @custom-variant hocus (&:hover, &:focus-visible);
  ```

---

## 2. Responsive Design & Layout Architecture

### Rule 3: Mobile-First Responsive Breakpoints
- Always design mobile-first: write default styles for the smallest viewport without prefixes, and layer responsive modifiers (`sm:`, `md:`, `lg:`, `xl:`, `2xl:`) as screen width increases.
  ```html
  <!-- Good: Mobile stacked, desktop side-by-side -->
  <div class="flex flex-col gap-4 md:flex-row md:items-center">
  ```
- **Never** use responsive prefixes to override desktop styles for mobile (avoid desktop-first hacks).

### Rule 4: Container Queries for Component Modularity
- Use container queries when component appearance depends on its parent container's width rather than the browser viewport:
  ```html
  <div class="@container">
    <div class="flex flex-col @md:flex-row @md:items-center gap-4">
      <!-- Layout adapts dynamically to container size -->
    </div>
  </div>
  ```

### Rule 5: Modern Grid & Flexbox
- Use CSS Grid (`grid grid-cols-1 md:grid-cols-3 gap-6`) for 2D card lists and structured content grids.
- Use Flexbox (`flex items-center justify-between`) for 1D alignments, headers, toolbars, and badges.
- Prefer `gap-*` utilities for consistent spacing between children rather than manual margin overrides (`mb-*` or `mr-*`).

---

## 3. Utility Organization & Dynamic Classes

### Rule 6: Consistent Class Ordering
Follow a logical, consistent sequence when ordering utility classes:
1. **Layout & Positioning**: `relative`, `absolute`, `top-0`, `flex`, `grid`, `col-span-2`
2. **Box Model & Sizing**: `w-full`, `max-w-md`, `h-10`, `p-4`, `m-2`
3. **Typography**: `font-sans`, `text-sm`, `font-semibold`, `tracking-wide`, `text-center`
4. **Visuals & Decoration**: `bg-white`, `text-gray-900`, `rounded-lg`, `border`, `shadow-sm`
5. **Interactive & State Variants**: `hover:bg-gray-100`, `focus-visible:ring-2`, `disabled:opacity-50`, `dark:bg-gray-800`

### Rule 7: Dynamic Classes and Component Variants
- Avoid string concatenation or template literal hacking for conditional classes.
- Use [`clsx`](https://github.com/lukeed/clsx) and [`tailwind-merge`](https://github.com/dcastil/tailwind-merge) to safely resolve conflicting utility classes:
  ```typescript
  import { clsx, type ClassValue } from 'clsx';
  import { twMerge } from 'tailwind-merge';

  export function cn(...inputs: ClassValue[]): string {
    return twMerge(clsx(inputs));
  }
  ```
- For reusable UI components with variants (e.g., button sizes and intents), use [`cva`](https://cva.style/docs) (class-variance-authority).

### Rule 8: Avoid Overuse of `@apply`
- Keep utilities in markup / template files to preserve the benefits of utility-first CSS (tree-shaking, fast refactoring, local reasoning).
- Extract reusable logic into template components (React/Svelte/Vue components) rather than writing massive custom CSS classes with `@apply`.

### Rule 9: Avoid Arbitrary Values Where Tokens Exist
- Avoid arbitrary values like `p-[17px]` or `text-[#3b82f6]` when standard scale utilities (`p-4`) or theme tokens (`text-brand-500`) exist.
- Use arbitrary values (`w-[calc(100%-2rem)]`) only for exceptional, highly specific geometry constraints.

---

## 4. Accessibility (a11y), States & Dark Mode

### Rule 10: Accessible Interactive States
- **Focus Rings**: Always provide high-contrast, accessible focus indicators on interactive elements:
  ```html
  <button class="focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-600 focus:outline-none">
  ```
- **Screen Reader Support**: Use `sr-only` to visually hide descriptive text that remains available to assistive technologies:
  ```html
  <button>
    <TrashIcon class="size-5" />
    <span class="sr-only">Delete item</span>
  </button>
  ```
- **Motion Reduction**: Respect user preferences for reduced motion:
  ```html
  <div class="transition-transform motion-reduce:transition-none">
  ```

### Rule 11: Dark Mode Strategy
- Design color schemes using paired semantic classes (`bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100`).
- Ensure contrast ratios meet WCAG AA standards in both light and dark modes.

---

## 5. Pre-Commit & Review Quality Checklist

Before submitting templates or stylesheets for review or commit, verify:

- [ ] **Tailwind v4 Conventions**: Uses `@import "tailwindcss";` and `@theme`; no outdated `@tailwind` directives or unnecessary config files.
- [ ] **Mobile-First**: Unprefixed base classes style mobile; responsive prefixes handle larger screens.
- [ ] **Spacing & Layout**: Uses `gap-*` rather than manual directional margins for collections.
- [ ] **Accessibility**: Focus rings (`focus-visible:ring-*` or `focus-visible:outline-*`) present on all interactive elements.
- [ ] **No Dead Arbitrary Values**: Design tokens used instead of hardcoded hex colors or arbitrary pixel values.
- [ ] **Dynamic Class Safety**: Dynamic classes merged safely via `twMerge` / `clsx` without collision bugs.
