# Execution Models

This document shows five common ways to run this repo:

- GitHub Actions
- Azure Pipelines
- bastion host
- Ansible Automation Platform (AAP)
- Terraform CLI

All five methods use the same input files:

- `clusters/<env>/<cluster>/cluster.yaml`
- `clusters/<env>/<cluster>/gitops.yaml`
- `clusters/<env>/<cluster>/values/*.yaml`

## Shared Requirements

These things must be ready no matter where you run the code:

- the cluster files are filled in
- values files exist for every GitOps app you enable
- required `externalSecrets` entries are added before you enable apps that need secrets
- the execution environment has these tools:
  - `bash`
  - `git`
  - `jq`
  - `python3`
  - `terraform`
  - `helm`
  - `rg`
  - `oc`
  - `az`
- you have Azure access for Terraform
- you have access to the GitOps repo if it is private
- you have access to the Azure Key Vault secrets referenced by the cluster and GitOps values
- if ACM registration is enabled, you have the ACM hub kubeconfig ready

Tool check:

```bash
scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc az
```

Common execution flow:

```text
Validate cluster files
  -> render effective config
  -> write terraform.auto.tfvars.json
  -> terraform init
  -> terraform plan
  -> terraform apply
```

Example cluster path used below:

```text
clusters/dev/aroclassic101
```

## Pattern 1: GitHub Actions

Use this pattern when GitHub is your source control and deployment runner.

### Setup Prerequisites

- GitHub repo with Actions enabled
- GitHub runners with network access to Azure, ARO, and Git
- required secrets or OIDC setup for:
  - Azure login for Terraform and `az`
  - private GitOps repo credentials if needed
  - ACM hub kubeconfig if ACM registration is enabled
- backend settings and approval rules added to the workflow

### How It Works

This repo already includes a GitHub Actions example in [factory.yml](../../.github/workflows/factory.yml).

What it does now:

- pull request:
  - detects changed clusters
  - validates inputs
  - renders effective config
  - runs `terraform validate`
- merge to `main`:
  - detects changed clusters
  - can run gated apply for changed clusters when `vars.TERRAFORM_APPLY` is set to `true`
  - uses Azure login and the shared runner script
  - uploads rendered artifacts

Important notes:

- the committed workflow now uses the shared runner script for both validation and apply
- you still need to add the real Terraform backend settings, approval rules, and production secret values

### Basic Flow

1. Detect changed cluster directories.
2. Validate each changed cluster.
3. Render `terraform.auto.tfvars.json`.
4. Run `terraform init`.
5. Run `terraform plan`.
6. Save the plan and rendered artifacts.
7. After approval, run `terraform apply`.

### Secrets And Variables

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_CLIENT_SECRET` if you do not use OIDC federation
- `ARM_CLIENT_ID`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_CLIENT_SECRET` if you do not use OIDC federation
- `ACM_HUB_KUBECONFIG` if ACM registration is enabled

### Command Sequence

```bash
scripts/run_cluster_stack.sh \
  --cluster-dir "$CLUSTER_DIR" \
  --artifact-dir "$ARTIFACT_DIR" \
  --mode plan

scripts/run_cluster_stack.sh \
  --cluster-dir "$CLUSTER_DIR" \
  --artifact-dir "$ARTIFACT_DIR" \
  --mode apply
```

## Pattern 2: Azure Pipelines

Use this pattern when Azure DevOps is your source control or approved enterprise runner.

### Setup Prerequisites

- Azure DevOps project and pipeline
- Microsoft-hosted or self-hosted agents with network access to Azure, ARO, and Git
- secure variables or variable groups for:
  - Azure login
  - private GitOps repo credentials if needed
  - ACM hub kubeconfig if ACM registration is enabled
- a validation stage
- a plan stage
- an approval gate before apply

### Basic Flow

1. Checkout the repo.
2. Install or verify the required tools.
3. Authenticate to Azure.
4. Run input validation.
5. Render `terraform.auto.tfvars.json`.
6. Run `terraform init`.
7. Run `terraform plan`.
8. Publish plan and render artifacts.
9. Run `terraform apply` only after approval.

### Azure Pipelines Example

This repo now includes an example pipeline at [azure-pipelines.yml](../../azure-pipelines.yml).

```yaml
trigger:
  branches:
    include:
      - main

pr:
  branches:
    include:
      - main

variables:
  cluster_dir: clusters/dev/aroclassic101
  artifact_dir: $(Build.ArtifactStagingDirectory)/aroclassic101

pool:
  vmImage: ubuntu-latest

steps:
  - checkout: self
    fetchDepth: 0

  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.12'

  - script: |
      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    displayName: Install Helm

  - task: AzureCLI@2
    inputs:
      azureSubscription: your-service-connection
      scriptType: bash
      scriptLocation: inlineScript
      inlineScript: |
        az version
        scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc az

        python3 scripts/validate_stack_inputs.py \
          --cluster "$(cluster_dir)/cluster.yaml" \
          --gitops-values "$(cluster_dir)/gitops.yaml"

        python3 scripts/render_effective_config.py \
          --cluster "$(cluster_dir)/cluster.yaml" \
          --gitops-values "$(cluster_dir)/gitops.yaml" \
          --output-dir "$(artifact_dir)"

        cp "$(artifact_dir)/terraform.auto.tfvars.json" \
          "$(cluster_dir)/terraform.auto.tfvars.json"

        terraform -chdir="$(cluster_dir)" init
        terraform -chdir="$(cluster_dir)" plan
    displayName: Validate and plan
```

