locals {

  helm_chart_dir      = "${path.module}/openshift-gitops"
  helm_release_name   = "openshift-gitops-operator"

  gitops_repo_name    = format("%s-gitops", var.cluster_name)
  git_repository_url  = format("%s/%s/%s.git", var.git_base_url, var.git_owner, var.git_repository_name)

}