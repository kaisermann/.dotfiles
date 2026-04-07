#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/validate.sh" >/dev/null

cmd_help() {
    cat << 'EOF'
Usage: spoke-ask.sh [options] <<'EOF' ... EOF

Query Spoke's internal knowledge base (Twist discussions, Linear tickets, product decisions)

OPTIONS:
  --attachment FILE      Attach text file(s) for analysis (can be repeated)
  help, --help, -h       Show this help message

PERFORMANCE:
  - Queries may take several minutes to answer
  - More specific context = better results
EOF
}

QUERY=""
ATTACHMENTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        help|--help|-h)
            cmd_help
            exit 0
            ;;
        --strategy)
            shift 2
            ;;
        --attachment)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --attachment requires a file path" >&2
                exit 1
            fi
            ATTACHMENTS+=("$2")
            shift 2
            ;;
        *)
            QUERY="$1"
            shift
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    if [ ! -t 0 ]; then
        QUERY=$(cat)
    fi
fi

if [ -z "$QUERY" ]; then
    echo "Error: Prompt is required" >&2
    echo "Run 'spoke-ask.sh help' for usage information" >&2
    exit 1
fi

if [ ${#ATTACHMENTS[@]} -gt 0 ]; then
    for ATTACHMENT in "${ATTACHMENTS[@]}"; do
        if [ ! -f "$ATTACHMENT" ]; then
            echo "Error: Attachment file not found: $ATTACHMENT" >&2
            exit 1
        fi
        if [ ! -r "$ATTACHMENT" ]; then
            echo "Error: Cannot read attachment file: $ATTACHMENT" >&2
            exit 1
        fi
        if grep -qI '' "$ATTACHMENT" 2>/dev/null; then
            :
        else
            echo "Error: Attachment appears to be a binary file: $ATTACHMENT" >&2
            echo "Only text files are supported" >&2
            exit 1
        fi
    done
fi

if [ -z "${ASK_CIRCUIT_TOKEN:-}" ]; then
    [ -f "$HOME/.spoke-env" ] && source "$HOME/.spoke-env"
fi

if [ -z "${ASK_CIRCUIT_TOKEN:-}" ]; then
    echo "Error: ASK_CIRCUIT_TOKEN not configured" >&2
    echo "Get token from: https://console.cloud.google.com/security/secret-manager/secret/staging--ask-auth-token/versions?project=circuit-api-284012" >&2
    echo "Add to ~/.spoke-env: ASK_CIRCUIT_TOKEN=your_token_here" >&2
    exit 1
fi

# TEMPORARY: Cap at medium to avoid hitting GCP 300s total request timeout
# Revert once getcircuit/infra#484 is merged and deployed
if [ ${#ATTACHMENTS[@]} -ge 1 ]; then
    REASONING_EFFORT="medium"
else
    REASONING_EFFORT="low"
fi

QUERY_PAYLOAD="$QUERY"

if [ ${#ATTACHMENTS[@]} -gt 0 ]; then
    for ATTACHMENT in "${ATTACHMENTS[@]}"; do
        FILENAME=$(basename "$ATTACHMENT")
        CONTENT=$(cat "$ATTACHMENT")
        QUERY_PAYLOAD+="

<attachment filename=\"$FILENAME\"><![CDATA[
$CONTENT
]]></attachment>"
    done
fi

curl -N -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ASK_CIRCUIT_TOKEN" \
  -H "Accept: text/event-stream" \
  -H "Cache-Control: no-cache" \
  -H "Connection: keep-alive" \
  -H "User-Agent: Spoke Agent" \
  -d "$(jq -n --arg q "$QUERY_PAYLOAD" --arg r "$REASONING_EFFORT" '{query: $q, reasoningEffort: $r}')" \
  'https://ask.internal.spoke.com/chat/ask/agentic' \
  --fail-with-body \
  --show-error \
  --silent \
  --compressed | \
  awk '
    BEGIN {
      is_token = 0
      is_error = 0
    }
    /^event: token$/ {
      is_token = 1
      next
    }
    /^event: error$/ {
      is_error = 1
      next
    }
    /^data: / && is_error {
      content = substr($0, 7)
      if (match(content, /"message":"[^"]*"/)) {
        msg = substr(content, RSTART + 11, RLENGTH - 12)
        gsub(/\\"/, "\"", msg)
        print "Error: " msg > "/dev/stderr"
      }
      exit 1
    }
    /^data: / && is_token {
      content = substr($0, 7)
      if (substr(content, 1, 1) == "\"" && substr(content, length(content), 1) == "\"") {
        content = substr(content, 2, length(content) - 2)
      }
      gsub(/\\n/, "\n", content)
      gsub(/\\t/, "\t", content)
      gsub(/\\"/, "\"", content)
      gsub(/\\\\/, "\\", content)
      printf "%s", content
      is_token = 0
    }
    /^event: / && !/^event: token$/ && !/^event: error$/ {
      is_token = 0
    }
  '
echo

exit 0