### Command Sequence

```bash
scripts/run_cluster_stack.sh \
  --cluster-dir "$CLUSTER_DIR" \
  --artifact-dir "$ARTIFACT_DIR" \
  --mode plan

scripts/run_cluster_stack.sh \
  --cluster-dir "$CLUSTER_DIR" \
  --artifact-dir "$ARTIFACT_DIR" \
  --mode apply
```

## Pattern 3: Bastion Host

Use this pattern for manual admin execution and debugging.

### Setup Prerequisites

- bastion host with network access to Azure, ARO, and Git
- repo cloned on the bastion host
- required tools installed
- Azure credentials exported or already available on the host
- disk space for temporary files such as `.artifacts/`
- if ACM registration is enabled, the ACM hub kubeconfig available on disk

### Command Sequence

```bash
export ARM_CLIENT_ID='your-client-id'
export ARM_CLIENT_SECRET='your-client-secret'
export ARM_SUBSCRIPTION_ID='your-subscription-id'
export ARM_TENANT_ID='your-tenant-id'

scripts/run_cluster_stack_bastion.sh \
  --cluster-dir clusters/dev/aroclassic101 \
  --mode plan

scripts/run_cluster_stack_bastion.sh \
  --cluster-dir clusters/dev/aroclassic101 \
  --mode apply
```

Use this when:

- you want a controlled manual run
- you want to debug one cluster directly
- you need to test bastion network reachability to Azure APIs, the cluster API, or Git endpoints

## Pattern 4: AAP

Use this pattern when your team wants approvals, RBAC, and managed credentials in Ansible Automation Platform.

### Setup Prerequisites

- AAP controller and execution environment
- execution environment image with the required tools installed
- repository access from AAP
- AAP credentials for:
  - Git
  - Azure login
  - ACM hub kubeconfig if ACM registration is enabled
- job template or workflow template
- optional approval node before apply

### Basic Flow

1. Checkout the repo.
2. Check the required tools.
3. Validate cluster files.
4. Render `terraform.auto.tfvars.json`.
5. Run `terraform init`.
6. Run `terraform plan`.
7. Add approval if needed.
8. Run `terraform apply`.

### AAP Playbook Example

This repo now includes an example AAP playbook at [scripts/aap/run_cluster_stack.yml](../../scripts/aap/run_cluster_stack.yml).

Example extra vars:

```yaml
cluster_dir: clusters/dev/aroclassic101
artifact_dir: /runner/artifacts/aroclassic101
execution_mode: plan
skip_tool_check: false
skip_az_login: false
backend_false: false
```

Example run:

```bash
ansible-playbook scripts/aap/run_cluster_stack.yml \
  -e cluster_dir=clusters/dev/aroclassic101 \
  -e artifact_dir=/runner/artifacts/aroclassic101 \
  -e execution_mode=plan
```

### Command Sequence

```bash
ansible-playbook scripts/aap/run_cluster_stack.yml \
  -e cluster_dir="$CLUSTER_DIR" \
  -e artifact_dir="$ARTIFACT_DIR" \
  -e execution_mode=plan

ansible-playbook scripts/aap/run_cluster_stack.yml \
  -e cluster_dir="$CLUSTER_DIR" \
  -e artifact_dir="$ARTIFACT_DIR" \
  -e execution_mode=apply
```

## Pattern 5: Terraform CLI

Use this pattern when you want to run the repo directly with Terraform from any approved shell environment.

### Setup Prerequisites

- local or remote shell with the required tools
- Terraform backend settings ready if you use a remote backend
- required environment variables exported
- network access to Azure, ARO, and Git

### Command Sequence

```bash
export ARM_CLIENT_ID='your-client-id'
export ARM_CLIENT_SECRET='your-client-secret'
export ARM_SUBSCRIPTION_ID='your-subscription-id'
export ARM_TENANT_ID='your-tenant-id'

scripts/run_cluster_stack.sh \
  --cluster-dir clusters/dev/aroclassic101 \
  --mode plan

scripts/run_cluster_stack.sh \
  --cluster-dir clusters/dev/aroclassic101 \
  --mode apply
```

## Which Method Should You Choose

Use:

- GitHub Actions for GitHub-native PR and merge workflows
- Azure Pipelines for Azure DevOps-native enterprise pipelines
- bastion host for manual testing and debugging
- AAP for controlled operations with approvals and central credentials
- Terraform CLI for direct shell execution

For most teams, the best long-term pattern is:

```text
Engineers change Git
  -> PR validation in GitHub Actions or Azure Pipelines
  -> approval
  -> apply from CI or an approved admin-run path
```

## Notes

- `terraform.auto.tfvars.json` is generated. Do not edit it by hand.
- `scripts/run_cluster_stack.sh` is the main shared runner for CI and shell-based runs.
- `scripts/run_cluster_stack_bastion.sh` is the bastion wrapper.
- `scripts/aap/run_cluster_stack.yml` is the AAP playbook that calls the shared runner.
- Terraform builds the Azure resources, the ARO cluster, and optional bootstrap pieces.
- OpenShift GitOps manages the selected platform and workload apps after bootstrap.
- If a GitOps app needs a Kubernetes `Secret`, add that app's `externalSecrets` entries to the same values file before apply.
- If ACM registration is enabled, make sure the ACM inputs are ready before apply.
