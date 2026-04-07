#!/bin/bash

set -euo pipefail

SPOKE_ENV="$HOME/.spoke-env"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed" >&2
  echo "Install jq to use Ask Spoke: brew install jq" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed" >&2
  exit 1
fi

unset ASK_CIRCUIT_TOKEN
[ -f "$SPOKE_ENV" ] && source "$SPOKE_ENV"

if [ ! -f "$SPOKE_ENV" ]; then
  echo "Error: ~/.spoke-env not found" >&2
  echo "Create ~/.spoke-env and add ASK_CIRCUIT_TOKEN" >&2
  exit 1
fi

if [ -z "${ASK_CIRCUIT_TOKEN:-}" ]; then
  echo "Error: ASK_CIRCUIT_TOKEN not configured" >&2
  echo "Add ASK_CIRCUIT_TOKEN to ~/.spoke-env" >&2
  exit 1
fi

if [ -n "$ASK_CIRCUIT_TOKEN" ]; then
  echo "Ask Spoke token: configured"
  exit 0
fi
