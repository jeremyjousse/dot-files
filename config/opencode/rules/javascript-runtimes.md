# JavaScript / TypeScript Runtimes and Package Managers Policy

This policy defines the mandatory runtime and package manager conventions for all JavaScript and TypeScript projects
across all OpenCode sessions.

---

## Strict Prohibitions

1. **Bun is Strictly Forbidden**:
   - NEVER use, suggest, or execute `bun` or `bunx` (`bun install`, `bun add`, `bun run`, `bun test`, `bun create`,
     etc.).
   - NEVER generate or commit Bun-specific files (e.g. `bun.lockb`, `bunfig.toml`).
2. **Yarn is Strictly Forbidden**:
   - NEVER use, suggest, or execute `yarn` (`yarn install`, `yarn add`, `yarn run`, etc.).
   - NEVER generate or commit Yarn-specific files (e.g. `yarn.lock`, `.yarnrc`, `.yarnrc.yml`).

---

## Approved Runtimes and Package Managers

When executing scripts, managing dependencies, building, or scaffolding projects:

1. **Package Management**:
   - **Primary / Default**: Always use **`pnpm`** (`pnpm install`, `pnpm add`, `pnpm run <script>`, `pnpm dlx <pkg>`).
   - **Fallback**: Use **`npm`** only when a repository explicitly mandates `package-lock.json` and does not support
     `pnpm`.
2. **Runtime Execution**:
   - **Node.js**: Use **`node`** or `pnpm exec` / `npx` (e.g. `node script.js`, `pnpm exec tsx script.ts`).
   - **Deno**: Use **`deno`** (`deno run`, `deno test`, `deno task`, `deno check`, `deno fmt`, `deno lint`) when the
     project uses Deno or when standalone TypeScript execution without bundler configuration is desired.

---

## Project Initialization & Scaffolding

- When bootstrapping new projects or generating scripts, ALWAYS choose either **`pnpm`** (with Node.js) or **`deno`**.
- Do NOT initialize repositories with Bun or Yarn under any circumstances.
