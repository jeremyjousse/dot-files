---
description: Synchronize GitHub labels for a repository using github-labels and standard SDLC taxonomy
---

# GitHub Labels Synchronization

You are executing the **GitHub Labels Synchronization** workflow using `github-labels` (`labels` CLI).

## Target Repository & Configuration

Arguments: $ARGUMENTS

### 1. Identify Target Repository

- If an argument is provided (e.g. `owner/repo` or URL), parse the repository slug `owner/repo`.
- Otherwise, resolve the repository from the current working tree:

  ```bash
  gh repo view --json nameWithOwner -q .nameWithOwner
  ```

### 2. Identify Labels Configuration

- If `--config <path>` (or `-c <path>`) is supplied in `$ARGUMENTS`, use that configuration file.
- Otherwise, check if `.github/labels.json` exists in the current repository root.
- Otherwise, fall back to the global OpenCode taxonomy at:

  ```bash
  echo "$HOME/.config/opencode/labels.json"
  ```

### 3. Verify Prerequisites

- Ensure `github-labels` (`labels`) is installed:

  ```bash
  mise which labels || which labels
  ```

  If not found, run `mise install` or advise installing via `mise use -g npm:github-labels`.

- Verify GitHub CLI authentication:

  ```bash
  gh auth status
  ```

### 4. Execute Synchronization

- Capture token securely and synchronize labels to the target repository using the preload patch:

  ```bash
  TOKEN="$(gh auth token)"
  if [ -z "$TOKEN" ]; then
    echo "Error: Unable to retrieve GitHub token. Ensure 'gh auth login' has been executed." >&2
    exit 1
  fi
  NODE_OPTIONS="-r $HOME/.config/opencode/scripts/github-labels-auth.cjs" mise exec -- labels -c <config-path> -t "$TOKEN" <owner/repo>
  ```

  _(Note: Add `-f` only if the user explicitly requested force-deleting existing remote labels)._

### 5. Verification & Output

- Fetch and display the list of remote labels to confirm synchronization:

  ```bash
  gh label list --repo <owner/repo>
  ```

- Summarize the synchronized labels (counts by category: `Status:*`, `Type:*`, `Priority:*`, `Effort:*`).
