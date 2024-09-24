resource "helm_release" "deploy_openshift_gitops" {
  chart       = local.helm_chart_dir
  name        = local.helm_release_name
  namespace   = "openshift-gitops"
  lint        = true
  max_history = 10
  verify      = true

  set {
    name  = "clusterName"
    value = cluster_name
  }
}
