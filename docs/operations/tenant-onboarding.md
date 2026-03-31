# Tenant Onboarding

This document explains the tenant GitOps and namespace onboarding model in this repo.

Keep the boundary simple:

- Terraform owns Azure infrastructure, the ARO cluster, identities, and GitOps bootstrap.
- GitOps owns namespace setup, shared tenant Argo CD, and approved in-cluster access.

## Admin And Tenant Boundary

Admin-owned:

- central GitOps bootstrap
- all apps under `gitops/apps/platform/`
- all apps under `gitops/apps/workloads/`
- cluster-wide policy and platform configuration
- onboarding approval
- tenant repo approval
- tenant namespace approval

Tenant-owned after approval:

- Argo CD `Application` objects in the shared tenant Argo CD instance
- optional `ApplicationSet` objects when the admin enables them for that tenant
- app-of-apps patterns inside the tenant's approved repositories
- Kubernetes namespace access granted through approved `RoleBinding` objects

## Argo CD Layout

This repo uses two Argo CD layers:

1. Central admin Argo CD
   - bootstrapped by Terraform
   - admin-only
   - targets this platform repo

2. Shared tenant Argo CD
   - created by `namespace-onboarding` only when enabled
   - shared by many teams
   - one `AppProject` per tenant
   - each tenant is limited to approved namespaces and approved repos

## Approval Flow

1. Admin reviews the tenant request.
2. Admin adds tenant namespaces and optional guardrails in `namespace-onboarding`.
3. Admin enables shared tenant Argo CD if needed.
4. Admin adds the tenant definition with approved repos, namespaces, groups, and optional `ApplicationSet` access.
5. Admin merges the change.
6. Tenant users can then use the shared tenant Argo CD instance.

## Namespace Guardrails

Guardrails are optional and can be set per namespace:

- `ResourceQuota`
- `LimitRange`
- baseline `NetworkPolicy`
- feature intent labels and annotations
- feature-specific namespace `RoleBinding` objects

They are not forced on unless the admin adds them.

## Feature Enrollment

`namespace-onboarding` can also record namespace-level opt-in for shared platform capabilities.

Current supported feature intent:

- `serviceMesh`
- `openshiftAI`
- `cp4ba`
- `aap`

Important rule:

- feature flags do not create tenant operator subscriptions
- the shared platform or workload module must already be installed by admins
- feature flags are used to record approved namespace participation and access bindings

## Repo Credentials

Tenant repo credentials live in the shared tenant Argo CD namespace.

Rules:

- use `ExternalSecret`
- do not store plaintext credentials in Git
- use Azure Key Vault as the default pattern
- every repo credential must match an approved repo URL for that tenant

## ApplicationSet

`ApplicationSet` is disabled by default for tenants.

Allow it only when:

- the tenant needs generator-based app management
- the tenant repo and namespace boundaries are already approved
- the platform team accepts the extra governance risk
