---
name: spoke-linear
description: Query and update Product-team Linear issues, projects, labels, and documents via the bundled CLI wrapper. Use when a Linear issue or project context is needed for implementation.
---

Use the bundled Linear wrapper for Product-team ticket and project workflows.

If the Spoke Knowledge Base exists at `~/.spoke-knowledge/` and the task creates or updates issues, read `content/company/_reference/linear-ticket-conventions.md` before making issue mutations. Use those conventions for project placement, workflow state, labels, parent/child structure, assignment posture, and how much context the description needs.

Use the bundled wrapper at `scripts/linear.sh`.

If the wrapper fails, stop and tell the user what is missing.

Expected token in `~/.spoke-env`:

```bash
LINEAR_API_KEY=your_token_here
```

The wrapper also requires `jq`.

## Common Commands

```bash
# Get one issue using the bundled wrapper
sh scripts/linear.sh issue get PRO-12345

# Search issues
sh scripts/linear.sh issue list --query "navigation" --label "iOS"

# List issues assigned to you
sh scripts/linear.sh issue my

# Get a project
sh scripts/linear.sh project get "Feature Name"

# Inspect mutation support
sh scripts/linear.sh mutation help
```

For common mutations:

- use `state list` first to resolve workflow state IDs before updating issue state
- if the current user's Linear ID is already known in the session, reuse it for self-assignment instead of listing users again
- use `user list` only when you need to assign someone else or the current user's ID is not known yet

## When To Use

- find ticket context for implementation work
- inspect projects, labels, states, or documents
- look up issue relationships, attachments, or linked docs
- create or update issues when the user asks

## Important Behavior

- the wrapper is scoped to the Product team (`PRO-` tickets)
- it supports both issue identifiers like `PRO-12345` and direct UUIDs where Linear allows them
- it returns structured JSON-friendly output, so prefer reading it directly instead of scraping the web UI
- issue mutations commonly require IDs rather than display names

## Failure Handling

- if the wrapper fails before the request: report the missing token or tool requirement surfaced by the wrapper
- if the API says unauthorized: tell the user to refresh `LINEAR_API_KEY` in `~/.spoke-env`
- if the API says rate limited: wait and retry later rather than spamming requests

## See Also

- `~/.spoke-knowledge/content/company/_reference/internal-tools.md` — internal tooling reference
