# RTK (Rust ToolKit) Token Optimization Guidelines

RTK is installed globally as a high-performance CLI proxy to filter and summarize system output before it enters LLM
context, reducing token usage and speeding up agent responses.

## General Guidance

- Whenever running shell commands via `bash`, prefer routing supported commands through `rtk`:
  - **Git**: `rtk git status`, `rtk git diff`, `rtk git log`
  - **GitHub CLI**: `rtk gh pr status`, `rtk gh pr checks`, `rtk gh issue view`, `rtk gh pr diff`
  - **Package & Task Managers**: `rtk pnpm <cmd>`, `rtk cargo <cmd>`, `rtk mise <cmd>`
  - **Testing**: `rtk test`, `rtk pytest`, `rtk vitest`, `rtk cargo test`
  - **Search & Inspection**: `rtk rg <pattern>`, `rtk read <file>`, `rtk err <cmd>`
- Although the OpenCode RTK plugin automatically intercepts and rewrites raw commands, agents should proactively use
  `rtk` prefixes.
