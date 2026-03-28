# GitOps

OpenShift GitOps manages normal in-cluster changes after Terraform finishes bootstrap.

Simple flow:

1. Terraform installs the OpenShift GitOps operator and creates a root `Application`.
2. The root application points to the shared overlay under `gitops/overlays/cluster-applications/`.
3. The shared overlay creates child Argo CD applications.
4. Those child applications deploy platform and workload apps.

Most reusable apps in this repo are Helm charts.

The shared overlay is also a Helm chart. During bootstrap, Terraform passes in the real Git repo URL and Git revision.

How to set up GitOps for one cluster:

- choose apps in `clusters/<environment>/<cluster>/gitops.yaml`
- set `enabled: true` only for the apps you want to run now
- put each app's values in `clusters/<environment>/<cluster>/values/<app>.yaml`
- if an app needs a Kubernetes `Secret`, add its `externalSecrets` entries to that same values file before you enable the app

The sample cluster lists every app that is available now. Only `external-secrets-operator` is enabled by default. Everything else is opt-in.

## Layout

- `bootstrap/openshift-gitops/`: installs the OpenShift GitOps operator
- `bootstrap/root-app/`: creates the root `Application` for a cluster
- `overlays/cluster-applications/`: builds the list of Argo CD applications for a cluster
- `apps/platform/`: reusable platform applications
- `apps/workloads/`: reusable workload applications
