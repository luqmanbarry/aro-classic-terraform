# Terraform vs GitOps Boundary

Use Terraform for build-time and platform bootstrap concerns.

Use OpenShift GitOps for normal cluster configuration after the cluster is reachable.

## Terraform

- optional Azure infrastructure required by the cluster
- ARO classic cluster
- cluster DNS records
- cluster connection details in Key Vault
- kubeconfig generation for automation
- optional ACM registration
- OpenShift GitOps operator bootstrap

When Azure infrastructure is customer-managed, Terraform for the cluster has a smaller blast radius. Problems in cluster state are less likely to affect shared VNets, subnets, and DNS that may be used by other clusters.

## OpenShift GitOps

- one OpenShift GitOps operator per cluster
- one admin Argo CD instance for shared platform and workload apps
- one optional shared tenant Argo CD instance for approved app teams
- operator subscriptions and namespaces
- identity configuration
- logging and monitoring
- image registry policy
- Azure Key Vault secret sync through External Secrets Operator
- extra worker `MachineSet` objects
- `MachineAutoscaler` and `ClusterAutoscaler` objects
- workload enablement

## Boundary Rule

Terraform stops once the cluster and GitOps bootstrap are complete.
Day-2 configuration should be modeled as GitOps applications whenever practical.
