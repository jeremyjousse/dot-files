---
description: Stage 1 Refinement Gate - Review, clarify, and refine a GitHub issue before development
agent: sdlc-refine
---

# Stage 1: User Story & Issue Refinement Gate

You are executing **Stage 1 (User Story & Issue Refinement Gate)** of the SDLC.

## Target Issue

Target: $ARGUMENTS

If no issue number or URL was provided above, prompt the user for the target GitHub issue number.

## Operational Boundaries

- **Strictly Read-Only for Code**: Do NOT create branches (`git checkout -b`), write application code, or start
  implementation.
- **Scope Confined to Stage 1**: This command is strictly confined to reviewing, analyzing, and refining the target
  GitHub Issue. Transitioning to implementation requires running `/sdlc-2-develop`.

## Refinement Instructions

1. **Extract Issue ID**: Parse the numeric issue ID from `$ARGUMENTS` (e.g. from `42`, `#42`, or
   `https://github.com/<owner>/<repo>/issues/42`).

2. **Inspect Issue via GitHub CLI**: Run:

   ```bash
   rtk gh issue view <issue-id>
   ```

3. **Verify Refinement Gate Criteria**:

   - **Mandatory Language**: All GitHub issues MUST be written entirely in English. If the issue is in another language
     (e.g., French), translate and rewrite all sections in English during refinement.
   - **Mandatory Label**: The issue MUST have the label `Status: To do :computer:` (or `Status: To do 💻`). If the issue
     has `Status: Refinement :page_facing_up:` or lacks `Status: To do :computer:`, it requires refinement.
   - **Mandatory Sections**:
     - `## context`: Maximum 2 lines explaining the "why".
     - `## Tasks & scope`: Clear, split tasks and explicit scope boundaries.
     - `## Out of Scope`: Explicitly excluded features and actions.

4. **Action Protocol**:

   - **If the issue is incomplete, ambiguous, or lacks detail**:

     1. Load the `review-user-story` skill for refinement guidance.
     2. Clearly state which sections or details are missing or misaligned.
     3. Formulate at most three (<= 3) concise, targeted questions to clarify scope, requirements, or platform behavior.
     4. Propose an improved, English-written issue body adhering strictly to the 3 mandatory sections.
     5. Once the user validates the proposal, update the issue on GitHub:

        ```bash
        gh issue edit <issue-id> --body "<refined_body>" --remove-label "Status: Refinement :page_facing_up:" --add-label "Status: To do :computer:"
        ```

   - **If the issue is complete and meets all criteria**:

     1. Confirm that the issue passes all Refinement Gate criteria.
     2. If `Status: Refinement :page_facing_up:` is present, update the label to `Status: To do :computer:`:

        ```bash
        gh issue edit <issue-id> --remove-label "Status: Refinement :page_facing_up:" --add-label "Status: To do :computer:"
        ```

     3. Inform the user that the review is complete and the issue is ready in the backlog.

5. **Conclude**: Stop here. Do NOT propose branch creation or write any code.
