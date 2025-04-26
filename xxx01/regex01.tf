variabel "rg_name" {
validering {

condition = can(regex("^rg-[a-z0-9]+-(dev|qa|prod|stag)-[a-z0-9]+-[0-9]{3}$", var.resource_group_name))

error_message = "SSK The resource group name must match the pattern: rg-<app>-<env=dev|qa|prod|stag>-<region>-<3 digit number> (e.g. rg-ecommerce-prod-centralindia-001)."

 default = "rg-ecommerce-prod-centralindia-001" #korrigerad
 }

 resource "azurerm_resource_group" "rg6" {
 namn = var.resursgruppnamn 
 plats = "Centrala Indien"
 }
}
