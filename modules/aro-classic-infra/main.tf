data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

data "azurerm_key_vault" "target" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group
}

data "azuread_service_principal" "redhatopenshift" {
  client_id = var.redhatopenshift_sp_client_id
}

locals {
  custom_dns_domain_name = "${var.cluster.dns_prefix}.${var.network.base_dns_zone_name}"
  managed_identity_names = {
    aro_cluster              = "${var.cluster_name}-aro-cluster"
    cloud_controller_manager = "${var.cluster_name}-cloud-controller-manager"
    ingress                  = "${var.cluster_name}-ingress"
    machine_api              = "${var.cluster_name}-machine-api"
    disk_csi_driver          = "${var.cluster_name}-disk-csi-driver"
    cloud_network_config     = "${var.cluster_name}-cloud-network-config"
    image_registry           = "${var.cluster_name}-image-registry"
    file_csi_driver          = "${var.cluster_name}-file-csi-driver"
    aro_operator             = "${var.cluster_name}-aro-operator"
  }
  managed_identity_roles = {
    cloud_controller_manager = {
      role   = "Azure Red Hat OpenShift Cloud Controller Manager"
      scopes = [azurerm_subnet.main.id, azurerm_subnet.worker.id]
    }
    ingress = {
      role   = "Azure Red Hat OpenShift Cluster Ingress Operator"
      scopes = [azurerm_subnet.main.id, azurerm_subnet.worker.id]
    }
    machine_api = {
      role   = "Azure Red Hat OpenShift Machine API Operator"
      scopes = [azurerm_subnet.main.id, azurerm_subnet.worker.id]
    }
    aro_operator = {
      role   = "Azure Red Hat OpenShift Service Operator"
      scopes = [azurerm_subnet.main.id, azurerm_subnet.worker.id]
    }
    cloud_network_config = {
      role   = "Azure Red Hat OpenShift Network Operator"
      scopes = [azurerm_virtual_network.cluster.id]
    }
    image_registry = {
      role   = "Azure Red Hat OpenShift Image Registry Operator"
      scopes = [azurerm_virtual_network.cluster.id]
    }
    file_csi_driver = {
      role   = "Azure Red Hat OpenShift File Storage Operator"
      scopes = [azurerm_virtual_network.cluster.id]
    }
  }
  managed_identity_scope_assignments = flatten([
    for identity_key, assignment in local.managed_identity_roles : [
      for scope in assignment.scopes : {
        key          = "${identity_key}-${replace(scope, "/", "_")}"
        identity_key = identity_key
        role         = assignment.role
        scope        = scope
      }
    ]
  ])

  derived_tags = {
    cluster_name = var.cluster_name
    owner        = var.business_metadata.owner
    environment  = var.environment
    cost_center  = var.business_metadata.cost_center
    contact      = var.business_metadata.contact
    created_by   = data.azuread_user.current.user_principal_name
  }

  resource_tags = merge(local.derived_tags, var.default_tags)
}

resource "azurerm_resource_group" "cluster" {
  name     = var.cluster.resource_group_name
  location = var.azure_region
  tags     = local.resource_tags
}

resource "azurerm_virtual_network" "cluster" {
  name                = var.cluster_name
  address_space       = [var.network.vnet_cidr]
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  tags                = local.resource_tags
}

