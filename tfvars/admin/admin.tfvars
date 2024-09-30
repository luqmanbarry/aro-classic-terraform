redhatopenshift_sp_client_id  = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
resource_name_suffix          = "platformops"
cert_issuer_email             = "dhabbhoufaamou@gmail.com"
cert_issuer_server            = "https://acme-v02.api.letsencrypt.org/directory"
tf_resources_namespace        = "tf-resources"
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
git_org                 = "luqmanbarry"
git_username            = "git"
git_repository_name     = "aro-classic-terraform"
git_branch              = "main"
git_commit_email        = "dhabbhoufaamou@gmail.com"
