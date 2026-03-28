# factory-stack

This is the main module for the ARO classic factory layout.

It calls the other modules in this order:

```text
factory-stack
  -> optional aro-classic-infra
  -> aro-classic-core
  -> aro-classic-kubeconfig
  -> optional aro-classic-acm-registration
  -> optional openshift-gitops-bootstrap
```

The default is customer-managed infrastructure.

Use `infrastructure.create_azure_resources: true` when you want this repo to build Azure resources such as the resource group, VNet, subnets, service principal, and DNS.

Use `infrastructure.create_azure_resources: false` when the customer already has a cloud team managing those Azure resources. In that case, pass the existing subnet IDs and cluster service principal client ID through `infrastructure.existing`.

This default reduces blast radius. If a cluster stack has Terraform state problems, it is less likely to damage shared Azure resources that may be used by other clusters.
