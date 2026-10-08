---
name: github
description:
  Use when reading, managing or updating User Stories (US), GitHub issues, or creating and managing Pull Requests (PR)
  with the gh CLI.
---

# GitHub CLI (`gh`) Workflow

Use `gh` (GitHub CLI) for all interactions with the GitHub remote repository, including User Stories (tracked as GitHub
Issues) and Pull Requests. All actions must comply with the 5-stage SDLC.

## Repository Inspection

- **View repository information**:

  ```bash
  rtk gh repo view
  ```

- **Inspect repository details in JSON format (e.g. owner and name)**:

  ```bash
  gh repo view --json owner,name
  ```

## User Stories (US) / GitHub Issues

In projects adhering to this SDLC, User Stories and tasks are tracked as GitHub Issues.

### Reading a US

- **View issue details**:

  ```bash
  rtk gh issue view <issue_number>
  ```

- **View issue with full discussion**:

  ```bash
  rtk gh issue view <issue_number> --comments
  ```

- **List active User Stories**:

  ```bash
  rtk gh issue list --state open --limit 20
  ```

- **Search for specific US**:

  ```bash
  rtk gh issue list --search "<keyword>"
  ```

### Updating a US

- **Post progress, design notes, or completion updates**:

  ```bash
  gh issue comment <issue_number> --body "Comment text"
  ```

- **Edit issue labels or assignees**:

  ```bash
  gh issue edit <issue_number> --add-label "<label>"
  ```

- **Close a completed US directly**:

  ```bash
  gh issue close <issue_number> --comment "Implemented in PR #..."
  ```

### GitHub Issue Labels

- **List available labels**:

  ```bash
  rtk gh label list
  ```

Standard status and type labels:

- **Status labels**:
  - `Status: Refinement :page_facing_up:` — Issue being scoped, questions asked.
  - `Status: To do :computer:` (or `Status: To do 💻`) — Issue refined, validated, ready for development (SDLC Stage 1
    gate).
  - `Status: In progress :construction:` — Active development underway (transitioned immediately upon branch creation in
    SDLC Stage 2).
  - `Status: Done :heavy_check_mark:` — Task completed.
  - `Status: Abandoned :no_entry:` — Canceled or superseded.
- **Type labels**:
  - `Type: Feature :gift:` — New features.
  - `Type: Bug :boom:` — Bug fixes.
  - `Type: Chore :broom:` — Maintenance, tooling, dependency updates, or chore tasks.
  - `Type: Idea :bulb:` — Concepts and ideas.

### Branch Creation Rule

- NEVER create or switch to a branch automatically.
- Do not propose or create a branch during an issue review/refinement request. Branch creation belongs to Stage 2 and
  requires an explicit instruction from the user to develop the issue.
- When development is requested, always propose the branch name first (e.g., `feat/<issue-id>-<name>`,
  `fix/<issue-id>-<name>`, `chore/<issue-id>-<name>`) and **wait for the user's explicit validation** before creating it
  (`git checkout -b <branch>`).
- **Issue Status Transition**: Immediately upon creating the branch and starting development, update the issue status
  label:

  ```bash
  gh issue edit <issue_number> --remove-label "Status: To do :computer:" --remove-label "Status: To do 💻" --add-label "Status: In progress :construction:"
  ```

### Commit Validation Rule (NEVER commit directly)

- DO NOT commit directly or automatically after code modifications or tests.
- Present `git status` and the list of modified/added files so the user has time to personally inspect them.
- Propose the conventional commit message (`feat: ...`, `fix: ...`, `refactor: ...`).
- **Wait for the user's explicit approval of the files and proposed commit message** before executing `git commit`.

---

## Pull Requests (PR)

### Pre-PR Checklist

1. Inspect git status and stage only relevant files:

   ```bash
   rtk git status
   rtk git diff
   rtk git log --oneline -5
   ```

2. Verify quality and tests (run `rtk mise run verify` or commands in `AGENTS.md`).
3. Push current branch to remote (only after explicit user confirmation):

   ```bash
   git push -u origin HEAD
   ```

### Creating a Pull Request

- Create the PR with Conventional Commit title and issue reference. If `.github/PULL_REQUEST_TEMPLATE.md` exists, GitHub
  CLI will leverage it:

  ```bash
  gh pr create --title "<type>(<scope>): <summary>" --body "$(cat <<'EOF'
  ## Summary
  - Brief description of the changes

  ## Related Issue / US
  Closes #<issue_number>
  EOF
  )"
  ```

- **Title conventions**: Match Conventional Commits (`feat: ...`, `fix: ...`, `refactor: ...`).
- **Return the PR URL** to the user upon creation.

### Monitoring & Reviewing PRs

- **Check PR status & diff**:

  ```bash
  rtk gh pr status
  rtk gh pr view
  rtk gh pr diff
  ```

- **Check CI workflow status**:

  ```bash
  rtk gh pr checks
  ```

- **Triage and resolve PR review comments**: For inspecting, triaging, replying to, and resolving PR review threads,
  load the `review-pr` skill.
