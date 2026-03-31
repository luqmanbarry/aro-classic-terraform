#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/run_cluster_stack_bastion.sh --cluster-dir <path> [options]

Options:
  --cluster-dir <path>   Cluster stack directory, for example clusters/dev/aroclassic101 or clusters/us-east-1/qa/aroclassic210
  --artifact-dir <path>  Artifact output directory. Default: .artifacts/bastion/<cluster-name>
  --mode <mode>          One of: validate, plan, apply. Default: plan
  --backend-false        Run terraform init with -backend=false
  --skip-tool-check      Skip the required tool check
  --skip-az-login        Skip Azure CLI login
  --help                 Show this help
EOF
}

cluster_dir=""
artifact_dir=""
mode="plan"
backend_false="false"
skip_tool_check="false"
skip_az_login="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-dir)
      cluster_dir="${2:-}"
      shift 2
      ;;
    --artifact-dir)
      artifact_dir="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --backend-false)
      backend_false="true"
      shift
      ;;
    --skip-tool-check)
      skip_tool_check="true"
      shift
      ;;
    --skip-az-login)
      skip_az_login="true"
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$cluster_dir" ]]; then
  echo "--cluster-dir is required" >&2
  usage >&2
  exit 1
fi

cluster_name="$(basename "$cluster_dir")"
artifact_dir="${artifact_dir:-.artifacts/bastion/${cluster_name}}"
args=(
  --cluster-dir "$cluster_dir"
  --artifact-dir "$artifact_dir"
  --mode "$mode"
)

if [[ "$backend_false" == "true" ]]; then
  args+=(--backend-false)
fi

if [[ "$skip_tool_check" == "true" ]]; then
  args+=(--skip-tool-check)
fi

if [[ "$skip_az_login" == "true" ]]; then
  args+=(--skip-az-login)
fi

exec scripts/run_cluster_stack.sh "${args[@]}"
