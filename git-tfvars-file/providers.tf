terraform {
  required_providers {

    github = {
      source  = "integrations/github"
      version = "~> 6"
    }
  }
}

# Configure the GitHub Provider - OAuth / Personal Access Token
provider "github" {
  token               = var.git_token
  # base_url            = var.git_base_url # UNCOMMENT IF GIT ENTERPRISE
  owner               = var.git_owner # UNCOMMENT IF GIT ENTERPRISE
}