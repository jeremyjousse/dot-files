---
description: Analyze and explain a Pull Request, audit technical quality, and sync insights to Obsidian
argument-hint: "[pr-number-or-url]"
---
Load and follow the `analyze-pr` skill for PR: ${@:-current branch PR}
Keep the project workspace read-only, never mutate PR state, and wait for explicit confirmation before writing Obsidian vault notes.
