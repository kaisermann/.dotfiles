#!/bin/bash

set -u

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd: available"
  else
    echo "Warning: $cmd is not installed" >&2
  fi
}

check_cmd jq
check_cmd curl
check_cmd gcloud
check_cmd kubectl

if command -v gcloud >/dev/null 2>&1; then
  active_gcloud_account=$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null || true)
  if [ -n "$active_gcloud_account" ]; then
    echo "gcloud auth: $active_gcloud_account"
  else
    echo "Warning: gcloud has no active authenticated account" >&2
  fi
fi

if command -v kubectl >/dev/null 2>&1; then
  if kubectl config current-context >/dev/null 2>&1; then
    echo "kubectl context: configured"
  else
    echo "Warning: kubectl has no current context" >&2
  fi

  if kubectl argo rollouts version >/dev/null 2>&1; then
    echo "kubectl argo rollouts: available"
  else
    echo "Warning: kubectl argo rollouts plugin not available" >&2
  fi
fi

exit 0
