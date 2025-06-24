terraform {
  required_version = ">=1.11.4, <2.0.0"

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
  alias = "hmcts-control"
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias                       = "sbox-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id
}

provider "databricks" {
  alias                       = "sbox-01"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-01"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-01"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id
}

provider "databricks" {
  alias                       = "sbox-02"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-02"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-02"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id
}
