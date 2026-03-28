# Platform Factory

This repo is a reusable way to build ARO classic clusters from files stored in Git.

Simple flow:

1. Users propose cluster inputs in Git.
2. A pull request is reviewed and approved.
3. CI validates and renders the effective configuration.
4. Merge to `main` runs Terraform to:
   - create Azure infrastructure in scope
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
     -> Azure infrastructure
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

- Azure resource group, VNet, subnets, NSG, identities, and DNS
- ARO classic cluster creation
- cluster admin detail capture into Key Vault
- managed cluster kubeconfig generation
- optional ACM registration
- optional OpenShift GitOps bootstrap

## GitOps Scope

OpenShift GitOps handles normal cluster configuration after bootstrap:

- identity providers
- RBAC
- registry policy
- monitoring and logging
- operator installs
- application onboarding
