data "azurerm_client_config" "current" {}

data "azuread_service_principal" "cluster" {
  count     = var.managed_identity.enabled ? 0 : 1
  client_id = var.cluster_sp_client_id
}

resource "azuread_service_principal_password" "cluster" {
  count                = var.managed_identity.enabled ? 0 : 1
  service_principal_id = data.azuread_service_principal.cluster[0].object_id
}

data "azurerm_key_vault_secret" "pull_secret" {
  name         = var.key_vault.pull_secret_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  managed_resource_group_name = "${var.resource_group_name}-resources"
  managed_resource_group_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.managed_resource_group_name}"
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
  managed_identity_arm_ids = {
    for id in values(var.managed_identity_ids) : id => {}
  }
}

resource "azurerm_redhat_openshift_cluster" "cluster" {
  count               = var.managed_identity.enabled ? 0 : 1
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
    client_id     = data.azuread_service_principal.cluster[0].client_id
    client_secret = azuread_service_principal_password.cluster[0].value
  }

  tags = local.resource_tags
}

resource "azapi_resource" "cluster" {
  count                     = var.managed_identity.enabled ? 1 : 0
  type                      = "Microsoft.RedHatOpenShift/openShiftClusters@2024-08-12-preview"
  name                      = var.cluster_name
  parent_id                 = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  location                  = var.azure_region
  schema_validation_enabled = false
  body = {
    identity = {
      type                   = "UserAssigned"
      userAssignedIdentities = local.managed_identity_arm_ids
    }
    properties = {
      clusterProfile = {
        domain               = var.use_azure_provided_domain ? "${var.cluster_name}-${replace(var.cluster.dns_prefix, ".", "-")}" : var.custom_dns_domain_name
        version              = var.openshift_version
        pullSecret           = data.azurerm_key_vault_secret.pull_secret.value
        resourceGroupId      = local.managed_resource_group_id
        fipsValidatedModules = var.fips_enabled ? "Enabled" : "Disabled"
      }
      networkProfile = {
        podCidr     = var.network.pod_cidr
        serviceCidr = var.network.service_cidr
      }
      masterProfile = {
        vmSize           = var.cluster.main_vm_size
        subnetId         = var.main_subnet_id
        encryptionAtHost = "Disabled"
      }
      workerProfiles = [
        {
          name             = "worker"
          vmSize           = var.cluster.worker_vm_size
          diskSizeGB       = var.cluster.worker_disk_size_gb
          count            = var.cluster.worker_node_count
          subnetId         = var.worker_subnet_id
          encryptionAtHost = "Disabled"
        }
      ]
      apiserverProfile = {
        visibility = var.private_cluster ? "Private" : "Public"
      }
      ingressProfiles = [
        {
          name       = "default"
          visibility = var.private_cluster ? "Private" : "Public"
        }
      ]
    }
    tags = local.resource_tags
  }
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = var.managed_identity.enabled ? [azapi_resource.cluster] : [azurerm_redhat_openshift_cluster.cluster]
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
    cluster_id = var.managed_identity.enabled ? azapi_resource.cluster[0].id : azurerm_redhat_openshift_cluster.cluster[0].id
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
    cluster_sp_client_id     = var.managed_identity.enabled ? null : var.cluster_sp_client_id
    cluster_sp_client_secret = var.managed_identity.enabled ? null : azuread_service_principal_password.cluster[0].value
    managed_identity_enabled = var.managed_identity.enabled
    managed_identity_ids     = var.managed_identity_ids
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
