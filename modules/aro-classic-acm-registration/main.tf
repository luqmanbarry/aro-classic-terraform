resource "kubernetes_manifest" "managed_cluster_namespace" {
  provider = kubernetes.acmhub_cluster
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.cluster_name
    }
  }
}

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
  depends_on = [kubernetes_manifest.managed_cluster_namespace, kubernetes_manifest.managed_cluster]
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

resource "kubernetes_manifest" "auto_import_secret" {
  provider   = kubernetes.acmhub_cluster
  depends_on = [kubernetes_manifest.managed_cluster_namespace, kubernetes_manifest.managed_cluster]
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "auto-import-secret"
      namespace = var.cluster_name
    }
    stringData = {
      autoImportRetry = "5"
      kubeconfig      = file(var.managed_cluster_kubeconfig_filename)
    }
    type = "Opaque"
  }
}
