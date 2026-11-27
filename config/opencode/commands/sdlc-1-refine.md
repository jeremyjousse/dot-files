---
description: Stage 1 Refinement Gate - Review, clarify, and refine a GitHub issue before development
argument-hint: <issue-id-or-url>
agent: sdlc-readonly
---

Load and follow the `review-user-story` skill for target issue: $ARGUMENTS

If `$ARGUMENTS` is empty, prompt for the GitHub issue number. Strictly confine this run to Stage 1 issue refinement (no branches, no code edits).
