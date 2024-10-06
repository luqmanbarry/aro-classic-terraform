resource "azurerm_resource_group" "ocp_cluster_rg" {
  name        = var.cluster_name
  location    = var.location

  tags        = local.resource_tags

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_virtual_network" "ocp_cluster_vnet" {
  name                = var.cluster_name
  address_space       = [ var.vnet_cidr ]
  location            = azurerm_resource_group.ocp_cluster_rg.location
  resource_group_name = azurerm_resource_group.ocp_cluster_rg.name

  tags                = local.resource_tags

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_subnet" "ocp_cluster_main_subnet" {
  name                 = format("%s-main-subnet", var.cluster_name)
  resource_group_name  = azurerm_resource_group.ocp_cluster_rg.name
  virtual_network_name = azurerm_virtual_network.ocp_cluster_vnet.name
  address_prefixes     = [ var.main_subnet_cidr ]
  service_endpoints    = [ "Microsoft.Storage", "Microsoft.ContainerRegistry" ]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "ocp_cluster_worker_subnet" {
  name                 = format("%s-worker-subnet", var.cluster_name)
  resource_group_name  = azurerm_resource_group.ocp_cluster_rg.name
  virtual_network_name = azurerm_virtual_network.ocp_cluster_vnet.name
  address_prefixes     = [ var.worker_subnet_cidr ]
  service_endpoints    = [ "Microsoft.Storage", "Microsoft.ContainerRegistry" ]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_network_security_group" "inbound_traffic_security_group" {
  name                = var.cluster_name
  location            = azurerm_resource_group.ocp_cluster_rg.location
  resource_group_name = azurerm_resource_group.ocp_cluster_rg.name

  tags                = local.derived_tags

  lifecycle {
    ignore_changes = [ tags ]
  }
}


resource "azurerm_network_security_rule" "inbound_traffic_security_rules" {
  resource_group_name         = azurerm_resource_group.ocp_cluster_rg.name
  network_security_group_name = azurerm_network_security_group.inbound_traffic_security_group.name

  count                       = length(var.inbound_traffic_security_rules)

  name                        = var.inbound_traffic_security_rules[count.index].name
  priority                    = (100 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = var.inbound_traffic_security_rules[count.index].protocol
  source_port_range           = var.inbound_traffic_security_rules[count.index].source_port_range
  destination_port_range      = var.inbound_traffic_security_rules[count.index].target_port_range
  source_address_prefix       = var.inbound_traffic_security_rules[count.index].source_cidrs
  destination_address_prefix  = var.inbound_traffic_security_rules[count.index].target_cidrs
}

data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

resource "azuread_application" "ocp_cluster_application" {
  depends_on        = [ azurerm_network_security_rule.inbound_traffic_security_rules ]
  display_name      = var.cluster_name
  owners            = toset( [ data.azuread_client_config.current.object_id ] )

  # tags = local.resource_tags
}

resource "azuread_service_principal" "ocp_cluster_sp" {
  client_id   = azuread_application.ocp_cluster_application.client_id
  description = format("The service principal used by cluster %s to interact with Azure services", var.cluster_name)
  owners      = [ data.azuread_client_config.current.object_id ]

  # tags = local.resource_tags
}

resource "null_resource" "export_cluster_sp_client_id" {
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "echo -n \"$CLUSTER_SP_CLIENT_ID\" > \"$CLUSTER_SP_CLIENT_ID_FILE_NAME\" "
    environment = {
      CLUSTER_SP_CLIENT_ID           = azuread_service_principal.ocp_cluster_sp.client_id
      CLUSTER_SP_CLIENT_ID_FILE_NAME = local.cluster_sp_client_id_filename
    }
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}

data "azurerm_key_vault" "bu_keyvault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

resource "azurerm_key_vault_access_policy" "grant_keyvault_read" {
  key_vault_id  = data.azurerm_key_vault.bu_keyvault.id
  tenant_id     = data.azuread_client_config.current.tenant_id
  object_id     = azuread_service_principal.ocp_cluster_sp.object_id

  secret_permissions = [ "Get", "List", "Set" ]
}

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  client_id = var.redhatopenshift_sp_client_id
}

resource "azurerm_role_assignment" "role_network_contributor_rg" {
  scope                = azurerm_resource_group.ocp_cluster_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.ocp_cluster_sp.object_id
}

resource "azurerm_role_assignment" "redhatopenshift_network_contributor_vnet" {
  scope                = azurerm_virtual_network.ocp_cluster_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

resource "azurerm_role_assignment" "role_contributor_rg" {
  scope                = azurerm_resource_group.ocp_cluster_rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ocp_cluster_sp.object_id
}

resource "azurerm_role_assignment" "role_user_access_administrator_rg" {
  scope                = azurerm_resource_group.ocp_cluster_rg.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.ocp_cluster_sp.object_id
}

# Create child DNS Zone for the cluster
resource "azurerm_dns_zone" "cluster_dns_zone" {
  depends_on          = [ azurerm_role_assignment.role_user_access_administrator_rg ]
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = local.custom_dns_domain_name
  resource_group_name = var.base_dns_zone_resource_group

  tags = local.resource_tags

  timeouts {
    create = "10m"
    delete = "30m"
    read   = "10m"
  }
}

## Create an NS record in the base DNS zone
resource "azurerm_dns_ns_record" "child_dns_zone" {
  depends_on          = [ azurerm_dns_zone.cluster_dns_zone ]
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = local.custom_dns_domain_prefix
  zone_name           = var.base_dns_zone_name
  resource_group_name = var.base_dns_zone_resource_group
  ttl                 = var.dns_ttl
  records             = azurerm_dns_zone.cluster_dns_zone[0].name_servers

  tags                = local.resource_tags

  timeouts {
    create = "10m"
    delete = "30m"
    read   = "10m"
  }
}