resource "azurerm_subnet" "main" {
  name                              = "${var.cluster_name}-main-subnet"
  resource_group_name               = azurerm_resource_group.cluster.name
  virtual_network_name              = azurerm_virtual_network.cluster.name
  address_prefixes                  = [var.network.main_subnet_cidr]
  service_endpoints                 = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "worker" {
  name                              = "${var.cluster_name}-worker-subnet"
  resource_group_name               = azurerm_resource_group.cluster.name
  virtual_network_name              = azurerm_virtual_network.cluster.name
  address_prefixes                  = [var.network.worker_subnet_cidr]
  service_endpoints                 = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_network_security_group" "cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  tags                = local.resource_tags
}

resource "azurerm_network_security_rule" "inbound" {
  count = length(var.network.inbound_traffic_security_rules)

  name                        = var.network.inbound_traffic_security_rules[count.index].name
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = var.network.inbound_traffic_security_rules[count.index].protocol
  source_port_range           = var.network.inbound_traffic_security_rules[count.index].source_port_range
  destination_port_range      = var.network.inbound_traffic_security_rules[count.index].target_port_range
  source_address_prefix       = var.network.inbound_traffic_security_rules[count.index].source_cidrs
  destination_address_prefix  = var.network.inbound_traffic_security_rules[count.index].target_cidrs
  resource_group_name         = azurerm_resource_group.cluster.name
  network_security_group_name = azurerm_network_security_group.cluster.name
}

resource "azuread_application" "cluster" {
  count        = var.managed_identity_enabled ? 0 : 1
  display_name = var.cluster_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "cluster" {
  count       = var.managed_identity_enabled ? 0 : 1
  client_id   = azuread_application.cluster[0].client_id
  owners      = [data.azuread_client_config.current.object_id]
  description = "Service principal for ARO classic cluster ${var.cluster_name}"
}

resource "azurerm_key_vault_access_policy" "cluster" {
  count        = var.managed_identity_enabled || var.key_vault.authorization_mode != "access_policy" ? 0 : 1
  key_vault_id = data.azurerm_key_vault.target.id
  tenant_id    = data.azuread_client_config.current.tenant_id
  object_id    = azuread_service_principal.cluster[0].object_id

  secret_permissions = ["Get", "List", "Set"]
}

resource "azurerm_role_assignment" "cluster_key_vault_secrets_officer" {
  count                = var.managed_identity_enabled || var.key_vault.authorization_mode != "rbac" ? 0 : 1
  scope                = data.azurerm_key_vault.target.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_service_principal.cluster[0].object_id
}

resource "azurerm_role_assignment" "cluster_network_contributor" {
  count                = var.managed_identity_enabled ? 0 : 1
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.cluster[0].object_id
}

resource "azurerm_role_assignment" "cluster_contributor" {
  count                = var.managed_identity_enabled ? 0 : 1
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.cluster[0].object_id
}

resource "azurerm_role_assignment" "cluster_user_access_admin" {
  count                = var.managed_identity_enabled ? 0 : 1
  scope                = azurerm_resource_group.cluster.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.cluster[0].object_id
}

resource "azurerm_user_assigned_identity" "managed" {
  for_each            = var.managed_identity_enabled ? local.managed_identity_names : {}
  name                = each.value
  location            = azurerm_resource_group.cluster.location
  resource_group_name = azurerm_resource_group.cluster.name
  tags                = local.resource_tags
}

resource "azurerm_role_assignment" "managed_identity_scopes" {
  for_each             = var.managed_identity_enabled ? { for item in local.managed_identity_scope_assignments : item.key => item } : {}
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.managed[each.value.identity_key].principal_id
}

resource "azurerm_role_assignment" "managed_identity_federated_credential" {
  for_each             = var.managed_identity_enabled ? { for key, identity in azurerm_user_assigned_identity.managed : key => identity if key != "aro_cluster" } : {}
  scope                = each.value.id
  role_definition_name = "Azure Red Hat OpenShift Federated Credential"
  principal_id         = azurerm_user_assigned_identity.managed["aro_cluster"].principal_id
}

resource "azurerm_role_assignment" "redhat_network_contributor" {
  scope                = azurerm_virtual_network.cluster.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

resource "azurerm_dns_zone" "cluster" {
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = local.custom_dns_domain_name
  resource_group_name = var.network.base_dns_zone_resource_group
  tags                = local.resource_tags
}

resource "azurerm_dns_ns_record" "delegation" {
  count               = var.use_azure_provided_domain ? 0 : 1
  name                = var.cluster.dns_prefix
  zone_name           = var.network.base_dns_zone_name
  resource_group_name = var.network.base_dns_zone_resource_group
  ttl                 = var.network.dns_ttl
  records             = azurerm_dns_zone.cluster[0].name_servers
  tags                = local.resource_tags
}
