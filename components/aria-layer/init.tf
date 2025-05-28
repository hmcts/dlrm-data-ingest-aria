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
  features {}
}

provider "databricks" {
  alias                       = "sbox-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_url

  azure_client_id     = var.ClientId
  azure_client_secret = var.ClientSecret
  azure_tenant_id     = var.TenantId
}

provider "databricks" {
  alias                       = "sbox-01"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-01"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-01"].workspace_url

  azure_client_id     = var.ClientId
  azure_client_secret = var.ClientSecret
  azure_tenant_id     = var.TenantId
}

provider "databricks" {
  alias                       = "sbox-02"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-02"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-02"].workspace_url

  azure_client_id     = var.ClientId
  azure_client_secret = var.ClientSecret
  azure_tenant_id     = var.TenantId
}

provider "databricks" {
  alias                       = "stg-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["stg-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_url

  azure_client_id     = var.ClientId 
  azure_client_secret = var.ClientSecret # TODO: for stg, request client secret value from platops
  azure_tenant_id     = var.TenantId
}

provider "databricks" {
  alias                       = "prod-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["prod-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["prod-00"].workspace_url

  azure_client_id     = var.ClientId 
  azure_client_secret = var.ClientSecret # TODO: for prod, request client secret value from platops
  azure_tenant_id     = var.TenantId
}
