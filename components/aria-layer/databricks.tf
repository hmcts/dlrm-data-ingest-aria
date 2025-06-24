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

  skip_verify = var.env != "sbox"
}

provider "databricks" {
  alias                       = "sbox-01"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-01"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-01"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id

  skip_verify = var.env != "sbox"
}

provider "databricks" {
  alias                       = "sbox-02"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["sbox-02"].id
  host                        = data.azurerm_databricks_workspace.db_ws["sbox-02"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id

  skip_verify = var.env != "sbox"
}

provider "databricks" {
  alias                       = "stg-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["stg-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id

  skip_verify = var.env != "stg"
}


provider "databricks" {
  alias                       = "prod-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["prod-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["prod-00"].workspace_url

  azure_client_id     = data.azurerm_client_config.current.client_id
  azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id

  skip_verify = var.env != "prod"
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

resource "databricks_dbfs_file" "config_file_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "stg"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}

## access policies and vnets for azure functions 

resource "databricks_secret_scope" "kv-scope-stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00
  name     = "ingest00-meta002-stg"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["00"].id
    dns_name    = data.azurerm_key_vault.logging_vault["00"].vault_uri
  }
}

resource "databricks_secret_scope" "kv-scope-prod00" {

  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00
  name     = "ingest00-meta002-prod"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["00"].id
    dns_name    = data.azurerm_key_vault.logging_vault["00"].vault_uri
  }
}

resource "databricks_dbfs_file" "config_file_prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "prod"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}