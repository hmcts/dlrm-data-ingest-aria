terraform {
  required_version = "1.11.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
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

  client_id     = $(client_id_test)
  client_secret = $(client_secret_test)
}

# provider "databricks" {
#   alias                       = "sbox-02"
#   azure_workspace_resource_id = data.azurerm_databricks_workspace.ws["sbox-02"].id
#   use_azure_cli_auth          = true
# }