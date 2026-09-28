---
description: Synchronize GitHub repository labels using the standard SDLC taxonomy
---

# GitHub Labels Synchronization

You are executing the **GitHub Labels Synchronization** workflow.

## Target Repository & Options

Arguments: $ARGUMENTS

### Execution Protocol

Call the `sync_labels` tool directly:

- If `$ARGUMENTS` contains a target repository (e.g. `owner/repo` or repository URL), pass it in the `repo` argument.
- If `$ARGUMENTS` contains a configuration path (e.g. `--config <path>` or `<path>.json`), pass it in the `config`
  argument.
- If no repository or configuration argument is provided, invoke `sync_labels` with `{}` (empty arguments); the tool
  automatically detects the repository from the working tree and resolves the labels configuration.

Do NOT run manual shell commands (`gh repo view`, `gh auth`, etc.) as the `sync_labels` tool handles repository
resolution and synchronization internally.

### Output

Display the synchronization summary returned by the `sync_labels` tool to the user.
