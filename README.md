# ARO Classic Factory

This repo builds and manages Azure Red Hat OpenShift classic clusters on Azure. The inputs live in Git, Terraform builds the Azure and ARO pieces, and OpenShift GitOps manages normal in-cluster changes.

## Repository Layout

- `catalog/`: shared defaults and reusable classes
- `clusters/`: one folder per cluster under `clusters/<group-path>/<cluster-name>/`
- `modules/`: reusable Terraform modules
- `gitops/`: OpenShift GitOps bootstrap, shared overlay, and reusable apps
- `playbooks/`: Ansible Automation Platform examples
- `scripts/`: render, validate, and helper scripts
- `docs/`: design notes and execution guidance
- `.github/workflows/`: GitHub Actions example
- `azure-pipelines.yml`: Azure Pipelines example

## How It Works

1. Write or update `cluster.yaml`, `gitops.yaml`, and any app values under `clusters/<group-path>/<cluster-name>/`.
2. Render and validate the cluster inputs with the shared scripts.
3. Run Terraform from that cluster folder.
4. Terraform builds or reuses Azure infrastructure, creates the ARO cluster, and bootstraps OpenShift GitOps.
5. GitOps applies platform and workload apps after the cluster is ready.

## Terraform Scope

- Optional Azure infrastructure when `infrastructure.create_azure_resources` is `true`
- ARO classic cluster lifecycle
- Cluster identities, role assignments, DNS, and bootstrap outputs
- Optional ACM registration
- OpenShift GitOps bootstrap

This repo defaults to customer-managed Azure networking and shared landing-zone resources. That keeps the normal cluster stack focused on cluster lifecycle instead of broad shared Azure resources.

## GitOps Scope

- Azure Key Vault plus External Secrets Operator is the default secret pattern
- Terraform creates the shared Azure workload identity and bootstrap metadata secret for the default Key Vault store
- Platform apps cover identity, RBAC, registry policy, monitoring, logging, operators, onboarding, and recovery helpers
- Workload apps cover shared platforms such as AAP, OpenShift AI, and CP4BA
- High-risk or optional operators use manual install approval by default
- Tenant onboarding is optional and stays separate from admin-owned platform GitOps

## Prerequisites

- Azure access:
  - permission to create resource groups, networking, identities, role assignments, ARO clusters, and DNS records
  - Azure login details for Terraform
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

## Execution Patterns

- Bastion or Terraform CLI for manual admin runs
- GitHub Actions for PR validation and gated apply flows
- Azure Pipelines for enterprise Azure DevOps runners
- Ansible Automation Platform for controlled job templates and approvals

See [Execution Models](./docs/operations/execution-models.md) for the exact command flow.

## Read More

- [Platform factory](./docs/architecture/platform-factory.md)
- [Terraform vs GitOps boundary](./docs/architecture/terraform-vs-gitops-boundary.md)
- [Execution models](./docs/operations/execution-models.md)
- [Tenant onboarding](./docs/operations/tenant-onboarding.md)
- [Catalog](./catalog/README.md)
- [Clusters](./clusters/README.md)
- [Terraform modules](./modules/README.md)
- [GitOps](./gitops/README.md)
- [AAP playbooks](./playbooks/README.md)
