locals {
  openshift_gitops_chart_dir = "${path.module}/../../gitops/bootstrap/openshift-gitops"
  root_app_chart_dir         = "${path.module}/../../gitops/bootstrap/root-app"
  root_app_values_file       = "${path.module}/.tmp-${var.cluster_name}-root-app-values.yaml"
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
  depends_on = [null_resource.deploy_operator, local_file.root_app_values]

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
