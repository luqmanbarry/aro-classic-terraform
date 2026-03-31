# GitOps Apps

These are the reusable app targets used by the shared cluster overlay.

## Layout

- `platform/`: platform apps and operators managed by cluster admins
- `workloads/`: workload apps enabled per cluster

Each cluster chooses its apps in `clusters/<group-path>/<cluster>/gitops.yaml`.
Update the matching values file before you enable an app. Never store live credentials in Git; reference Azure Key Vault secrets through External Secrets Operator instead.

The platform app set includes optional storage integrations. Keep them disabled until the storage team has approved the backend, network paths, credentials, and support model for ARO.
