resource "null_resource" "deploy_argocd_applications" {

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
      RELEASE_NAME    = local.arocd_apps_release_name
      CHART_DIR       = local.argocd_apps_dir
      CLUSTER_NAME    = var.cluster_name
    }
  }
}

