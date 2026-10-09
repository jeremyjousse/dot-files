# gh-dash Configuration

[gh-dash](https://github.com/dlvhdr/gh-dash) is a command-line extension for the GitHub CLI (`gh`) that
provides a dashboard interface for pull requests, issues, and notifications.

## Overview

This directory provides the dashboard view settings, section layouts, query filters, and diff viewer
integration for `gh-dash`.

## Configuration Details

- **File**: `config.yml`
- **PR Sections**: Filters for *My Pull Requests*, *Needs My Review*, and *Involved*.
- **Issue Sections**: Filters for *My Issues*, *Assigned*, and *Involved*.
- **Notifications**: Structured breakdown across authors, mentions, review requests, and subscriptions.
- **Diff Pager**: Integrated with `diffnav` for tree-based side-by-side diff navigation.

## Symlink Location

Linked by `bootstrap.sh`:

- `config/gh-dash` &rarr; `~/.config/gh-dash`
