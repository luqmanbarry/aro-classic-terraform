resource "kubernetes_manifest" "managed_cluster" {
  provider = kubernetes.acmhub_cluster
  manifest = {
    apiVersion = "cluster.open-cluster-management.io/v1"
    kind       = "ManagedCluster"
    metadata = {
      name = var.cluster_name
    }
    spec = {
      hubAcceptsClient = true
    }
  }
}

resource "kubernetes_manifest" "addon_config" {
  provider   = kubernetes.acmhub_cluster
  depends_on = [kubernetes_manifest.managed_cluster]
  manifest = {
    apiVersion = "agent.open-cluster-management.io/v1"
    kind       = "KlusterletAddonConfig"
    metadata = {
      name      = var.cluster_name
      namespace = var.cluster_name
    }
    spec = {
      clusterName      = var.cluster_name
      clusterNamespace = var.cluster_name
      applicationManager = {
        enabled = true
      }
      certPolicyController = {
        enabled = true
      }
      iamPolicyController = {
        enabled = true
      }
      policyController = {
        enabled = true
      }
      searchCollector = {
        enabled = true
      }
      clusterLabels = {
        cloud  = "Azure"
        vendor = "OpenShift"
      }
    }
  }
}

resource "null_resource" "apply_import" {
  depends_on = [kubernetes_manifest.addon_config]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
oc --kubeconfig="$HUB_KUBECONFIG" get secret "$CLUSTER-import" -n "$CLUSTER" -o jsonpath='{.data.crds\.yaml}' | base64 --decode | oc apply --kubeconfig="$MANAGED_KUBECONFIG" -f -
oc --kubeconfig="$HUB_KUBECONFIG" get secret "$CLUSTER-import" -n "$CLUSTER" -o jsonpath='{.data.import\.yaml}' | base64 --decode | oc apply --kubeconfig="$MANAGED_KUBECONFIG" -f -
EOT
    environment = {
      CLUSTER            = var.cluster_name
      MANAGED_KUBECONFIG = var.managed_cluster_kubeconfig_filename
      HUB_KUBECONFIG     = var.acmhub_kubeconfig_filename
    }
  }

  triggers = {
    cluster_name = var.cluster_name
  }
}
