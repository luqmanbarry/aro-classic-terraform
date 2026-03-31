# openshift-gitops-bootstrap

Installs OpenShift GitOps and creates the root application that points back to this repo.

This module also creates the shared Azure workload identity used by the default External Secrets Operator `ClusterSecretStore`, grants that identity read access to Key Vault, creates the federated credential for the ESO service account, and writes the client and tenant IDs into the Terraform-owned bootstrap secret namespace.

The bootstrap flow uses one OpenShift GitOps operator and the default admin Argo CD instance in `openshift-gitops`.

The root application points to the shared cluster overlay, which creates:

- the shared `platform` AppProject
- the shared `workloads` AppProject
- the enabled child applications for the cluster

If tenant app delivery is needed later, the `namespace-onboarding` app can create one separate shared tenant Argo CD instance. This repo does not use a second GitOps operator for tenants.
