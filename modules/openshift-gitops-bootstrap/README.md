# openshift-gitops-bootstrap

Installs OpenShift GitOps and creates the root application that points back to this repo.

The bootstrap flow uses one OpenShift GitOps operator and the default admin Argo CD instance in `openshift-gitops`.

The root application points to the shared cluster overlay, which creates:

- the shared `platform` AppProject
- the shared `workloads` AppProject
- the enabled child applications for the cluster

If tenant app delivery is needed later, the `namespace-onboarding` app can create one separate shared tenant Argo CD instance. This repo does not use a second GitOps operator for tenants.
