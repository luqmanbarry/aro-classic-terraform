data "azurerm_key_vault_secret" "cluster_details" {
  name         = var.cluster_details_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  cluster_details = jsondecode(data.azurerm_key_vault_secret.cluster_details.value)
}

resource "null_resource" "managed_cluster_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
mkdir -p "$(dirname "$KUBECONFIG")"
mkdir -p "$(dirname "$DEST")"
export KUBECONFIG="$KUBECONFIG"
oc login -u "$USERNAME" -p "$PASSWORD" "$API_SERVER" --insecure-skip-tls-verify
cp "$KUBECONFIG" "$DEST"
EOT
    environment = {
      KUBECONFIG = var.default_kubeconfig_filename
      DEST       = var.managed_cluster_kubeconfig_filename
      USERNAME   = local.cluster_details.admin_username
      PASSWORD   = local.cluster_details.admin_password
      API_SERVER = local.cluster_details.api_server_url
    }
  }

  triggers = {
    secret_version = data.azurerm_key_vault_secret.cluster_details.version
  }
}

data "azurerm_key_vault_secret" "acmhub_details" {
  count        = var.acmhub_registration_enabled && length(trimspace(var.acmhub_details_secret_name)) > 0 ? 1 : 0
  name         = var.acmhub_details_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  acmhub_details = length(data.azurerm_key_vault_secret.acmhub_details) > 0 ? jsondecode(data.azurerm_key_vault_secret.acmhub_details[0].value) : null
}

resource "null_resource" "acmhub_kubeconfig" {
  count      = local.acmhub_details == null ? 0 : 1
  depends_on = [null_resource.managed_cluster_kubeconfig]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
mkdir -p "$(dirname "$KUBECONFIG")"
mkdir -p "$(dirname "$DEST")"
export KUBECONFIG="$KUBECONFIG"
oc login -u "$USERNAME" -p "$PASSWORD" "$API_SERVER" --insecure-skip-tls-verify
cp "$KUBECONFIG" "$DEST"
EOT
    environment = {
      KUBECONFIG = var.default_kubeconfig_filename
      DEST       = var.acmhub_kubeconfig_filename
      USERNAME   = local.acmhub_details.admin_username
      PASSWORD   = local.acmhub_details.admin_password
      API_SERVER = local.acmhub_details.api_server_url
    }
  }

  triggers = {
    secret_version = local.acmhub_details.cluster_name
  }
}
