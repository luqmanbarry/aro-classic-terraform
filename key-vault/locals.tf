locals {
  
  derived_tags = {
      "organization"   = var.organization
      "environment"     = var.platform_environment
      "cost_center"     = var.cost_center
      "created_by"      = format("%s", data.azuread_user.current.user_principal_name)
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )
}