---
name: review-pr
description: Use when inspecting, triaging, and addressing Pull Request review comments and conversation threads.
---

# PR Review Skill

This skill defines the standardized protocol for fetching, triaging, and addressing Pull Request review comments and
conversation threads across repositories.

---

## Core Guardrails & SDLC Rules

All actions performed during PR review resolution MUST adhere to the following guardrails:

1. **Commit Approval Rule (SDLC Stage 4 - MANDATORY)**:
   - **NEVER** commit directly or automatically after making code modifications or tests.
   - If the project requires project synchronization (e.g. `rtk mise run generate`), execute it.
   - Always run the verification suite (`rtk mise run verify` or quality commands from `AGENTS.md`).
   - Present `git status` + list of changed files and propose a Conventional Commit message (`fix(...)` /
     `refactor(...)`).
   - **Wait for explicit user approval** before running `git commit`.
2. **Merge Gate (SDLC Stage 5 - MANDATORY)**:
   - **NEVER** merge a PR automatically (`gh pr merge`).
   - Merging is strictly reserved for explicit human confirmation or manual action by the repository maintainer once all
     reviews and CI checks pass.
3. **Architectural Integrity**:
   - Maintain strict separation of concerns and layer decoupling adhering to the project's `AGENTS.md`.

---

## Step 1: Discover & Fetch PR Review Threads

### 1. Identify the Active PR

If the PR number is not specified in the user request, determine the PR associated with the current branch:

```bash
# View active PR for current branch
gh pr view --json number,title,url,state
```

Or list recent open PRs:

```bash
gh pr list --state open --limit 5
```

### 2. Fetch Review Threads via GraphQL

GitHub groups review comments into conversation threads. Use `gh api graphql --paginate` with `$endCursor: String` and
`pageInfo` to exhaustively retrieve all threads, their resolution state, file locations, line numbers, and comment
details:

```bash
gh api graphql --paginate -f query='
query($owner: String!, $repo: String!, $pr: Int!, $endCursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      id
      reviewThreads(first: 50, after: $endCursor) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first: 10) {
            nodes {
              id
              databaseId
              body
              author {
                login
              }
              reactions(first: 10) {
                nodes {
                  content
                  user {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}' -F owner=':owner' -F repo=':repo' -F pr=<pr_number>
```

**Key Data Fields**:

- `thread.id`: GraphQL node ID (e.g., `PRRT_...`) used to resolve the thread.
- `thread.isResolved`: Boolean indicating if the thread is already resolved.
- `comment.databaseId`: Numeric REST ID used for REST reactions and replies.
- `comment.id`: GraphQL node ID used for GraphQL mutations.
- `comment.body`: The comment text containing the reviewer's feedback.

---

## Step 2: Triage Review Comments

Evaluate every unresolved thread (`isResolved == false`). Classify each thread into one of two categories:

### Category A: Legitimate Comments

The comment points out a genuine problem or improvement aligned with the PR's scope:

- **Bugs & Edge Cases**: Unhandled error paths, missing validation, panics, memory/concurrency leaks.
- **Architectural & Design Drift**: Leaking infrastructure details, missing abstractions, bypassing layer boundaries.
- **Missing Tests & Assertions**: Missing unit/integration tests for newly added logic or edge cases.
- **Typing & Linting Issues**: Incorrect types, linter warnings, formatting violations, dead code.

### Category B: Non-Applicable Comments (Wontfix)

The comment is inapplicable or should not be implemented:

- **Out of Scope**: Demands features or refactoring unrelated to the User Story / Issue.
- **Intentional Design / Architectural Decision**: Conflicts with explicit project architecture defined in `AGENTS.md`.
- **False Positives**: Reviewer or automated bot hallucination misinterpreting the code context.

---

## Step 3: Resolving Legitimate Comments

When a comment is deemed legitimate, follow this sequential execution loop:

### 1. Implement Fixes & Tests

- Apply the necessary code changes respecting project architecture.
- Add regression tests covering the specific scenario identified by the reviewer.
- Run project synchronization if required (`rtk mise run generate`).

### 2. Run Local Quality Verification (Stage 4)

Execute the project verification suite to ensure zero regressions:

```bash
rtk mise run verify
# or execute commands from AGENTS.md
```

### 3. Propose Conventional Commit & Await Human Approval (Stage 4 Commit Gate)

- **NEVER commit directly.**
- Run `git status` and present the list of changed files.
- Propose a Conventional Commit message:

  ```text
  fix(<scope>): address PR review comments on <topic>
  ```

- **Wait for explicit user confirmation** before running `git commit`.

### 4. Push Commit to Remote

Once approved and committed:

```bash
git push origin HEAD
```

### 5. Add Positive Reaction (👍)

Acknowledge valid feedback by adding a `+1` reaction:

```bash
gh api repos/{owner}/{repo}/pulls/comments/<database_id>/reactions -f content='+1'
```

### 6. Reply to Review Thread

Post an informative reply explaining the fix. **Always pass the reply text via standard input with a quoted heredoc
(`-F body=@- <<'EOF'`)**:

```bash
gh api repos/{owner}/{repo}/pulls/<pr_number>/comments/<database_id>/replies \
  -F body=@- <<'EOF'
Fixed in commit <short_hash>. <Concise description of the fix and regression tests added>.
EOF
```

### 7. Resolve Review Thread via GraphQL

Resolve the conversation thread:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: { threadId: $threadId }) {
    thread {
      id
      isResolved
    }
  }
}' -F threadId="<thread_node_id>"
```

---

## Step 4: Resolving Non-Applicable Comments (Wontfix)

When a comment is determined to be non-applicable or wontfix:

- **DO NOT** modify application code, configuration, or tests.
- **DO NOT** create commits.

### 1. Add Negative Reaction (👎)

```bash
gh api repos/{owner}/{repo}/pulls/comments/<database_id>/reactions -f content='-1'
```

### 2. Reply with Technical Justification

Post a professional reply explaining the technical rationale. Pass body via standard input:

```bash
gh api repos/{owner}/{repo}/pulls/<pr_number>/comments/<database_id>/replies \
  -F body=@- <<'EOF'
<Clear technical justification explaining why the suggestion cannot or should not be applied>.
EOF
```

### 3. Resolve Review Thread via GraphQL

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: { threadId: $threadId }) {
    thread {
      id
      isResolved
    }
  }
}' -F threadId="<thread_node_id>"
```

---

## Step 5: Post-Triage Verification & Final Checks

1. **Verify Thread Resolution**:
   - Re-run the paginated GraphQL query to confirm all review threads have `isResolved: true`.
2. **Verify CI Status**:

   ```bash
   rtk gh pr checks
   ```

3. **Merge Reminder**:
   - Remind the user that all review feedback has been triaged, CI checks verified, and the PR is ready for manual
     merge.
