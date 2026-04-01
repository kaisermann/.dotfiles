---
name: spoke-ask
description: Query Spoke's internal knowledge search for historical context, prior decisions, and Twist discussion history. Load this skill when the knowledge base does not cover the answer and you need internal discussion context.
---

# Spoke Ask

Query Spoke's internal AI assistant to search Twist chat history, internal context, and past decisions.

## Before You Query

Check auth first:

```bash
sh ~/.spoke-knowledge/scripts/validate-config.sh ask-spoke
```

If auth fails, stop and tell the user exactly what is missing. Do not keep retrying blind.

Expected token in `~/.spoke-env`:

```bash
ASK_CIRCUIT_TOKEN=your_token_here
```

Token source: [GCP Secret Manager — staging--ask-auth-token](https://console.cloud.google.com/security/secret-manager/secret/staging--ask-auth-token/versions?project=circuit-api-284012)

The script also requires `jq` and `curl`.

## Usage

```bash
# Simple query
sh ~/.spoke-knowledge/scripts/spoke-ask.sh "How does the optimization engine handle time windows?"

# Longer prompt via stdin
sh ~/.spoke-knowledge/scripts/spoke-ask.sh <<'EOF'
What was the decision around migrating from Firebase Functions to backend-services for trigger processing? Include any tradeoffs discussed.
EOF

# Attach a file for analysis
sh ~/.spoke-knowledge/scripts/spoke-ask.sh --attachment path/to/file.txt "Summarize the context around this code"
```

## When To Use

- historical context on why a decision was made
- finding who discussed or owned a topic
- locating relevant Twist discussions
- answering "has this been discussed before?"

## When Not To Use

- current architecture or stable patterns already covered in the knowledge base
- repo-specific implementation details that belong in local docs or source
- broad exploratory searches when you already know the right knowledge base doc

## Query Tips

- be specific about the system, team, or decision
- include date ranges for time-bounded topics
- paste a Twist thread URL to constrain search when you already have one
- expect queries to take 30-120 seconds

## Failure Handling

- if auth is missing: run `sh ~/.spoke-knowledge/scripts/validate-config.sh ask-spoke` and report the missing token
- if the result looks stale: cross-check dates and current code before treating it as ground truth
- if you need stable, curated knowledge instead of search results: use `spoke-knowledge`

## See Also

- `~/.spoke-knowledge/scopes/operations/internal-tools.md` — broader internal tooling reference
- `spoke-knowledge` — curated knowledge base routing
