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

data "databricks_group" "aria_admins" {
  provider     = databricks.account
  display_name = "aria_admin_${var.env}${var.landing_zones}"
}

data "databricks_group" "aria_users" {
  provider     = databricks.account
  display_name = "aria_users_${var.env}${var.landing_zones}"
}

## create catalog
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

## create list of aria users
data "databricks_user" "aria_uc_admins" {
  provider = databricks.account
  for_each = toset(var.aria_uc_admins)

  user_name = each.value
}

## add aria admins to the group -> will get UC permissions
resource "databricks_group_member" "aria_admins" {
  provider = databricks.account
  for_each = data.databricks_user.aria_uc_admins

  group_id  = data.databricks_group.aria_admins.id
  member_id = each.value.id
}

##create databricks access connector
resource "azurerm_databricks_access_connector" "ext_access_connector" {
  for_each = var.landing_zones

  name                = "${var.env}${each.key}-ext-access-connector"
  resource_group_name = "ingest${each.key}-main-${var.env}"
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location

  identity {
    type = "SystemAssigned"
  }
}

##set up storage credential for external storage account -> this will be used to create external location
resource "databricks_storage_credential" "external" {
  for_each = var.landing_zones

  name = "aria_uc_${var.env}${each.key}"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector[each.key].id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"
}

## create external location for landing storage account -> this will be used to create external tables (external delta tables)
resource "databricks_external_location" "landing_external" {
  for_each = var.landing_zones

  name = "external_storage_location_${var.env}${each.key}"

  url             = format("abfss://%s@%s.dfs.core.windows.net", "landing", data.azurerm_storage_account.landing_storage[each.key].name)
  credential_name = databricks_storage_credential.external[each.key].id
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

##grant access /permissions to storage credential and external location to the aria_admins and aria_users groups
resource "databricks_grants" "storage_cred_grants" {
  for_each           = var.landing_zones
  storage_credential = databricks_storage_credential.external[each.key].id

  grant {
    principal  = data.databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = data.databricks_group.aria_users.display_name
    privileges = ["READ_FILES"]
  }
}

resource "databricks_grants" "external_location_admin_grants" {
  for_each          = var.landing_zones
  external_location = databricks_external_location.landing_external[each.key].id

  grant {
    principal  = data.databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = data.databricks_group.aria_users.display_name
    privileges = ["BROWSE", "READ_FILES"]
  }
}

##assign catalog permissions to aria admins
resource "databricks_grants" "catalog_aria_grants" {
  for_each = var.landing_zones
  catalog  = databricks_catalog.aria_catalog[each.key].name

  grant {
    principal  = data.databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES"]
  }

  grant {
    principal  = data.databricks_group.aria_users.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
  }
}