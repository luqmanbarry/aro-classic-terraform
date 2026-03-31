# Terraform vs GitOps Boundary

Use Terraform for build-time and platform bootstrap concerns.

Use OpenShift GitOps for normal cluster configuration after the cluster is reachable.

## Terraform

- optional Azure infrastructure required by the cluster
- ARO classic cluster
- optional managed identity cluster configuration for new clusters
- cluster DNS records
- cluster connection details in Key Vault
- kubeconfig generation for automation
- optional ACM registration
- OpenShift GitOps operator bootstrap
- the shared Azure workload identity and bootstrap metadata secret for the default External Secrets Operator store

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

Managed identity for the ARO cluster itself is a Terraform concern because it changes the cluster identity model and Azure role assignment model. The shared GitOps bootstrap identity for the default External Secrets store is also Terraform-owned because it depends on Azure role assignment and federated credential setup. Day-2 app-specific workload identity remains a GitOps or app-delivery concern after the cluster exists.
