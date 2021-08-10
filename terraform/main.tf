# variables
variable "region" {
  default = "Norway East" 
}

variable "app_name" {
  default = "terraform-env"
}

# locals

locals {
  rg_name = "${terraform.workspace}-${var.app_name}-rg"
  app_service_plan_name = "${terraform.workspace}-${var.app_name}-service-plan"
  app_name = "${terraform.workspace}-${var.app_name}-app"
}

# providers
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "local" {
  name = local.rg_name
  location = var.region
}

# app service

resource "azurerm_app_service_plan" "local" {
  name = local.app_service_plan_name
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  kind = "Linux"
  reserved = true
    
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "local" {
  name = local.app_name
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  app_service_plan_id = azurerm_app_service_plan.local.id
  
  site_config {
    dotnet_framework_version = "v5.0"
  }
}

output "webAppName" {
  value = azurerm_app_service.local.name
}
