#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/run_cluster_stack.sh --cluster-dir <path> [options]

Options:
  --cluster-dir <path>   Cluster stack directory, for example clusters/dev/aroclassic101 or clusters/us-east-1/qa/aroclassic210
  --artifact-dir <path>  Artifact output directory. Default: .artifacts/<cluster-name>
  --mode <mode>          One of: validate, plan, apply. Default: plan
  --skip-tool-check      Skip the required tool check
  --skip-az-login        Skip Azure CLI login
  --backend-false        Run terraform init with -backend=false
  --help                 Show this help

Environment variables:
  TF_INIT_ARGS           Extra arguments passed to terraform init
  TF_PLAN_ARGS           Extra arguments passed to terraform plan
  TF_APPLY_ARGS          Extra arguments passed to terraform apply
EOF
}

cluster_dir=""
artifact_dir=""
mode="plan"
skip_tool_check="false"
skip_az_login="false"
backend_false="false"

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
    --skip-tool-check)
      skip_tool_check="true"
      shift
      ;;
    --skip-az-login)
      skip_az_login="true"
      shift
      ;;
    --backend-false)
      backend_false="true"
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

if [[ ! -d "$cluster_dir" ]]; then
  echo "cluster directory not found: $cluster_dir" >&2
  exit 1
fi

if [[ ! -f "$cluster_dir/cluster.yaml" ]]; then
  echo "missing cluster.yaml in $cluster_dir" >&2
  exit 1
fi

if [[ ! -f "$cluster_dir/gitops.yaml" ]]; then
  echo "missing gitops.yaml in $cluster_dir" >&2
  exit 1
fi

case "$mode" in
  validate|plan|apply) ;;
  *)
    echo "invalid mode: $mode" >&2
    exit 1
    ;;
esac

cluster_name="$(basename "$cluster_dir")"
artifact_dir="${artifact_dir:-.artifacts/${cluster_name}}"
mkdir -p "$artifact_dir"
artifact_dir="$(cd "$artifact_dir" && pwd)"
plan_file="${artifact_dir}/terraform.tfplan"
plan_json_file="${artifact_dir}/terraform.tfplan.json"

if [[ "$skip_tool_check" != "true" ]]; then
  scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc az
fi

if [[ "$skip_az_login" != "true" ]]; then
  if ! az account show >/dev/null 2>&1; then
    if [[ -n "${ARM_CLIENT_ID:-}" && -n "${ARM_CLIENT_SECRET:-}" && -n "${ARM_TENANT_ID:-}" ]]; then
      az login --service-principal \
        --username "$ARM_CLIENT_ID" \
        --password "$ARM_CLIENT_SECRET" \
        --tenant "$ARM_TENANT_ID" >/dev/null
    else
      echo "azure cli is not logged in and ARM_CLIENT_ID, ARM_CLIENT_SECRET, or ARM_TENANT_ID is missing" >&2
      exit 1
    fi
  fi
fi

python3 scripts/validate_stack_inputs.py \
  --cluster-dir "$cluster_dir"

python3 scripts/render_effective_config.py \
  --cluster-dir "$cluster_dir" \
  --output-dir "$artifact_dir"

cp "$artifact_dir/terraform.auto.tfvars.json" "$cluster_dir/terraform.auto.tfvars.json"

init_args=()
if [[ "$backend_false" == "true" ]]; then
  init_args+=("-backend=false")
fi
if [[ -n "${TF_INIT_ARGS:-}" ]]; then
  # shellcheck disable=SC2206
  init_args+=(${TF_INIT_ARGS})
fi

terraform -chdir="$cluster_dir" init "${init_args[@]}"

case "$mode" in
  validate)
    terraform -chdir="$cluster_dir" validate
    ;;
  plan)
    # shellcheck disable=SC2206
    plan_args=(${TF_PLAN_ARGS:-})
    terraform -chdir="$cluster_dir" plan -out="$plan_file" "${plan_args[@]}"
    terraform -chdir="$cluster_dir" show -json "$plan_file" > "$plan_json_file"
    ;;
  apply)
    # shellcheck disable=SC2206
    plan_args=(${TF_PLAN_ARGS:-})
    terraform -chdir="$cluster_dir" plan -out="$plan_file" "${plan_args[@]}"
    terraform -chdir="$cluster_dir" show -json "$plan_file" > "$plan_json_file"
    # shellcheck disable=SC2206
    apply_args=(${TF_APPLY_ARGS:-})
    terraform -chdir="$cluster_dir" apply "${apply_args[@]}" "$plan_file"
    ;;
esac
