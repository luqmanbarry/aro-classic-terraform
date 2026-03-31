# OADP Operator

Installs the OADP operator and creates the `DataProtectionApplication` resource for Azure-backed backups.

Safe defaults:

- operator install plan approval is `Automatic` because `oadp-backup` and `oadp-restore` depend on OADP CRDs
- backup schedules are not created here
- snapshot tagging is off by default
- the chart expects the Azure client secret to come from Azure Key Vault through External Secrets Operator

Before you enable this chart:

1. Confirm the backup resource group, storage account, blob endpoint, and container.
2. Create or approve the Azure service principal used by Velero.
3. Put the client secret in Azure Key Vault.
4. Review whether you want filesystem backup or CSI snapshots for this cluster.
