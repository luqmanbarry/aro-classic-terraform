# Terraform vs GitOps Boundary

Use Terraform for build-time and platform bootstrap concerns.

Use OpenShift GitOps for normal cluster configuration after the cluster is reachable.

## Terraform

- Azure infrastructure required by the cluster
- ARO classic cluster
- cluster DNS records
- cluster connection details in Key Vault
- kubeconfig generation for automation
- optional ACM registration
- OpenShift GitOps operator bootstrap

## OpenShift GitOps

- operator subscriptions and namespaces
- identity configuration
- logging and monitoring
- image registry policy
- workload enablement

## Boundary Rule

Terraform stops once the cluster and GitOps bootstrap are complete.
Day-2 configuration should be modeled as GitOps applications whenever practical.
