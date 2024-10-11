# resource "azurerm_policy_definition" "policy" {
#   name         = "accTestPolicy"
#   policy_type  = "Custom"
#   mode         = "Indexed"
#   display_name = "acceptance test policy definition"

#   metadata = <<METADATA
#     {
#     "category": "General"
#     }
#     METADATA


#   policy_rule = jsonencode(
#     {
#       "if" = {
#         "anyOf" = {
#           "allOf" = {
#             "value" = "[resourceGroup().name]"

#             "equals" = "[parameters('resourceGroupName')]"
#           }
#         }

#         "anyOf" = {
#           "allOf" = {
#             "field" = "name"

#             "equals" = "[parameters('resourceGroupName')]"
#           }

#           "allOf" = {
#             "field" = "type"

#             "equals" = "Microsoft.Resources/subscriptions/resourceGroups"
#           }
#         }
#       }

#       "then" = {
#         "details" = {
#           "operations" = {
#             "condition" = "[not(equals(parameters('tag0')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag0')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag0')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag1')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag1')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag1')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag2')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag2')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag2')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag3')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag3')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag3')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag4')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag4')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag4')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag5')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag5')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag5')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag6')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag6')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag6')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag7')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag7')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag7')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag8')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag8')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag8')['tag'][1]]"
#           }

#           "operations" = {
#             "condition" = "[not(equals(parameters('tag9')['tag'][0], ''))]"

#             "field" = "[concat('tags[', parameters('tag9')['tag'][0], ']')]"

#             "operation" = "addOrReplace"

#             "value" = "[parameters('tag9')['tag'][1]]"
#           }

#           "roleDefinitionIds" = ["/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f"]
#         }

#         "effect" = "modify"
#       }
#     })


#   parameters = jsonencode({
#     "tag0" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag0"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag1" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag1"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag2" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag2"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag3" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag3"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag4" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag4"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag5" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag5"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag6" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag6"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag7" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag7"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag8" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag8"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "tag9" = {
#       "type" = "Object"

#       "metadata" = {
#         "displayName" = "tag9"
#       }

#       "defaultValue" = {
#         "tag" = ["", ""]
#       }

#       "schema" = {
#         "type" = "object"

#         "properties" "tag" {
#           "type" = "array"

#           "items" = {
#             "type" = "string"
#           }

#           "maxItems" = 2

#           "minItems" = 2
#         }
#       }
#     }

#     "resourceGroupName" = {
#       "type" = "String"

#       "metadata" = {
#         "displayName" = "Resource Group Name"

#         "description" = "The name of the resource group whose resources you'd like to require the tag on"
#       }
#     }
#   })

# }

# data "azurerm_resource_group" "managed_resource_group" {
#   name = local.managed_resource_group_name
# }

# resource "azurerm_resource_policy_assignment" "example" {
#   name                 = "example-policy-assignment"
#   resource_id          = data.azurerm_resource_group.managed_resource_group.id
#   policy_definition_id = azurerm_policy_definition.example.id

#   parameters = jsonencode({
#     "tag0" = {
#       "value" = {
#         "tag" = ["<your tag key here>", "<your tag value here>"]
#       }
#     }

#     "resourceGroupName" = {
#       "value" = local.managed_resource_group_name
#     }
#   })
# }

# resource "azurerm_policy_assignment" "example" {
#   count                = "${length(var.tag_list)}"
#   name                 = "mandatory-tags-forRG-${var.tag_list[count.index]}"
#   scope                = "/subscriptions/${var.subscription}"
#   policy_definition_id = element(azurerm_policy_definition.addTagToRG.*.id,count.index)
#   description          = "Policy Assignment created for Mandatory Tags"
#   display_name         = "Mandatory Tags Assignment-${var.tag_list[count.index]}"
#   metadata = <<METADATA
#     {
#       "category": "General"
#     }
#   METADATA
#   parameters = jsonencode({
#     "tag0" "value" {
#       "tag" = ["<your tag key here>", "<your tag value here>"]
#     }

#     "resourceGroupName" = {
#       "value" = local.managed_resource_group_name
#     }
#   })

#   parameters = jsonencode({
#     "tagName": {
#       "value":  var.tag_list[count.index],
#     }
#   })
# }