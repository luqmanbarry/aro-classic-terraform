# External Secrets Operator

Installs External Secrets Operator and the shared Azure Key Vault `ClusterSecretStore`.

Safe defaults:

- Azure Key Vault is the default provider pattern
- operator install plan approval is `Automatic` because many charts in this repo depend on ESO CRDs
- workload identity is the default auth mode for the shared store
- service principal auth is still supported as an opt-in override
- the chart fails fast if the Azure tenant ID or vault URL is still a placeholder
- app secrets should stay in the app charts; this chart is only for the shared operator and shared store

Required inputs:

- a running ARO cluster
- for workload identity, the Terraform bootstrap module must create the Azure workload identity and bootstrap metadata secret
- for service principal auth, provide a Kubernetes secret with the client ID and client secret
- real `tenantID` and `vaultURL` values in the cluster values file

Key Vault note:

- the default bootstrap path in this repo uses Key Vault RBAC role assignments for the shared GitOps identity
- use `key_vault.authorization_mode: access_policy` only when you must support an older vault permission model
