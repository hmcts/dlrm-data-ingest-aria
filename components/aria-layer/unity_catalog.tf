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

provider "databricks" {
  host = data.azurerm_databricks_workspace.db_ws.workspace_url
}

resource "databricks_group" "aria_admins" {
  provider     = databricks.account
  display_name = "aria_admin_${var.env}"
}

resource "databricks_catalog" "aria_catalog" {
  for_each = var.landing_zones

  name    = "aria_${var.env}${each.key}"
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "Aria catalog for ${var.env}${each.key}"
  }

  storage_root   = "abfss://landing@ingest${each.key}landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"
  isolation_mode = "ISOLATED"
}

resource "azurerm_databricks_access_connector" "ext_access_connector" {
  for_each = var.landing_zones

  name                = "${var.env}${each.key}-ext-access-connector"
  resource_group_name = "ingest${each.key}-main-${var.env}"
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location

  identity {
    type = "SystemAssigned"
  }
}

resource "databricks_storage_credential" "external" {
  for_each = var.landing_zones

  name = "aria_catalog_${var.env}${each.key}"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector[each.key].id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"
}

resource "databricks_external_location" "landing_external" {
  for_each = var.landing_zones

  name = "external_storage_aria_uc_${var.env}${each.key}"
  url = format(
    "abfss://%s@%s.dfs.core.windows.net",
    "landing",
    data.azurerm_storage_account.landing[each.key].name
  )
  credential_name = databricks_storage_credential.external[each.key].id
  comment         = "Managed by TF "
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

## perms
resource "databricks_grants" "storage_cred_grants" {
  for_each           = var.landing_zones
  storage_credential = databricks_storage_credential.external[each.key].id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }
}

resource "databricks_grants" "external_location_admin_grants" {
  for_each          = var.landing_zones
  external_location = databricks_external_location.landing_external[each.key].id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }
}

resource "databricks_grants" "catalog_aria_grants" {
  for_each = var.landing_zones
  catalog  = databricks_catalog.aria_catalog[each.key].name

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}
