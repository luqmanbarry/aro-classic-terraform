# OADP/Velero Backup & Restore on Azure Red Hat OpenShift

This demo uses Pod file system backup (FSB) to copy pod resources and volume data to a storage account. Pod FSB implies volumes included in the backup must be mounted by pods, even if they are just temporary test pods 

## Pre-requisites
- OpenShift GitOps instance deployed
  - This applies to the backup and restore clusters.
- Ensure network traffic between the backup cluster and the storage account is allowed; as well as traffic between restore cluster and the storage account.
- Sample applications up and running on the backup cluster
- [Prepare the storage account credentials](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure)
  - Multiple options are available, I chose to use qa Storage Account access key which removes the need to have a Service Principal created.
- Store the storage account access key to Azure Key Vault

## Procedure

### Backup
1. Install the [OADP Operator](../oadp-operator/).
  - Register the [oadp-operator](../../argocd-apps/values.aroclassic102.yaml) ArgoCD Application
    ```yaml
    modules:
      - name: oadp-operator
        config_path: gitops/modules/oadp-operator
        sync_wave: 113
    ```
2. Verify applications being backed up are healthy and all volumes mounted.
3. Identity the namespaces you want backed up and provide their names in the [OADP Backup](../oadp-backup/) module's `values.<cluster-name>.yaml` file. 
  - The [OADP Backup](../oadp-backup/) module takes periodic backup of selected namespaces.
  - You should update the backup schedule to your requirements.
4. Deploy the [OADP Backup](../oadp-backup/) module.
  - Register the [oadp-backup](../../argocd-apps/values.aroclassic102.yaml) ArgoCD Application
    ```yaml
    modules:
      - name: oadp-backup
        config_path: gitops/modules/oadp-backup
        sync_wave: 113
    ``` 
5. Wait for the backup to complete.

### Restore

The restore can be applied to different scenarios.
- Restoring backups on the same cluster where they were taken.
- Restoring backups on a different cluster, same or different region.

1. Install the [OADP Operator](../oadp-operator/).
  - **Skip** this step if the restore operation is taking place in the backup cluster.
2. Go the storage account container and find the backups you want to restore
3. Identity the backups you want restored and provide their names in the [OADP Restore](../oadp-restore/) module's `values.<cluster-name>.yaml` file.
4. Deploy the [OADP Restore](../oadp-restore/) module.
  - Register the [oadp-restore](../../argocd-apps/values.aroclassic102.yaml) ArgoCD Application
    ```yaml
    modules:
      - name: oadp-restore
        config_path: gitops/modules/oadp-restore
        sync_wave: 113
    ``` 
5. Wait for the restore to complete.