# AKS to ARO application migration - WIP

## Pre-requisites
* Azure permission to:
** Create/Delete Azure Disks
** Read Storage Account & Container
* Azure Service Principal (used by Velero in ARO) that has read access to the AKS Storage Container hosting the Velero backups
* Admin access to an AKS cluster
* Admin access to an ARO cluster
* CLI Programs: velero, openshift-client, helm, jq
* Network connectivity:
** Bastion to AKS
** Bastion to ARO

## Procedure

We start from a stage where Velero has been periodically taking AKS application backups. Velero Backup stores Kubernetes objects manifests such as Secrets, ConfigMaps, Deployments... inside a storage container, and take disks snapshots of application persistent state (data). 

We are primarily going to look at how to setup Velero on ARO, and run Velero Restore.

1. Install Velero on the target (ARO) cluster
   1. Prepare the velero helm chart values file
    ```yaml
    
    ```
   2. 
    ```sh
    
    helm upgrade velero vmware-tanzu-repo/velero -f aro-values.yaml --description "Aro deploy" --version 2.27.0 --install
    ```
2. Configure Velero to target the AKS backup storage account
3. Configure StorageClass mapping (needs to run before pulling down backups)
   * For example: We are migrating from AKS `managed-premium` StorageClass to ARO `managed-csi`.
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
        # any name can be used; Velero uses the labels (below)
        # to identify it rather than the name
        name: change-storage-class-config
        # must be in the velero namespace
        namespace: velero
        # the below labels should be used verbatim in your
        # ConfigMap.
        labels:
            # this value-less label identifies the ConfigMap as
            # config for a plugin (i.e. the built-in change storage
            # class restore item action plugin)
            velero.io/plugin-config: ""
            # this label identifies the name and kind of plugin
            # that this ConfigMap is for.
            velero.io/change-storage-class: RestoreItemAction
    data:
        # add 1+ key-value pairs here, where the key is the old
        # storage class name and the value is the new storage
        # class name.
        managed-premium: `managed-csi`
    ```
4. Pull down the AKS backups into ARO
5. Apply the privileged SecurityContextConstraints CR onto the ARO cluster
6. Ensure AKS disks sku is set to match that of ARO (ie: LRS --> ZRS)
* Scale down AKS applications
* Change the AKS disk sku
* Scale up the AKS application
1. Do Velero restore with resource inclusion (ie: Secrets, ConfigMaps, PersistentVolumes, PersistentVolumeClaims)
2. Helm install the restored application to create excluded resources
3.  Create Routes/Ingress if applicable
4.   Validate the applications