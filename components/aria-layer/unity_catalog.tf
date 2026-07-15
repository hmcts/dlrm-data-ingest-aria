resource "databricks_metastore_assignment" "sbox00" {
  count        = var.env == "sbox" ? 1 : 0
  provider     = databricks.sbox-00
  workspace_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_metastore_assignment" "stg00" {
  count        = var.env == "stg" ? 1 : 0
  provider     = databricks.stg-00
  workspace_id = data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_metastore_assignment" "stg01" {
  count        = var.env == "stg" ? 1 : 0
  provider     = databricks.stg-01
  workspace_id = data.azurerm_databricks_workspace.db_ws["stg-01"].workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_metastore_assignment" "prod00" {
  count        = var.env == "prod" ? 1 : 0
  provider     = databricks.prod-00
  workspace_id = data.azurerm_databricks_workspace.db_ws["prod-00"].workspace_id
  metastore_id = var.metastore_id
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

resource "databricks_group" "aria_uc_admins_sbox00" {
  provider     = databricks.sbox-00
  display_name = "aria-admins-${var.env}00"
}

resource "databricks_group" "aria_uc_admins_stg00" {
  provider     = databricks.stg-00
  display_name = "aria-admins-${var.env}00"
}

resource "databricks_group" "aria_uc_admins_stg01" {
  provider     = databricks.stg-01
  display_name = "aria-admins-${var.env}01"
}

resource "databricks_group" "aria_uc_admins_prod00" {
  provider     = databricks.prod-00
  display_name = "aria-admins-${var.env}00"
}

resource "databricks_storage_credential" "curated" {
  for_each = var.landing_zones

  name = "aria_databricks_catalogue_${var.env}${each.key}"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector[each.key].id
  }
  comment = "Managed by TF"
}

resource "databricks_grants" "storage_cred_grants" {
  for_each = var.landing_zones

  storage_credential = databricks_storage_credential.curated[each.key].id

  grant {
    principal  = local.uc_admin_groups["${var.env}${each.key}"]
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_external_location" "bronze" {
  for_each        = var.landing_zones
  name            = "bronze_${var.env}_${each.key}"
  url             = "abfss://bronze@ingest${each.key}curated${var.env}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.curated[each.key].id
}

resource "databricks_external_location" "silver" {
  for_each        = var.landing_zones
  name            = "silver_${var.env}_${each.key}"
  url             = "abfss://silver@ingest${each.key}curated${var.env}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.curated[each.key].id
}

resource "databricks_external_location" "gold" {
  for_each        = var.landing_zones
  name            = "gold_${var.env}_${each.key}"
  url             = "abfss://gold@ingest${each.key}curated${var.env}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.curated[each.key].id
}

resource "databricks_grants" "storage_container_grants" {
  for_each = var.landing_zones

  storage_credential = databricks_storage_credential.curated[each.key].id

  grant {
    principal  = local.uc_admin_groups["${var.env}${each.key}"]
    privileges = ["ALL_PRIVILEGES"]
  }
}

data "databricks_user" "aria_uc_admins_sbox00" {
  provider = databricks.sbox-00

  for_each = toset(var.aria_uc_admins)

  user_name = each.value
}

data "databricks_user" "aria_uc_admins_sbox00" {
  provider = databricks.sbox-00

  for_each = var.env == "sbox" ? toset(var.aria_uc_admins) : {}

  user_name = each.value
}

resource "databricks_group_member" "sbox00" {
  provider = databricks.sbox-00

  for_each = var.env == "sbox" ? data.databricks_user.aria_uc_admins_sbox00 : {}

  group_id  = databricks_group.aria_uc_admins_sbox00.id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_stg00" {
  provider = databricks.stg-00

  for_each = var.env == "stg" ? toset(var.aria_uc_admins) : {}

  user_name = each.value
}

resource "databricks_group_member" "stg00" {
  provider = databricks.stg-00

  for_each = var.env == "stg" ? data.databricks_user.aria_uc_admins_stg00 : {}

  group_id  = databricks_group.aria_uc_admins_stg00.id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_stg01" {
  provider = databricks.stg-01

  for_each = var.env == "stg" ? toset(var.aria_uc_admins) : {}

  user_name = each.value
}

resource "databricks_group_member" "stg01" {
  provider = databricks.stg-01

  for_each = var.env == "stg" ? data.databricks_user.aria_uc_admins_stg01 : {}

  group_id  = databricks_group.aria_uc_admins_stg01.id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_prod00" {
  provider = databricks.prod-00

  for_each = var.env == "prod" ? toset(var.aria_uc_admins) : {}

  user_name = each.value
}

resource "databricks_group_member" "prod00" {
  provider = databricks.prod-00

  for_each = var.env == "prod" ? data.databricks_user.aria_uc_admins_prod00 : {}

  group_id  = databricks_group.aria_uc_admins_prod00.id
  member_id = each.value.id
}