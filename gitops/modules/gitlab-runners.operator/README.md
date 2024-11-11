# GitLab Runners Helm Chart

This helm chart deploys GitLab runners. Additionally, it deploys one or more `BuildConfig` CRs to build the custom images used as container image by the job executiion pods.

As an example, the openshift-cicd-tools BuildConfig is added. The pattern is to add a `BuildConfig` CR for each additional `Runner` CR.

## Inputs

Required inputs are defined in the [values.yaml](./values.yaml) file of the helm chart. 

The recommended pattern is to keep all common (defaults) parameters set in the `values.yaml` and overwrite params that change per cluster in the `values.cluster-name.yaml` file.

## Dependencies

- Up & Running ARO cluster
- [External Secrets Operator](../external-secrets-operator/)
- GitLab Runner token stored in Azure KeyVault