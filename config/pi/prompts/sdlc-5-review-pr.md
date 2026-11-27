---
description: Stage 5 PR Review Loop - Fetch, triage, address review comments, and resolve conversation threads
argument-hint: "[pr-number-or-url]"
---
Load and follow the `review-pr` skill for PR: ${@:-current branch PR}
Present the full triage assessment and wait for explicit confirmation before editing files, committing, reacting, replying, or resolving threads. Never run `gh pr merge`.
