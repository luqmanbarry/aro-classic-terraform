
## Load the tfvars file
data "local_file" "tfvars_file_content" {
  filename  = local.tfvars_file
}

resource "null_resource" "commit_tfvars_file" {

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      git add "$TFVARS_FILE"
      git commit -am "$COMMIT_MESSAGE"
      git push origin $BRANCH
    EOT
    environment = {
      TFVARS_FILE     = data.local_file.tfvars_file_content.filename
      COMMIT_MESSAGE  = local.message
      BRANCH          = var.git_branch
    }
  }
}

data "github_repository" "current" {
  full_name = format("%s/%s", var.git_owner, var.git_repository_name)
}

# ## GitHub: Commit tfvar file to remote repository
# resource "github_repository_file" "commit_tfvars_file" {
#   repository                = var.git_repository_name
#   branch                    = var.git_branch
#   file                      = data.local_file.tfvars_file_content.filename
#   content                   = data.local_file.tfvars_file_content.content
#   commit_message            = local.message
#   commit_author             = var.git_owner
#   commit_email              = var.git_commit_email
#   overwrite_on_create       = true
# }