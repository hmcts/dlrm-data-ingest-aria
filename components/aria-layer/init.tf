terraform {
  required_version = "1.11.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.27.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "1.79.1"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias                       = "sbox-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.ws["sbox-00"].id
  client_id                   = var.client_id_test
  client_secret               = var.client_secret_test
  tenant_id                   = var.tenant_id_test
}

# provider "databricks" {
#   alias                       = "sbox-02"
#   azure_workspace_resource_id = data.azurerm_databricks_workspace.ws["sbox-02"].id
#   client_id                   = var.client_id
#   client_secret               = var.client_secret
#   tenant_id                   = var.tenant_id
# }