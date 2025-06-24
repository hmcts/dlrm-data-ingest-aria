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