---
name: sdlc-pr
description: Execute SDLC Stage 5 pull request creation by checking branch state, pushing, opening a PR referencing the issue, and inspecting CI.
---

# SDLC Pull Request Creation Skill (Stage 5)

Use this skill to push a completed development branch, create a Pull Request linked to the target issue, and verify CI checks.

---

## Guardrails

- **No Direct Merge**: NEVER run `gh pr merge`. Merging is strictly reserved for human action once checks pass.
- **No Uncommitted Changes**: Ensure the working tree is clean before pushing or opening a PR.

---

## Execution Protocol

1. **Pre-Flight Check**:
   - Determine the issue ID from the argument or active branch name (e.g. `feat/<id>-...`, `fix/<id>-...`, `chore/<id>-...`).
   - Verify active branch is NOT `main`:

     ```bash
     git branch --show-current
     ```

     If on `main`, stop immediately and warn the user.
   - Verify working tree is clean (`rtk git status`). If uncommitted changes exist, hand off to Stage 4 verification (`code-review`) first.
   - Inspect repository/issue context if needed (`rtk gh repo view`, `rtk gh issue view <issue-id>`).
2. **Push Branch to Remote**:

   ```bash
   git push -u origin HEAD
   ```

3. **Create Pull Request**:
   - If `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`) exists, populate its sections; otherwise use the standard body:

     ```bash
     gh pr create --title "<type>(<scope>): <summary>" --body-file - <<'EOF'
     ## Summary
     - Description of changes

     ## Related Issue / US
     Closes #<issue-id>
     EOF
     ```

4. **Verify CI & Report**:
   - Output the PR URL.
   - Inspect PR status and CI checks:

     ```bash
     rtk gh pr status
     rtk gh pr checks
     ```

   - Remind the user that review feedback can be handled with Stage 5 review (`review-pr` skill) and merging remains strictly human-controlled.
