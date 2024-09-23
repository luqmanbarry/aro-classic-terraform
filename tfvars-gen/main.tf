# Azure Virtual Network
data "azurerm_virtual_network" "current_vnet" {
  name                = var.cluster_name
  resource_group_name = var.cluster_name
}

## Azure VNet Main Subnet
data "azurerm_subnet" "main_subnet" {
  name                 = format("%s-main-subnet", var.cluster_name)
  virtual_network_name = data.azurerm_virtual_network.current_vnet.name
  resource_group_name  = var.cluster_name
}

## Azure VNet Worker Subnet
data "azurerm_subnet" "worker_subnet" {
  name                 = format("%s-worker-subnet", var.cluster_name)
  virtual_network_name = data.azurerm_virtual_network.current_vnet.name
  resource_group_name  = var.cluster_name
}

## Azure Network Security Group
data "azurerm_network_security_group" "network_security_group" {
  name                = var.cluster_name
  resource_group_name = var.cluster_name
}

data "azurerm_key_vault" "bu_keyvault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

# Get Principal who's started the job; as well as subscription and tenant information
data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}
data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

data "azuread_service_principal" "current_cluster" {
  client_id = trimspace(file("${local.cluster_sp_client_id_filename}"))
}

## Local Filesystem: Write combined tfvars to file
resource "local_file" "write_output" {
  content = local.final_tfvars_content
  filename = local.final_tfvars_path
}

# DELETE cluster_client_id_filename
resource "null_resource" "delete_cluster_sp_client_id" {
  depends_on = [ local_file.write_output ]

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "echo 'DO NOT DELETE' > $CLUSTER_SP_CLIENT_ID_FILE_NAME "
    environment = {
      CLUSTER_SP_CLIENT_ID_FILE_NAME = local.cluster_sp_client_id_filename
    }
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}
