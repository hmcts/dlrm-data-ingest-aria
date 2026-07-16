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

# --- Reference existing Databricks workspace ---
data "azurerm_databricks_workspace" "this" {
  name                = "ingest${var.landing_zones}-product-databricks001-${var.env}"
  resource_group_name = "ingest${var.landing_zones}-main-${var.env}"
}

provider "databricks" {
  host = data.azurerm_databricks_workspace.this.workspace_url
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

resource "databricks_storage_credential" "external" {
  for_each = var.landing_zones

  name = "aria_catalog_${var.env}${each.key}"
  azure_managed_identity {
    access_connector_id = data.azurerm_databricks_access_connector.unity_catalog[each.key].id
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
  catalog  = databricks_catalog.aria_catalog.name

  grant {
    principal  = data.databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}
