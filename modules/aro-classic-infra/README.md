# aro-classic-infra

Creates the Azure setup needed before the ARO cluster is created:

- resource group
- VNet and subnets
- network security group rules
- cluster service principal and Azure role assignments
- Key Vault access policy for the cluster identity
- optional child DNS zone and NS delegation
