data "azuread_service_principal" "cluster" {
  client_id = var.cluster_sp_client_id
}

resource "azuread_service_principal_password" "cluster" {
  service_principal_id = data.azuread_service_principal.cluster.object_id
}

data "azurerm_key_vault_secret" "pull_secret" {
  name         = var.key_vault.pull_secret_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  managed_resource_group_name = "${var.resource_group_name}-resources"
  resource_tags = merge(
    {
      cluster_name = var.cluster_name
      owner        = var.business_metadata.owner
      environment  = var.environment
      cost_center  = var.business_metadata.cost_center
      contact      = var.business_metadata.contact
    },
    var.default_tags,
  )

  console_url_file    = "${var.temp_dir}/console_url"
  ingress_ip_file     = "${var.temp_dir}/ingress_lb_ip"
  api_server_url_file = "${var.temp_dir}/api_server_url"
  api_server_ip_file  = "${var.temp_dir}/api_server_lb_ip"
  admin_username_file = "${var.temp_dir}/admin_username"
  admin_password_file = "${var.temp_dir}/admin_password"
}

resource "azurerm_redhat_openshift_cluster" "cluster" {
  name                = var.cluster_name
  location            = var.azure_region
  resource_group_name = var.resource_group_name

  cluster_profile {
    managed_resource_group_name = local.managed_resource_group_name
    domain                      = var.use_azure_provided_domain ? "${var.cluster_name}-${replace(var.cluster.dns_prefix, ".", "-")}" : var.custom_dns_domain_name
    version                     = var.openshift_version
    pull_secret                 = data.azurerm_key_vault_secret.pull_secret.value
    fips_enabled                = var.fips_enabled
  }

  network_profile {
    pod_cidr     = var.network.pod_cidr
    service_cidr = var.network.service_cidr
  }

  main_profile {
    vm_size                    = var.cluster.main_vm_size
    subnet_id                  = var.main_subnet_id
    encryption_at_host_enabled = false
  }

  worker_profile {
    vm_size                    = var.cluster.worker_vm_size
    disk_size_gb               = var.cluster.worker_disk_size_gb
    node_count                 = var.cluster.worker_node_count
    subnet_id                  = var.worker_subnet_id
    encryption_at_host_enabled = false
  }

  api_server_profile {
    visibility = var.private_cluster ? "Private" : "Public"
  }

  ingress_profile {
    visibility = var.private_cluster ? "Private" : "Public"
  }

  service_principal {
    client_id     = data.azuread_service_principal.cluster.client_id
    client_secret = azuread_service_principal_password.cluster.value
  }

  tags = local.resource_tags
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = [azurerm_redhat_openshift_cluster.cluster]
  create_duration = "300s"
}

resource "null_resource" "cluster_details" {
  depends_on = [time_sleep.wait_for_cluster]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p \"$TMP_DIR\""
    environment = {
      TMP_DIR = var.temp_dir
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro show --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query consoleProfile.url -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.console_url_file
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro show --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query ingressProfiles[0].ip -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.ingress_ip_file
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro show --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query apiserverProfile.url -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.api_server_url_file
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro show --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query apiserverProfile.ip -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.api_server_ip_file
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro list-credentials --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query kubeadminUsername -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.admin_username_file
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "az aro list-credentials --name \"$CLUSTER\" --resource-group \"$RESOURCEGROUP\" --query kubeadminPassword -o tsv | xargs > \"$OUTPUT_FILE\""
    environment = {
      CLUSTER       = var.cluster_name
      RESOURCEGROUP = var.resource_group_name
      OUTPUT_FILE   = local.admin_password_file
    }
  }

  triggers = {
    cluster_id = azurerm_redhat_openshift_cluster.cluster.id
  }
}

data "local_file" "console_url" {
  depends_on = [null_resource.cluster_details]
  filename   = local.console_url_file
}

data "local_file" "ingress_ip" {
  depends_on = [null_resource.cluster_details]
  filename   = local.ingress_ip_file
}

data "local_file" "api_server_url" {
  depends_on = [null_resource.cluster_details]
  filename   = local.api_server_url_file
}

data "local_file" "api_server_ip" {
  depends_on = [null_resource.cluster_details]
  filename   = local.api_server_ip_file
}

data "local_file" "admin_username" {
  depends_on = [null_resource.cluster_details]
  filename   = local.admin_username_file
}

data "local_file" "admin_password" {
  depends_on = [null_resource.cluster_details]
  filename   = local.admin_password_file
}

locals {
  cluster_details = {
    cluster_name             = var.cluster_name
    console_url              = trimspace(data.local_file.console_url.content)
    api_server_url           = trimspace(data.local_file.api_server_url.content)
    admin_username           = trimspace(data.local_file.admin_username.content)
    admin_password           = trimspace(data.local_file.admin_password.content)
    ingress_lb_ip            = trimspace(data.local_file.ingress_ip.content)
    api_server_lb_ip         = trimspace(data.local_file.api_server_ip.content)
    openshift_version        = var.openshift_version
    cluster_sp_client_id     = var.cluster_sp_client_id
    cluster_sp_client_secret = azuread_service_principal_password.cluster.value
  }
}

resource "azurerm_key_vault_secret" "cluster_details" {
  name         = var.key_vault.cluster_details_secret_name
  value        = jsonencode(local.cluster_details)
  key_vault_id = var.key_vault_id
  content_type = "application/json"
  tags         = local.resource_tags
}

resource "azurerm_dns_a_record" "ingress" {
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = "*.apps"
  resource_group_name = var.base_dns_zone_resource_group
  zone_name           = var.custom_dns_domain_name
  ttl                 = var.network.dns_ttl
  records             = [local.cluster_details.ingress_lb_ip]
  tags                = local.resource_tags
}

resource "azurerm_dns_a_record" "api" {
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = "api"
  resource_group_name = var.base_dns_zone_resource_group
  zone_name           = var.custom_dns_domain_name
  ttl                 = var.network.dns_ttl
  records             = [local.cluster_details.api_server_lb_ip]
  tags                = local.resource_tags
}
