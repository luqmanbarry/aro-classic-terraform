# GitOps

OpenShift GitOps manages normal in-cluster changes after Terraform finishes bootstrap.

## GitOps Flow

1. Terraform installs the OpenShift GitOps operator and creates the root `Application`.
2. The root app points to `gitops/overlays/cluster-applications/`.
3. The shared overlay creates the `platform` and `workloads` AppProjects and their child applications.
4. Each child application syncs a chart from `gitops/apps/platform` or `gitops/apps/workloads`.

## Argo CD Model

- One GitOps operator per cluster in `openshift-gitops`.
- The admin Argo CD instance owns shared platform and workload applications.
- `namespace-onboarding` can optionally create one shared tenant Argo CD instance for approved teams.
- Tenant teams do not get their own GitOps operator.

## GitOps Modules

- Azure Key Vault plus External Secrets Operator is the default secret pattern.
- The shared Azure Key Vault store uses workload identity. Terraform creates the Azure identity, federated credential, and bootstrap metadata secret. GitOps creates the `ClusterSecretStore` and in-cluster service account.
- Platform charts cover identity, RBAC, logging, monitoring, registry policy, onboarding, operator bootstrap, and optional storage integration patterns.
- Workload charts cover shared platforms such as AAP, OpenShift AI, and CP4BA.
- `namespace-onboarding` can record namespace-level feature intent and access bindings for shared features such as service mesh, OpenShift AI, CP4BA, and AAP while keeping operator subscriptions under admin control.
- Foundational operators that provide CRDs for other repo charts use automatic approval by default. High-risk optional operators that do not unblock dependent charts stay on manual approval.
- High-risk charts use safer defaults: no example tenant resources, no default admin RBAC, manual install approval for optional operators, and fail-fast checks when required backend values are still placeholders.
- Vendor storage charts stay disabled by default and document that the storage backend, secrets, and vendor support remain environment-specific.

## How To Enable Apps

- Choose apps in `clusters/<group-path>/<cluster>/gitops.yaml`.
- Put each app's values in `clusters/<group-path>/<cluster>/values/<app>.yaml`.
- Keep secrets out of Git. Put them in Azure Key Vault and sync them with External Secrets Operator.

## Layout

- `bootstrap/openshift-gitops/`: installs the OpenShift GitOps operator
- `bootstrap/root-app/`: creates the root `Application` for a cluster
- `overlays/cluster-applications/`: builds the list of Argo CD applications for a cluster
- `apps/platform/`: reusable platform applications
- `apps/workloads/`: reusable workload applications
