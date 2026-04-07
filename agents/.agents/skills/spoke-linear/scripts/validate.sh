#!/bin/bash

set -euo pipefail

SPOKE_ENV="$HOME/.spoke-env"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed" >&2
  echo "Install jq to use Linear: brew install jq" >&2
  exit 1
fi

unset LINEAR_API_KEY
[ -f "$SPOKE_ENV" ] && source "$SPOKE_ENV"

if [ ! -f "$SPOKE_ENV" ]; then
  echo "Error: ~/.spoke-env not found" >&2
  echo "Create ~/.spoke-env and add LINEAR_API_KEY" >&2
  exit 1
fi

if [ -z "${LINEAR_API_KEY:-}" ]; then
  echo "Error: LINEAR_API_KEY not configured" >&2
  echo "Add LINEAR_API_KEY to ~/.spoke-env" >&2
  exit 1
fi

response=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  --data '{"query": "{ viewer { id } }"}' \
  --max-time 5 2>/dev/null)

if echo "$response" | jq -e '.data.viewer.id' >/dev/null 2>&1; then
  echo "Linear API: authenticated"
  exit 0
fi

echo "Error: invalid LINEAR_API_KEY" >&2
echo "Check LINEAR_API_KEY in ~/.spoke-env" >&2
exit 1
