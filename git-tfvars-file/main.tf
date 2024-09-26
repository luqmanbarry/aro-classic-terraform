
## Load the tfvars file
data "local_file" "tfvars_file_content" {
  filename  = local.tfvars_file
}

data "github_repository" "current" {
  full_name = format("%s/%s", var.git_owner, var.git_repository_name)
}

## GitHub: Commit tfvar file to remote repository
resource "github_repository_file" "commit_tfvars_file" {
  repository                = data.github_repository.current.full_name
  branch                    = var.git_branch
  file                      = local.tfvars_file
  content                   = data.local_file.tfvars_file_content.content
  commit_message            = local.message
  commit_author             = var.git_commit_email
  commit_email              = var.git_commit_email
  overwrite_on_create       = true
}