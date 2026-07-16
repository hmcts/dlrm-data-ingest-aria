provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

data "databricks_metastore" "this" {
  count        = var.assign_account == "true" ? 1 : 0
  provider     = databricks.account
  metastore_id = var.metastore_id
}

##sbox00

# Access connector
resource "azurerm_databricks_access_connector" "ext_access_connector" {

  name                = "${var.env}00-ext-access-connector"
  resource_group_name = "ingest00-main-${var.env}"
  location            = data.azurerm_resource_group.lz["ingest00-main-${var.env}"].location

  identity {
    type = "SystemAssigned"
  }
}


# Storage credential
resource "databricks_storage_credential" "external" {

  provider = databricks.sbox-00
  name     = "aria_catalog_${var.env}00"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector.id
  }

  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"
}


# External location
resource "databricks_external_location" "landing_external" {

  provider = databricks.sbox-00
  name     = "external_storage_aria_uc_${var.env}00"
  url = format(
    "abfss://%s@%s.dfs.core.windows.net",
    "landing",
    data.azurerm_storage_account.landing["00"].name
  )

  credential_name = databricks_storage_credential.external.id

  comment        = "Managed by TF"
  isolation_mode = "ISOLATED"
}

# Catalog
resource "databricks_catalog" "aria_catalog" {

  provider = databricks.sbox-00

  name = "aria_${var.env}00"

  comment = "this catalog is managed by terraform"

  properties = {
    purpose = "Aria catalog for ${var.env}00"
  }

  storage_root = "abfss://landing@ingest00landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"

  isolation_mode = "ISOLATED"
}

# Storage credential permissions
resource "databricks_grants" "storage_cred_grants" {

  provider = databricks.sbox-00

  storage_credential = databricks_storage_credential.external.id

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE"
    ]
  }
}

# External location permissions
resource "databricks_grants" "external_location_admin_grants" {

  provider = databricks.sbox-00

  external_location = databricks_external_location.landing_external.id

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE"
    ]
  }
}

# Catalog permissions
resource "databricks_grants" "catalog_aria_grants" {

  provider = databricks.sbox-00

  catalog = databricks_catalog.aria_catalog.name

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "ALL_PRIVILEGES"
    ]
  }
}

##stg00









##stg01














#prod00