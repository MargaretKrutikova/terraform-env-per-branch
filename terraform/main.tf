# variables
variable "azure_subscription_id" {}

variable "region" {
  default = "Norway East" 
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
  name = "terraform-env-per-branch-rg"
  location = var.region
}

# app service

resource "azurerm_app_service_plan" "local" {
  name = "terraform-env-per-branch-appserviceplan"
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name

  sku {
    tier = "Free"
    size = "S1"
  }
}

resource "azurerm_app_service" "local" {
  name = "terraform-env-per-branch-appservice"
  location = azurerm_resource_group.local.location
  resource_group_name = azurerm_resource_group.local.name
  app_service_plan_id = azurerm_app_service_plan.local.id

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "12-lts"
  }
}