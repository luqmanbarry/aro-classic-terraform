# Platform Factory

This repo is a reusable way to build ARO classic clusters from files stored in Git.

Simple flow:

1. Users propose cluster inputs in Git.
2. A pull request is reviewed and approved.
3. CI validates and renders the effective configuration.
4. After merge, a gated Terraform apply flow can run to:
   - optionally create Azure infrastructure in scope
   - create the ARO classic cluster
   - write cluster connection details to Key Vault
   - optionally register the cluster to ACM
   - optionally bootstrap OpenShift GitOps
5. OpenShift GitOps applies platform and workload apps.

## End-to-End Flow

```text
Cluster class
  + cluster files
  -> render effective config
  -> Terraform modules
     -> optional Azure infrastructure
     -> ARO classic cluster
     -> kubeconfig bootstrap
     -> optional ACM registration
     -> optional OpenShift GitOps bootstrap
        -> root app
           -> platform apps
           -> workload apps
```

## Terraform Scope

Terraform handles build and bootstrap work:

- optional Azure resource group, VNet, subnets, NSG, identities, and DNS
- ARO classic cluster creation
- optional managed identity cluster creation path for new clusters
- cluster admin detail capture into Key Vault
- managed cluster kubeconfig generation
- optional ACM registration
- optional OpenShift GitOps bootstrap

Customer-managed infrastructure is also supported. In that model, Terraform still creates the ARO cluster, but it uses existing subnet IDs and an existing cluster service principal client ID instead of building those Azure resources.

This is the default model. Teams must explicitly set `infrastructure.create_azure_resources: true` if they want this repo to build Azure infrastructure too.

Why this is the default:

- it reduces blast radius if cluster Terraform state is corrupted
- it keeps shared Azure resources such as VNets, subnets, and DNS out of the normal cluster stack
- it fits enterprise operating models where a cloud team owns shared landing-zone resources and the platform team owns the cluster lifecycle

## Managed Identity

Managed identity is a Terraform feature in this repo, not a GitOps feature.

It is:

- opt-in
- for new clusters only
- currently supported only when this repo also creates the Azure infrastructure

This repo keeps the service principal path as the default because many customer environments still use it.

## GitOps Scope

OpenShift GitOps handles normal cluster configuration after bootstrap:

- identity providers
- RBAC
- registry policy
- monitoring and logging
- operator installs
- application onboarding
