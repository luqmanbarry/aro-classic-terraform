#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: find_bugs_and_docs_issues.sh

This script runs quick checks that catch bugs and documentation issues before CI runs.
EOF
}

if [[ $# -gt 0 ]]; then
  usage
  exit 2
fi

marker_pattern='TODO|FIXME|TBD'

echo "Checking documentation for unresolved marker words..."
doc_issues=$(rg --no-heading --line-number --color never -g '*.md' -P "(?<!\`)$marker_pattern(?!\`)" . || true)
if [[ -n "$doc_issues" ]]; then
  echo "Documentation issues found:"
  echo "$doc_issues"
  exit 1
fi

echo "Checking repo files for unresolved marker words..."
repo_issues=$(rg --no-heading --line-number --color never -g '*.tf' -g '*.yaml' -g '*.yml' -g '*.sh' -g '*.py' -e "$marker_pattern" . | grep -v 'find_bugs_and_docs_issues.sh' || true)
if [[ -n "$repo_issues" ]]; then
  echo "Repository markers found:"
  echo "$repo_issues"
  exit 1
fi

echo "Running terraform fmt on clusters and modules..."
terraform fmt -check clusters modules

echo "Compiling shared Python helpers..."
python3 -m py_compile scripts/validate_stack_inputs.py scripts/render_effective_config.py
