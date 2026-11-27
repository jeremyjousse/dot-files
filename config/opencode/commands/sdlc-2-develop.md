---
description: Stage 2 & 3 Development - Branch isolation and architecture-guided implementation
argument-hint: <issue-id-or-url>
agent: sdlc-worker
---

Load and follow the `sdlc-develop` skill for target issue: $ARGUMENTS

If `$ARGUMENTS` is empty, prompt for the GitHub issue number. Wait for explicit branch confirmation before checkout, never commit directly, and hand off to Stage 4 review when complete.
