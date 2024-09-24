resource "helm_release" "deploy_openshift_gitops" {
  chart       = local.gitops_install_helm_chart_dir
  name        = "openshift-gitops-operator"
  namespace   = "openshift-gitops"
  lint        = true
  max_history = 10
  verify      = false
}

resource "time_sleep" "wait_for_operator" {
  depends_on = [ helm_release.deploy_openshift_gitops ]
  create_duration = "120s"
}

resource "helm_release" "deploy_openshift_gitops_argocd_configs" {
  depends_on = [ time_sleep.wait_for_operator ]

  chart         = local.gitops_config_helm_chart_dir
  name          = "argocd-config"
  namespace     = "openshift-gitops"
  lint          = true
  max_history   = 10
  verify        = false

  set {
    name  = "git.repository.username"
    value = "git"
  }

  set {
    name  = "git.repository.password"
    value = sensitive(var.git_token)
  }
}


