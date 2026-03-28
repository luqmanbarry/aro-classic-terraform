# Terraform Modules

These are the main Terraform modules used by this repo.

## Module Index

- [factory-stack](./factory-stack/README.md): main module that calls the other modules in order
- [aro-classic-infra](./aro-classic-infra/README.md): Azure infrastructure, identity, and DNS setup
- [aro-classic-core](./aro-classic-core/README.md): ARO classic cluster creation and Key Vault updates
- [aro-classic-kubeconfig](./aro-classic-kubeconfig/README.md): managed cluster kubeconfig generation
- [aro-classic-acm-registration](./aro-classic-acm-registration/README.md): optional ACM registration
- [openshift-gitops-bootstrap](./openshift-gitops-bootstrap/README.md): optional OpenShift GitOps bootstrap
