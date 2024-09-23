#========================= BEGIN: STATIC VARIABLES ===================================

azure_cloud_environment       = "AzurePublicCloud"
private_cluster               = false # Whether to deploy private|public cluster
redhatopenshift_sp_client_id  = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
resource_name_suffix          = "platformops"
cert_issuer_email             = "dhabbhoufaamou@gmail.com"
cert_issuer_server            = "https://acme-v02.api.letsencrypt.org/directory"
#================ OCP CLUSTER =========================================================
dns_ttl                       = 300
tls_certificates_ttl_seconds  = "15638400s"
autoscaling_enabled           = true
dns_tls_certificates_subject = {
  country = "United States"
  locality = "Raleigh"
  organizationalUnit = "Research & Development (RND)"
  organization = "SAMA-WAT LLC"
  province = "North Carolina"
  postalCode = "27601"
  streetAddresse = "100 East Davie Street"
}

pod_cidr                      = "172.128.0.0/14"
service_cidr                  = "172.127.0.0/16"

cluster_inbound_network_security_rules = [
    {
      name              = "allow-inbound-from-ops-ocp"
      source_cidrs      = "10.254.0.0/24"
      target_cidrs      = "*"
      source_port_range = "30000-32900"
      target_port_range = "*"
      protocol          = "Tcp"
    },
    {
      name              = "allow-inbound-from-vendor-svc"
      source_cidrs      = "10.10.0.0/24"
      target_cidrs      = "*"
      source_port_range = "8000-9000"
      target_port_range = "*"
      protocol          = "Tcp"
    }
]

default_tags = {
  "contact_us" = "lbarry@redhat.com"
  "team_owner" = "platform-ops@example.com"
  "cluster_type" = "aro"
  # More default tags here

}

#================= GIT MGMT OF TFVARS ================================================
git_base_url            = "https://github.com/"
git_owner               = "luqmanbarry"
git_repository_name          = "aro-classic-terraform"
git_branch         = "main"
git_commit_email        = "dhabbhoufaamou@gmail.com"


#========================= END: STATIC VARIABLES =====================================

#%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

organization="stig0001"

subscription_id="8f241089-b3a4-4149-92fa-6ad27bbf95f7"

vnet_name="aro-stig0001"

vnet_cidr="10.91.0.0/22"

main_subnet_cidr="10.91.1.0/24"

main_subnet_id="/subscriptions/8f241089-b3a4-4149-92fa-6ad27bbf95f7/resourceGroups/aro-stig0001/providers/Microsoft.Network/virtualNetworks/aro-stig0001/subnets/aro-stig0001-main-subnet"

worker_subnet_cidr="10.91.2.0/24"

worker_subnet_id="/subscriptions/8f241089-b3a4-4149-92fa-6ad27bbf95f7/resourceGroups/aro-stig0001/providers/Microsoft.Network/virtualNetworks/aro-stig0001/subnets/aro-stig0001-worker-subnet"

location="eastus"

platform_environment="dev"

cluster_name="aro-stig0001"

cluster_details_vault_secret_name="openshift-dev-aro-stig0001-cluster-details"

acmhub_details_vault_secret_name="openshift-dev-aro-acm-hub-102-cluster-details"

cluster_service_principal="aro-stig0001"

cluster_sp_client_id="6d8902d3-d3a1-43b3-873a-bfcc92188065"

cluster_resource_group="aro-stig0001"

cost_center="47007"

ocp_version="4.15.16"

acmhub_registration_enabled=false

default_kubeconfig_filename="/Users/luqman/.kube/config"

managed_cluster_kubeconfig_filename="/Users/luqman/.managed_cluster_kube/config"

acmhub_kubeconfig_filename="/Users/luqman/.acmhub_kube/config"

acmhub_cluster_name="aro-acm-hub-102"

main_vm_size="Standard_D8s_v3"

worker_vm_size="Standard_D4s_v3"

worker_node_count=3

worker_disk_size_gb=200

tfstate_resource_group="stig0001-dev-tfstate"

tfstate_storage_account_name="stig0001devtfstate"

tfstate_storage_container="ocp-tfstate"

inbound_network_security_group_name="aro-stig0001"

base_dns_zone_name="openshift.sama-wat.com"

base_dns_zone_resource_group="aro-dns-zones"

root_dns_domain="sama-wat.com"

fips_enabled=true

use_azure_provided_domain=true

custom_dns_domain_prefix="aro-stig0001.dev.eastus.stig0001"

custom_dns_domain_name="aro-stig0001.dev.eastus.stig0001.openshift.sama-wat.com"

key_vault_name="stig0001-dev-vault"

key_vault_resource_group="stig0001-dev-vault"

key_vault_id="/subscriptions/8f241089-b3a4-4149-92fa-6ad27bbf95f7/resourceGroups/stig0001-dev-vault/providers/Microsoft.KeyVault/vaults/stig0001-dev-vault"

pull_secret_vault_path="openshift-dev-pull-secret"

acmhub_cluster_env="dev"

acmhub_vault_secret_name="openshift-dev-acmhub-aro-acm-hub-102"

cluster_infra_tags={"cluster_name"="aro-stig0001","cluster_type"="aro","contact_us"="lbarry@redhat.com","cost_center"="47007","created_by"="lbarry@redhat.com (lbarry@redhat.com)","environment"="dev","organization"="stig0001","team_owner"="platform-ops@example.com"}

#%%%%%%%%%%%%%%%%%%%%%%%%% END: DERIVED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%