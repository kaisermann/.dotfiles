---
name: spoke-linear
description: Query and mutate Spoke's Linear workspace through the bundled CLI wrapper. Load this skill when you need ticket, project, or document context, or when you need to create or update Linear issues.
---

# Spoke Linear

Use the bundled Linear wrapper for Product-team ticket and project workflows.

## Before You Query

Check auth first:

```bash
sh ~/.spoke-knowledge/scripts/validate-config.sh linear
```

If auth fails, stop and tell the user what is missing.

Expected token in `~/.spoke-env`:

```bash
LINEAR_API_KEY=your_token_here
```

The wrapper also requires `jq`.

## Common Commands

```bash
# Get one issue
sh ~/.spoke-knowledge/scripts/linear.sh issue get PRO-12345

# Search issues
sh ~/.spoke-knowledge/scripts/linear.sh issue list --query "navigation" --label "iOS"

# List issues assigned to you
sh ~/.spoke-knowledge/scripts/linear.sh issue my

# Get a project
sh ~/.spoke-knowledge/scripts/linear.sh project get "Feature Name"

# Inspect mutation support
sh ~/.spoke-knowledge/scripts/linear.sh mutation help
```

## When To Use

- find ticket context for implementation work
- inspect projects, labels, states, or documents
- look up issue relationships, attachments, or linked docs
- create or update issues when the user asks

## Important Behavior

- the wrapper is scoped to the Product team (`PRO-` tickets)
- it supports both issue identifiers like `PRO-12345` and direct UUIDs where Linear allows them
- it returns structured JSON-friendly output, so prefer reading it directly instead of scraping the web UI

## Failure Handling

- if auth is missing: run `sh ~/.spoke-knowledge/scripts/validate-config.sh linear`
- if the API says unauthorized: tell the user to refresh `LINEAR_API_KEY` in `~/.spoke-env`
- if the API says rate limited: wait and retry later rather than spamming requests

## See Also

- `~/.spoke-knowledge/scopes/operations/internal-tools.md` — internal tooling reference
