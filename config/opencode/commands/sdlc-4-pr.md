---
description: Stage 5 Pull Request Gate - Push branch, create PR with repository template, and verify CI checks
argument-hint: '[issue-id]'
agent: sdlc-worker
---

Load and follow the `sdlc-pr` skill for issue: $ARGUMENTS

Never run `gh pr merge`. If no issue ID is provided, detect it from the active branch name.
