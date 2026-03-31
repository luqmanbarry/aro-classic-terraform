# External Secrets Operator

Installs External Secrets Operator and the shared Azure Key Vault `ClusterSecretStore`.

Safe defaults:

- Azure Key Vault is the default provider pattern
- operator install plan approval is `Automatic` because many charts in this repo depend on ESO CRDs
- the chart fails fast if the Azure tenant ID or vault URL is still a placeholder
- app secrets should stay in the app charts; this chart is only for the shared operator and shared store

Required inputs:

- a running ARO cluster
- an Azure service principal or equivalent secret with read access to Key Vault
- real `tenantID` and `vaultURL` values in the cluster values file
