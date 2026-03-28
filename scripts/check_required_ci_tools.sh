#!/usr/bin/env bash

set -euo pipefail

missing=0

for tool in "$@"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    missing=1
  fi
done

exit "$missing"
