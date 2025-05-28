## Connect Keyvaults to Databricks as a KV backed Scope - specifically for prod

resource "databricks_secret_scope" "kv-scope-00" {

  provider = databricks.prod-00
  name     = "ingest00-meta002-prod"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["00"].id
    dns_name    = data.azurerm_key_vault.logging_vault["00"].vault_uri
  }
}

# Config file specifically for sbox

resource "databricks_dbfs_file" "config_file_00" {
  provider = databricks.prod-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "prod"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}
