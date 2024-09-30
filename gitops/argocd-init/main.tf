resource "null_resource" "deploy_openshift_gitops" {

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$CHART_DIR/values.yaml" | oc apply -f -
    EOT
    environment = {
      KUBECONFIG      = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME    = "openshift-gitops-operator"
      CHART_DIR       = local.gitops_install_helm_chart_dir
    }
  }
}

resource "time_sleep" "wait_for_operator" {
  depends_on = [ null_resource.deploy_openshift_gitops ]
  create_duration = "120s"
}

resource "null_resource" "deploy_openshift_gitops_argocd_configs" {

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      helm template --kubeconfig $KUBECONFIG $RELEASE_NAME $CHART_DIR \
        --values "$CHART_DIR/values.yaml" \
        --values "$CHART_DIR/values.$CLUSTER_NAME.yaml" \
        --set git.repository.username="$GIT_USERNAME" \
        --set git.repository.password="$GIT_TOKEN" | oc apply -f -
    EOT
    environment = {
      KUBECONFIG      = var.managed_cluster_kubeconfig_filename
      RELEASE_NAME    = "openshift-gitops-operator"
      CHART_DIR       = local.gitops_config_helm_chart_dir
      CLUSTER_NAME    = var.cluster_name
      GIT_USERNAME    = "git"
      GIT_TOKEN       = sensitive(var.git_token)
    }
  }

  triggers = {
    timestamp = "${timestamp()}"
  }
}


