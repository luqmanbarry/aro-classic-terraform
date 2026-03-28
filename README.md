# ARO Classic Factory

This repo builds Azure Red Hat OpenShift classic clusters from files stored in Git.

High-level flow:

1. Engineers add or update files under `clusters/`.
2. They open a pull request.
3. CI checks the changed cluster files and validates Terraform.
4. After merge, a gated apply flow can create or update the cluster.
5. OpenShift GitOps applies normal day-2 cluster changes from Git.

## Start Here

- [Architecture Overview](./docs/architecture/platform-factory.md)
- [Terraform vs GitOps Boundary](./docs/architecture/terraform-vs-gitops-boundary.md)
- [Execution Models](./docs/operations/execution-models.md)
- [Catalog](./catalog/README.md)
- [Clusters](./clusters/README.md)
- [Terraform Modules](./modules/README.md)
- [GitOps](./gitops/README.md)

## Repository Layout

- `catalog/`: shared default settings
- `clusters/`: one folder per cluster
- `modules/`: reusable Terraform modules
- `gitops/`: GitOps bootstrap and app config
- `scripts/`: helper scripts used by CI and manual runs
- `.github/workflows/`: GitHub Actions example
- `azure-pipelines.yml`: Azure Pipelines example
- `scripts/aap/`: AAP example playbook

## Core Principles

- Terraform builds the Azure resources, the ARO cluster, and the bootstrap pieces.
- OpenShift GitOps manages normal in-cluster changes after bootstrap.
- Azure Key Vault is the default secret-management backend for ARO in this repo.
- People write YAML input files.
- Scripts create JSON files from those YAML files.
- Cluster differences should stay in Git, not in hidden shell scripts.

## Prerequisites

- Azure access:
  - permission to create resource groups, networking, identities, role assignments, ARO clusters, and DNS records
  - Azure login or service principal details for Terraform
- ARO access:
  - an Azure subscription that can run ARO
  - a Red Hat pull secret stored in Azure Key Vault
- Key Vault:
  - a Key Vault for cluster secrets
  - the pull secret saved under the secret name used in the cluster files
- Tooling:
  - `terraform`
  - `python3`
  - `oc`
  - `helm`
  - `az`
  - `git`
  - `jq`
  - `rg`

## CI/CD Requirements

The example pipelines check for these tools:

- `bash`
- `git`
- `jq`
- `python3`
- `terraform`
- `helm`
- `rg`
- `oc`
- `az`

See [factory.yml](./.github/workflows/factory.yml) and [check_required_ci_tools.sh](./scripts/check_required_ci_tools.sh).
See [azure-pipelines.yml](./azure-pipelines.yml) for an Azure Pipelines example.

For step-by-step examples for bastion, GitHub Actions, Azure Pipelines, AAP, and Terraform CLI, see [Execution Models](./docs/operations/execution-models.md).

## Factory Model

Each cluster folder under `clusters/<env>/<cluster>/` does three things:

1. It uses the generated `terraform.auto.tfvars.json` file.
2. It passes that data into `modules/factory-stack`.
3. It returns outputs that CI or operators can use.

The factory module composes:

- `aro-classic-infra`
- `aro-classic-core`
- `aro-classic-kubeconfig`
- `aro-classic-acm-registration`
- `openshift-gitops-bootstrap`

## Status

The factory layout is now the supported way to use this repo.
