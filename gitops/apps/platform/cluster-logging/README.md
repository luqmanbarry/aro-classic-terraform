# Cluster Logging

Installs the OpenShift Logging operator and creates `ClusterLogging` and `ClusterLogForwarder` resources for Splunk forwarding.

Safe defaults:

- operator install plan approval is `Manual`
- the chart fails fast if the cluster name or Splunk endpoint still uses placeholder values
- the HEC token is read by `ExternalSecret` from the shared Azure Key Vault store

Before you enable this chart:

1. Make sure `external-secrets-operator` and `external-secrets-config` are already working.
2. Put the Splunk HEC token in Azure Key Vault.
3. Set real values in `clusters/<group-path>/<cluster>/values/cluster-logging.yaml`.

Main inputs:

- `keyVaultName`: shared `ClusterSecretStore` name, usually `platform-secrets`
- `hecKeyVaultSecretName`: Key Vault secret name for the HEC token
- `splunk.endpoint`: real Splunk HEC URL
- `splunk.indexName`: Splunk index for forwarded logs
