#!/bin/bash

set -euo pipefail

SPOKE_ENV="$HOME/.spoke-env"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed" >&2
  echo "Install jq to use Figma: brew install jq" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed" >&2
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "Error: sips is not installed" >&2
  echo "Figma image export currently expects macOS sips" >&2
  exit 1
fi

unset FIGMA_TOKEN
[ -f "$SPOKE_ENV" ] && source "$SPOKE_ENV"

if [ ! -f "$SPOKE_ENV" ]; then
  echo "Error: ~/.spoke-env not found" >&2
  echo "Create ~/.spoke-env and add FIGMA_TOKEN" >&2
  exit 1
fi

if [ -z "${FIGMA_TOKEN:-}" ]; then
  echo "Error: FIGMA_TOKEN not configured" >&2
  echo "Add FIGMA_TOKEN to ~/.spoke-env" >&2
  exit 1
fi

http_code=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "X-Figma-Token: $FIGMA_TOKEN" \
  --max-time 5 \
  https://api.figma.com/v1/me 2>/dev/null)

if [ "$http_code" = "200" ]; then
  echo "Figma API: authenticated"
  exit 0
fi

if [ "$http_code" = "403" ]; then
  echo "Error: invalid or expired FIGMA_TOKEN" >&2
  echo "Regenerate FIGMA_TOKEN at https://www.figma.com/settings" >&2
  exit 1
fi

echo "Error: could not verify FIGMA_TOKEN (HTTP $http_code)" >&2
echo "Check FIGMA_TOKEN in ~/.spoke-env and your network access" >&2
exit 1
