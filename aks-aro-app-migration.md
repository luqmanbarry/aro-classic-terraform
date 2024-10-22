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

We are starting from a stage where Velero has been periodically taking AKS application backups. Velero Backup stores Kubernetes objects manifests such as Secrets, ConfigMaps, Deployments... inside a storage container, and take disks snapshots of application persistent state (data). 

We are primarily going to look at how to setup Velero on ARO, and run Velero Restore.

1. Install Velero on the target (ARO) cluster 
    ```sh
    
    ```
2. Configure Velero to target the AKS backup storage account
3. Configure StorageClass mapping (needs to run before pulling down backups)
4. Pull down the AKS backups into ARO
5. Apply the privileged SecurityContextConstraints CR onto the ARO cluster
6. Ensure AKS disks sku is set to match that of ARO (ie: LRS --> ZRS)
* Scale down AKS applications
* Change the AKS disk sku
* Scale up the AKS application
7. Do Velero restore with resource inclusion (ie: Secrets, ConfigMaps, PersistentVolumes, PersistentVolumeClaims)
8. Helm install the restored application to create excluded resources
9.  Create Routes/Ingress if applicable
10.  Validate the applications