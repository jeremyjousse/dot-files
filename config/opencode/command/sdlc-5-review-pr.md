---
description: Stage 5 PR Review Loop - Fetch, triage, address review comments, and resolve conversation threads
agent: sdlc-pr-review
---

# Stage 5: Pull Request Review Loop & Resolution

You are executing **Stage 5 (PR Review Feedback Loop & Merge Gate)** of the SDLC.

## Target PR / Arguments

Target: $ARGUMENTS

If no PR number or URL is specified in `$ARGUMENTS`, detect the active PR for the current branch using `gh pr status`.
If repository details or owner/repo are needed, inspect via `rtk gh repo view` (or `gh repo view --json owner,name`).

## Operational Boundaries

- **Scoped Editing**: File modifications are permitted exclusively to resolve legitimate review comments.
- **Triage Confirmation Gate**: You must NEVER modify code, create commits, add reactions, post replies, or resolve
  threads without explicit user confirmation. Explain the triage assessment for all comments and obtain approval first.
- **Commit Approval Rule**: You must NEVER commit code directly; propose commit messages for human approval.
- **No Direct Merge**: Automated PR merging is strictly denied (`gh pr merge` is forbidden). Merging is strictly
  reserved for manual human action.

## Review Feedback Protocol

Before triaging, load the `review-pr` skill for detailed guidance on inspecting, triaging, replying to, and resolving
review comments.

### 1. Fetch Review Threads

If needed, confirm repository details:

```bash
rtk gh repo view
# or retrieve owner and repository name explicitly
gh repo view --json owner,name
```

Query all unresolved review threads and conversation comments via GitHub CLI / GraphQL API:

```bash
gh api graphql --paginate -f query='
query($owner: String!, $repo: String!, $pr: Int!, $endCursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 50, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          path
          line
          comments(first: 10) {
            nodes {
              id
              author { login }
              body
            }
          }
        }
      }
    }
  }
}' -F owner=':owner' -F repo=':repo' -F pr=<pr-number>
```

### 2. Triage Assessment & User Confirmation (MANDATORY)

Before taking any action on the review comments:

1. **Evaluate Each Unresolved Thread**:
   - Classify as **Legitimate** (bug, regression, missing test, architectural drift, linter/type error) or
     **Non-Applicable** (out of scope, intentional design choice per `AGENTS.md`, false positive).
2. **Present Triage Plan to User**:
   - Present a clear, structured breakdown for each unresolved thread:
     - **Location**: `<file-path>:<line>` (Thread ID: `<thread-id>`)
     - **Author & Feedback**: Author login and summary/quote of reviewer feedback.
     - **Classification**: `Legitimate` or `Non-Applicable`.
     - **Rationale**: Detailed technical explanation justifying why the feedback is legitimate or non-applicable.
     - **Proposed Action**: Concrete implementation plan (code/test modifications) or proposed technical reply.
3. **STOP AND WAIT**:
   - Prompt the user: *"Please confirm if you agree with this triage assessment and the proposed actions before I proceed."*
   - Do **NOT** modify any files, add reactions, post replies, or resolve threads until the user explicitly confirms the
     plan.

### 3. Execute Approved Actions

Once the user approves the triage assessment:

#### A. Legitimate Feedback (Valid bug, style issue, missing test, architectural gap)

1. Implement the requested code and/or test changes adhering to `AGENTS.md`.
2. If project synchronization is required (e.g. `rtk mise run generate`), run it.
3. Run the verification suite to ensure no regressions:
   - Run `rtk mise run verify` if configured, or the quality commands defined in `AGENTS.md`.
4. Propose a Conventional Commit message (`fix(...)` or `refactor(...)`) and obtain explicit user approval before
   committing.
5. Push the commit to origin (`git push origin HEAD`).
6. Add a 👍 (`+1`) reaction to the review comment via GitHub API.
7. Post a reply comment explaining the fix and any tests added (pass body securely via stdin heredoc:
   `-F body=@- <<'EOF'`).
8. Resolve the review thread via GraphQL:

   ```bash
   gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "<thread-id>" }) { thread { isResolved } } }'
   ```

#### B. Non-Applicable Feedback (Wontfix / Intentional design choice / Out of scope)

1. Do NOT modify code or create commits.
2. Add a 👎 (`-1`) reaction to the review comment via GitHub API.
3. Post a respectful reply with clear technical justification explaining why the suggestion cannot or should not be
   applied (pass body securely via stdin heredoc: `-F body=@- <<'EOF'`).
4. Resolve the review thread via GraphQL:

   ```bash
   gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "<thread-id>" }) { thread { isResolved } } }'
   ```

### 4. Verify Resolution & CI Status

- Check that all review threads are resolved.
- Check CI workflow status:

  ```bash
  rtk gh pr checks
  ```

### 5. Merge Gate

Once all review threads are marked resolved and CI checks pass green:

- **NEVER** run `gh pr merge`.
- Inform the user that the PR is completely clean, green, and ready for human merge.
