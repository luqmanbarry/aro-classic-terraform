# resource "null_resource" "run_always" {
#   provisioner "local-exec" {
#     interpreter = [ "/bin/bash", "-c" ]
#     command = "echo 'Always run!'"
#   }

#   triggers = {
#     timestamp = "${timestamp()}"
#   }
# }

resource "azurerm_policy_definition" "rg_tagging_policy_definition" {

  name         = format("%s-tagging-policy-definition", var.cluster_name)
  policy_type  = "Custom"
  mode         = "All"
  display_name = format("'%s' managed resources tagging policy", var.cluster_name)

  metadata = <<METADATA
    {
      "category": "General"
    }
  METADATA

  policy_rule = <<POLICY_DEFS
    {
      "if": {
        "anyOf": [
          {
            "allOf": [
              {
                "value": "[resourceGroup().name]",
                "equals": "[parameters('resourceGroupName')]"
              }
            ]
          },
          {
            "allOf": [
              {
                "field": "name",
                "equals": "[parameters('resourceGroupName')]"
              },
              {
                "field": "type",
                "equals": "Microsoft.Resources/subscriptions/resourceGroups"
              }
            ]
          }
        ]
      },
      "then": {
        "details": {
          "operations": [
            {
              "condition": "[not(equals(parameters('tag0')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag0')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag0')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag1')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag1')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag1')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag2')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag2')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag2')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag3')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag3')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag3')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag4')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag4')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag4')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag5')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag5')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag5')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag6')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag6')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag6')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag7')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag7')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag7')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag8')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag8')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag8')['tag'][1]]"
            },
            {
              "condition": "[not(equals(parameters('tag9')['tag'][0], ''))]",
              "field": "[concat('tags[', parameters('tag9')['tag'][0], ']')]",
              "operation": "addOrReplace",
              "value": "[parameters('tag9')['tag'][1]]"
            }
          ],
          "roleDefinitionIds": [
            "/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f"
          ]
        },
        "effect": "modify"
      }
    }
  POLICY_DEFS


  parameters = <<PARAMS_PARAMS_DEFS
    {
      "tag0": {
        "type": "Object",
        "metadata": {
          "displayName": "tag0"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag1": {
        "type": "Object",
        "metadata": {
          "displayName": "tag1"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag2": {
        "type": "Object",
        "metadata": {
          "displayName": "tag2"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag3": {
        "type": "Object",
        "metadata": {
          "displayName": "tag3"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag4": {
        "type": "Object",
        "metadata": {
          "displayName": "tag4"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag5": {
        "type": "Object",
        "metadata": {
          "displayName": "tag5"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag6": {
        "type": "Object",
        "metadata": {
          "displayName": "tag6"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag7": {
        "type": "Object",
        "metadata": {
          "displayName": "tag7"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag8": {
        "type": "Object",
        "metadata": {
          "displayName": "tag8"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "tag9": {
        "type": "Object",
        "metadata": {
          "displayName": "tag9"
        },
        "defaultValue": {
          "tag": [
            "",
            ""
          ]
        },
        "schema": {
          "type": "object",
          "properties": {
            "tag": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "maxItems": 2,
              "minItems": 2
            }
          }
        }
      },
      "resourceGroupName": {
        "type": "String",
        "metadata": {
          "displayName": "Resource Group Name",
          "description": "The name of the resource group whose resources you'd like to require the tag on"
        }
      }
    }
  PARAMS_PARAMS_DEFS

  lifecycle {
    # At the moment (10/2024) ARO does not support more than 10 Tags
    precondition {
      condition     = length(local.resource_tags) <= 10
      error_message = "ARO does not support more than 10 tags. Reduce the num of tags and try again."
    }
    # replace_triggered_by = [ null_resource.run_always ]
  }
}

# data "azurerm_resource_group" "managed_rg" {
#   name = local.managed_resource_group_name
# }

data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "rg_tagging_policy_assignment" {
  count                = length(local.resource_tags)
  name                 = format("%s-tagging-policy-assignment-%s", local.managed_resource_group_name, count.index)
  subscription_id      = format("/subscriptions/%s", data.azurerm_subscription.current.subscription_id)
  policy_definition_id = azurerm_policy_definition.rg_tagging_policy_definition.id
  location             = var.location
  identity {
    type = "SystemAssigned"
    # identity_ids = [ data.azuread_user.current.object_id ]
  }

  parameters = jsonencode({

    "tag${count.index}" = {
      "value" = {
        "tag" = [format("%q", keys(local.resource_tags)[count.index]), format("%q", values(local.resource_tags)[count.index])]
      }
    }

    "resourceGroupName" = {
      "value" = local.managed_resource_group_name
    }
  })

  lifecycle {
    # At the moment (10/2024) ARO does not support more than 10 Tags
    precondition {
      condition     = length(local.resource_tags) <= 10
      error_message = "ARO does not support more than 10 tags. Reduce the num of tags and try again."
    }
    # replace_triggered_by = [ null_resource.run_always ]
  }
}

# resource "azurerm_resource_group_policy_remediation" "rg_tagging_policy_remediation" {
#   count                 = length(local.resource_tags)
#   name                  = format("%s-rg-tagging-policy-remediation-%s", var.cluster_name, count.index)
#   resource_group_id     = data.azurerm_resource_group.managed_rg.id
#   policy_assignment_id  = azurerm_subscription_policy_assignment.rg_tagging_policy_assignment[count.index].id
#   location_filters      = [ var.location ]

#   lifecycle {
#     # At the moment (10/2024) ARO does not support more than 10 Tags
#     precondition {
#       condition     = length(local.resource_tags) <= 10
#       error_message = "ARO does not support more than 10 tags. Reduce the num of tags and try again."
#     }
#     replace_triggered_by = [ null_resource.run_always ]
#   }
# }

# resource "azurerm_subscription_policy_remediation" "rg_tagging_policy_remediation" {
#   count                 = length(local.resource_tags)
#   name                  = format("%s-sub-tagging-policy-remediation-%s", var.cluster_name, count.index)
#   subscription_id       = format("/subscriptions/%s", data.azurerm_subscription.current.subscription_id)
#   policy_assignment_id  = azurerm_subscription_policy_assignment.rg_tagging_policy_assignment[count.index].id

#   lifecycle {
#     # At the moment (10/2024) ARO does not support more than 10 Tags
#     precondition {
#       condition     = length(local.resource_tags) <= 10
#       error_message = "ARO does not support more than 10 tags. Reduce the num of tags and try again."
#     }
#     replace_triggered_by = [ null_resource.run_always ]
#   }
# }