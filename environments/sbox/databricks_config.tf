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

locals {
  db_workspace_configs = {
    for lz_key in keys(var.landing_zones) :
    "${var.env}-${lz_key}" => {
      databricks_ws_name = "ingest${lz_key}-product-databricks001-${var.env}"
      databricks_rg_name = "ingest${lz_key}-main-${var.env}"
      key_vault_name     = "ingest${lz_key}-meta002-${var.env}"
      key_vault_rg_name  = "ingest${lz_key}-main-${var.env}"
    }
  }
}

data "azurerm_databricks_workspace" "db_ws" {
  for_each = local.db_workspace_configs

  name                = each.value.databricks_ws_name
  resource_group_name = each.value.databricks_rg_name
}

output "workspace_host" {
  value = {
    for key, ws in data.azurerm_databricks_workspace.db_ws :
    key => {
      ws_rl               = ws.workspace_url
      name                = ws.name
      resource_group_name = ws.resource_group_name

    }
  }
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


resource "databricks_secret_scope" "kv-scope-sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00
  name     = "ingest00-meta002-sbox"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["00"].id
    dns_name    = data.azurerm_key_vault.logging_vault["00"].vault_uri
  }
}

# resource "databricks_secret_scope" "kv-scope-sbox01" {
#   count    = var.env == "sbox" ? 1 : 0
#   provider = databricks.sbox-01
#   name     = "ingest01-meta002-sbox"

#   keyvault_metadata {
#     resource_id = data.azurerm_key_vault.logging_vault["01"].id
#     dns_name    = data.azurerm_key_vault.logging_vault["01"].vault_uri
#   }
# }

resource "databricks_secret_scope" "kv-scope-sbox02" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-02
  name     = "ingest02-meta002-sbox"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["02"].id
    dns_name    = data.azurerm_key_vault.logging_vault["02"].vault_uri
  }
}

# Config file specifically for sbox

resource "databricks_dbfs_file" "config_file_sbox00" {
  count = var.env == "sbox" ? 1 : 0

  provider = databricks.sbox-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}

resource "databricks_dbfs_file" "config_file_sbox01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.sbox-01

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "01"
  }))

  path = "/configs/config.json"
}

resource "databricks_dbfs_file" "config_file_sbox02" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-02

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "02"
  }))

  path = "/configs/config.json"
}

