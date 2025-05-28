## Connect Keyvaults to Databricks as a KV backed Scope - specifically for sbox
resource "databricks_secret_scope" "kv-scope-sbox00" {

  provider = databricks.sbox-00
  name     = "ingest00-meta002-sbox"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["00"].id
    dns_name    = data.azurerm_key_vault.logging_vault["00"].vault_uri
  }
}

resource "databricks_secret_scope" "kv-scope-sbox01" {

  provider = databricks.sbox-01
  name     = "ingest01-meta002-sbox"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["01"].id
    dns_name    = data.azurerm_key_vault.logging_vault["01"].vault_uri
  }
}

resource "databricks_secret_scope" "kv-scope-sbox02" {

  provider = databricks.sbox-02
  name     = "ingest02-meta002-sbox"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.logging_vault["02"].id
    dns_name    = data.azurerm_key_vault.logging_vault["02"].vault_uri
  }
}

# Config file specifically for sbox

resource "databricks_dbfs_file" "config_file_00" {
  provider = databricks.sbox-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}

resource "databricks_dbfs_file" "config_file_01" {
  provider = databricks.sbox-01

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "01"
  }))

  path = "/configs/config.json"
}

resource "databricks_dbfs_file" "config_file_02" {
  provider = databricks.sbox-02

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "02"
  }))

  path = "/configs/config.json"
}
