#!/usr/bin/env bash

set -euo pipefail

base_ref="${1:-origin/main}"
head_ref="${2:-HEAD}"

git diff --name-only "${base_ref}"...${head_ref} \
  | rg '^clusters/.+/' \
  | while IFS= read -r changed_path; do
      cluster_dir="$(dirname "$changed_path")"
      while [[ "$cluster_dir" != "clusters" && ! -f "$cluster_dir/cluster.yaml" ]]; do
        cluster_dir="$(dirname "$cluster_dir")"
      done

      if [[ -f "$cluster_dir/cluster.yaml" ]]; then
        echo "$cluster_dir"
      fi
    done \
  | sort -u
