#!/usr/bin/env bash

set -euo pipefail

base_ref="${1:-HEAD~1}"
head_ref="${2:-HEAD}"

git diff --name-only "$base_ref" "$head_ref" -- "clusters/*/*" \
  | awk -F/ 'NF >= 3 { print $1 "/" $2 "/" $3 }' \
  | sort -u
