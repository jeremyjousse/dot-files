---
description: Stage 5 Pull Request Gate - Push branch, create PR with repository template, and verify CI checks
agent: sdlc-pr-review
---

# Stage 5: Pull Request Creation Gate

You are executing **Stage 5 (Pull Request & Merge Gate - PR Creation)** of the SDLC.

## Target Issue / Arguments

Target: $ARGUMENTS

If no issue number is provided in `$ARGUMENTS`, detect the issue ID from the active git branch name (e.g.
`feat/<id>-...`, `fix/<id>-...`, `chore/<id>-...`).

## Operational Boundaries

- **No Direct Merge**: Automated PR merging is strictly denied (`gh pr merge` is forbidden). Merging is strictly
  reserved for manual human action once all checks pass.

## PR Creation Protocol

### 1. Pre-Flight Branch Check

- Verify the current git branch:

  ```bash
  git branch --show-current
  ```

- Confirm repository status if needed:

  ```bash
  rtk gh repo view
  ```

- Inspect target issue if needed to verify context, scope, and title details:

  ```bash
  rtk gh issue view <issue-id>
  ```

- Ensure development is NOT on `main`. If on `main`, stop immediately and warn the user.
- Verify working tree is clean (`git status`). If there are uncommitted changes, advise running `/sdlc-3-verify` first.

### 2. Push Branch to Remote

Push the current branch to origin:

```bash
git push -u origin HEAD
```

### 3. Create Pull Request

Create the PR using `gh pr create`:

- If `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/` files) exists in the repository, GitHub CLI
  will automatically use it or you can fill its sections:

  ```bash
  gh pr create --title "<type>(<scope>): <summary>"
  ```

- Otherwise, supply the standard template:

  ```bash
  gh pr create --title "<type>(<scope>): <summary>" --body "$(cat <<'EOF'
  ## Summary
  - Description of changes

  ## Related Issue / US
  Closes #<issue-id>
  EOF
  )"
  ```

### 4. CI Verification

- Display the PR URL to the user.
- Inspect the PR status and active CI checks:

  ```bash
  rtk gh pr status
  rtk gh pr checks
  ```

### 5. Next Steps

- Inform the user that the PR is open and CI checks are running.
- If review comments or feedback are requested, use `/sdlc-5-review-pr` to triage and resolve them.
- Remind the user that merge is strictly manual and human-controlled.
