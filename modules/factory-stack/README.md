# factory-stack

This is the main module for the ARO classic factory layout.

It calls the other modules in this order:

```text
factory-stack
  -> aro-classic-infra
  -> aro-classic-core
  -> aro-classic-kubeconfig
  -> optional aro-classic-acm-registration
  -> optional openshift-gitops-bootstrap
```
