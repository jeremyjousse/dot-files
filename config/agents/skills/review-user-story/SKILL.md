---
name: review-user-story
description: Use when asked to review, analyze, or scope a User Story (GitHub Issue) before starting development.
---

# User Story Review Skill

This skill provides a systematic approach for reviewing a User Story (GitHub Issue) to ensure it is clear, properly
scoped, and aligned with project standards before implementation.

## Strict Scope Boundary: Review & Refinement ONLY (No Implementation)

**MANDATORY RULE**: When asked to review, analyze, or scope a User Story / GitHub Issue:

- The task is **STRICTLY limited to reviewing, improving, and updating the GitHub Issue**.
- **DO NOT** create a branch (`git checkout -b`).
- **DO NOT** edit or write any application code, tests, or project configuration files.
- **DO NOT** start implementation (Stage 2 / Stage 3 of SDLC).
- Transitioning to implementation requires a **separate, explicit user prompt** instructing to develop the issue.

## Review Process & Criteria

When asked to review a User Story (US) or GitHub Issue, you must analyze its content against the following structure and
guidelines:

### 1. Mandatory Sections, Language & Title

Verify that the User Story respects the following language, title, and structure criteria:

- **Language**:
  - MUST be written entirely in English.
  - If the issue was drafted in another language (e.g., French), translate and rewrite all sections and the title in English during
    refinement.
- **Issue Title**:
  - MUST be written in plain imperative English (e.g., `Add ...`, `Fix ...`, `Refine ...`, `Update ...`). Do NOT use Conventional Commit prefixes unless explicitly instructed.
  - Must be typo-free and use clean sentence casing without trailing punctuation.
  - Must accurately correlate with the core objective and deliverables defined in `## Tasks & scope`.
- **## context**:
  - Must exist.
  - Must be a maximum of 2 lines.
  - Must clearly explain the context and the "why" behind the task.
- **## Tasks & scope**:
  - Must exist.
  - Must contain a list of split tasks and their associated scopes.
  - Must take into account any platform/architecture constraints outlined in `AGENTS.md`.
- **## Out of Scope**:
  - Must exist.
  - Must list non-activated or excluded actions/features.

### 2. Alignment & Quality Check

- Check if the title and tasks listed under "Tasks & scope" are consistent with the "context".
- Check if the title accurately reflects the actual scope of work.
- Check if the scope is realistic, clear, and unambiguous.

---

## Action Plan based on Review Results

Based on your analysis, take the appropriate action below:

### Scenario A: The User Story is incomplete, ambiguous, or lacks detail

If the User Story is missing mandatory sections, has title issues (typos, casing, non-imperative phrasing, scope mismatch), has a context longer than 2 lines, or needs more clarification to be
actionable:

1. **Identify the gaps**: State clearly which sections, title elements, or details are missing or misaligned.
2. **Ask max 3 questions**: Formulate precisely three (~3) targeted questions to scope, clarify, and complete the User
   Story.
3. **Propose refined content**: Propose an improved title (in plain imperative English) and an English-written issue body adhering strictly to the 3 mandatory
   sections (`## context`, `## Tasks & scope`, `## Out of Scope`). Once validated by the user, update the issue:

   ```bash
   gh issue edit <issue_number> --title "<refined_title>" --body "<refined_body>" --remove-label "Status: Refinement :page_facing_up:" --add-label "Status: To do :computer:"
   ```

4. **Conclude review**: Stop once the issue is updated. Do NOT start implementation.

### Scenario B: The User Story is complete and well-aligned

If all sections are present, the context is <= 2 lines, tasks are clear, and out-of-scope items are defined:

1. **Title Check & Update**:

   - Verify that the issue title is written in plain imperative English, typo-free, and correlated with the scope.
   - If the title requires corrections, update it alongside the status label:

     ```bash
     gh issue edit <issue_number> --title "<refined_title>" --remove-label "Status: Refinement :page_facing_up:" --add-label "Status: To do :computer:"
     ```

   - If the title already meets all criteria, update only the status label:

     ```bash
     gh issue edit <issue_number> --remove-label "Status: Refinement :page_facing_up:" --add-label "Status: To do :computer:"
     ```

2. **Confirm Readiness**:

   - Declare that the User Story is fully scoped and ready for future development.

3. **Conclude Review**:
   - Inform the user that the review is finished and the issue is ready in the backlog.
   - **STOP HERE**: Do not propose or create a branch, and do not write any code until the user explicitly asks to start
     development.
