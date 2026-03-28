# GitOps Apps

These are the reusable app targets used by the shared cluster overlay.

## Layout

- `platform/`: platform apps and operators managed by cluster admins
- `workloads/`: workload apps enabled per cluster

Each cluster chooses its apps in `clusters/<environment>/<cluster>/gitops.yaml`.
