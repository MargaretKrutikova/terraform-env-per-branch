# variables
variable "azure_subscription_id" {}

variable "resource_group_name" {
  default = "storage-rg"
}

variable "location" {
  default = "Norway East" 
}

variable "storage_account_name" {
  default = "mkterraformstorageacc"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "setup" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name
}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "17520h")

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

resource "local_file" "post-config" {
  depends_on = [azurerm_storage_container.ct]

  filename = "${path.module}/backend-config.txt"
  content  = <<EOF
storage_account_name = "${azurerm_storage_account.sa.name}"
container_name = "terraform-state"
key = "terraform.tfstate"
sas_token = "${data.azurerm_storage_account_sas.state.sas}"
  EOF
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}

output "shared_access_signature" {
  value = nonsensitive(data.azurerm_storage_account_sas.state.sas)
}
