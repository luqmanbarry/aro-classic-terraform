data "azurerm_client_config" "current" {}

locals {
  openshift_gitops_chart_dir = "${path.module}/../../gitops/bootstrap/openshift-gitops"
  root_app_chart_dir         = "${path.module}/../../gitops/bootstrap/root-app"
  root_app_values_file       = "${path.module}/.tmp-${var.cluster_name}-root-app-values.yaml"
  oidc_issuer_file           = "${path.module}/.tmp-${var.cluster_name}-oidc-issuer"
  workload_identity_name     = "${var.cluster_name}-gitops-eso"
  workload_identity_subject  = "system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account_name}"
}

resource "azurerm_user_assigned_identity" "external_secrets" {
  name                = local.workload_identity_name
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  tags                = var.default_tags
}

resource "azurerm_key_vault_access_policy" "external_secrets" {
  count        = var.key_vault_authorization_mode == "access_policy" ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.external_secrets.principal_id

  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

resource "azurerm_role_assignment" "external_secrets_key_vault_secrets_user" {
  count                = var.key_vault_authorization_mode == "rbac" ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.external_secrets.principal_id
}

resource "azurerm_role_assignment" "external_secrets_key_vault_certificate_user" {
  count                = var.key_vault_authorization_mode == "rbac" ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.external_secrets.principal_id
}

resource "local_file" "root_app_values" {
  content = yamlencode({
    rootApplication = {
      name                 = "${var.cluster_name}-root"
      namespace            = "openshift-gitops"
      destinationNamespace = "openshift-gitops"
      project              = "default"
      path                 = var.gitops_root_app_path
    }
    git = {
      repoURL        = var.gitops_git_repo_url
      targetRevision = var.gitops_target_revision
      username       = var.gitops_repo_username
      password       = var.gitops_repo_password
    }
    bootstrapValues = {
      clusterName     = var.cluster_name
      gitopsNamespace = "openshift-gitops"
      git = {
        repoURL        = var.gitops_git_repo_url
        targetRevision = var.gitops_target_revision
      }
      projects = [
        {
          name        = "platform"
          namespace   = "openshift-gitops"
          description = "Shared platform applications managed by the cluster factory."
        },
        {
          name        = "workloads"
          namespace   = "openshift-gitops"
          description = "Shared workload applications managed by the cluster factory."
        },
      ]
      applications = try(var.gitops_values.applications, [])
    }
  })
  filename = local.root_app_values_file
}

resource "null_resource" "discover_oidc_issuer" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "oc --kubeconfig=\"$KUBECONFIG\" get authentication cluster -o jsonpath='{.spec.serviceAccountIssuer}' | xargs > \"$OUTPUT_FILE\""
    environment = {
      KUBECONFIG  = var.managed_cluster_kubeconfig_filename
      OUTPUT_FILE = local.oidc_issuer_file
    }
  }

  triggers = {
    cluster_name = var.cluster_name
    kubeconfig   = var.managed_cluster_kubeconfig_filename
    issuer_file  = local.oidc_issuer_file
    wi_subject   = local.workload_identity_subject
  }
}

data "local_file" "oidc_issuer" {
  depends_on = [null_resource.discover_oidc_issuer]
  filename   = local.oidc_issuer_file
}

resource "azurerm_federated_identity_credential" "external_secrets" {
  name                = local.workload_identity_name
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.external_secrets.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = trimspace(data.local_file.oidc_issuer.content)
  subject             = local.workload_identity_subject
}

resource "null_resource" "bootstrap_workload_identity_secret" {
  depends_on = [
    azurerm_key_vault_access_policy.external_secrets,
    azurerm_role_assignment.external_secrets_key_vault_secrets_user,
    azurerm_role_assignment.external_secrets_key_vault_certificate_user,
    azurerm_federated_identity_credential.external_secrets,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
cat <<EOF | oc --kubeconfig="$KUBECONFIG" apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.workload_identity_secret_namespace}
---
apiVersion: v1
kind: Secret
metadata:
  name: ${var.workload_identity_secret_name}
  namespace: ${var.workload_identity_secret_namespace}
type: Opaque
stringData:
  client-id: ${azurerm_user_assigned_identity.external_secrets.client_id}
  tenant-id: ${data.azurerm_client_config.current.tenant_id}
EOF
EOT
    environment = {
      KUBECONFIG = var.managed_cluster_kubeconfig_filename
    }
  }

  triggers = {
    client_id        = azurerm_user_assigned_identity.external_secrets.client_id
    tenant_id        = data.azurerm_client_config.current.tenant_id
    kubeconfig       = var.managed_cluster_kubeconfig_filename
    secret_name      = var.workload_identity_secret_name
    secret_namespace = var.workload_identity_secret_namespace
  }
}

resource "null_resource" "deploy_operator" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
helm template openshift-gitops-operator "$CHART_DIR" --values "$CHART_DIR/values.yaml" | oc --kubeconfig="$KUBECONFIG" apply -f -
EOT
    environment = {
      CHART_DIR  = local.openshift_gitops_chart_dir
      KUBECONFIG = var.managed_cluster_kubeconfig_filename
    }
  }

  triggers = {
    cluster_name = var.cluster_name
  }
}

resource "null_resource" "deploy_root_app" {
  depends_on = [
    null_resource.bootstrap_workload_identity_secret,
    null_resource.deploy_operator,
    local_file.root_app_values,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
helm template aro-root-app "$CHART_DIR" \
  --values "$VALUES_FILE" | oc --kubeconfig="$KUBECONFIG" apply -f -
EOT
    environment = {
      CHART_DIR   = local.root_app_chart_dir
      KUBECONFIG  = var.managed_cluster_kubeconfig_filename
      VALUES_FILE = local.root_app_values_file
    }
  }

  triggers = {
    cluster_name    = var.cluster_name
    repo_url        = var.gitops_git_repo_url
    target_revision = var.gitops_target_revision
  }
}
