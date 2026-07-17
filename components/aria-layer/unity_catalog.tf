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

resource "databricks_group" "aria_admins" {
  provider     = databricks.account
  display_name = "aria_admin_${var.env}"
}

data "databricks_user" "aria_admins" {
  provider = databricks.account

  for_each = toset(var.aria_uc_admins)

  user_name = each.value
}

resource "databricks_group_member" "aria_admins" {
  provider = databricks.account

  for_each = data.databricks_user.aria_admins

  group_id  = databricks_group.aria_admins.id
  member_id = each.value.id
}

# Access connector
resource "azurerm_databricks_access_connector" "ext_access_connector" {

  for_each = var.landing_zones

  name                = "${var.env}${each.key}-ext-access-connector"
  resource_group_name = "ingest${each.key}-main-${var.env}"
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location

  identity {
    type = "SystemAssigned"
  }
}

##sbox00

##metastore assignment
resource "databricks_metastore_assignment" "workspace_00" {
  provider = databricks.account

  workspace_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_id
  metastore_id = var.metastore_id

  # Optional but recommended
  #   default_catalog_name = "main"
}


# Storage credential
resource "databricks_storage_credential" "external_sbox00" {

  provider = databricks.sbox-00
  name     = "aria_catalog_${var.env}00"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
  }

  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"
}


# External location
resource "databricks_external_location" "landing_external_sbox00" {

  provider = databricks.sbox-00
  name     = "external_storage_aria_uc_${var.env}00"
  url = format(
    "abfss://%s@%s.dfs.core.windows.net/aria_uc",
    "landing",
    data.azurerm_storage_account.landing["00"].name
  )

  credential_name = databricks_storage_credential.external_sbox00.id

  comment        = "Managed by TF"
  isolation_mode = "ISOLATED"

  depends_on = [
    databricks_metastore_assignment.workspace_00
  ]
}

# Catalog
resource "databricks_catalog" "aria_catalog_sbox00" {

  provider = databricks.sbox-00

  name = "aria_${var.env}00"

  comment = "this catalog is managed by terraform"

  properties = {
    purpose = "Aria catalog for ${var.env}00"
  }

  storage_root = "abfss://landing@ingest00landing${var.env}.dfs.core.windows.net/aria_uc"

  isolation_mode = "ISOLATED"

  depends_on = [
    databricks_external_location.landing_external_sbox00
  ]
}

#create active schema
resource "databricks_schema" "active_sbox00" {
  provider     = databricks.sbox-00
  catalog_name = databricks_catalog.aria_catalog_sbox00.id
  name         = "active"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

# #create archive schema
# resource "databricks_schema" "archive_sbox00" {
#   catalog_name = databricks_catalog.aria_catalog_sbox00.id
#   name         = "archive"
#   comment      = "this database is managed by terraform"
#   properties = {
#     kind = "various"
#   }
# }

# Storage credential permissions
resource "databricks_grants" "storage_cred_grants_sbox00" {

  provider = databricks.sbox-00

  storage_credential = databricks_storage_credential.external_sbox00.id

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE"
    ]
  }
}

# External location permissions
resource "databricks_grants" "external_location_admin_grants_sbox00" {

  provider = databricks.sbox-00

  external_location = databricks_external_location.landing_external_sbox00.id

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "ALL_PRIVILEGES",
      "MANAGE"
    ]
  }
}

# Catalog permissions
resource "databricks_grants" "sbox00_catalog" {
  provider = databricks.sbox-00
  catalog  = databricks_catalog.aria_catalog_sbox00.name
  grant {
    principal = data.azurerm_client_config.current.client_id

    privileges = [
      "USE_CATALOG",
      "CREATE_SCHEMA",
      "CREATE_TABLE",
      "CREATE_MATERIALIZED_VIEW",
      "SELECT",
      "MODIFY",
      "MANAGE",
      "BROWSE",
      "USE_SCHEMA"
    ]
  }
  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "USE_CATALOG",
      "CREATE_SCHEMA",
      "CREATE_TABLE",
      "CREATE_MATERIALIZED_VIEW",
      "SELECT",
      "MANAGE",
      "MODIFY",
      "BROWSE",
      "USE_SCHEMA"
    ]
  }
}

##assign permissions for user to create external location on the metastore
resource "databricks_grants" "metastore_sbox00" {
  provider  = databricks.sbox-00
  metastore = var.metastore_id

  grant {
    principal = data.azurerm_client_config.current.client_id

    privileges = [
      "CREATE_CATALOG",
      "CREATE_EXTERNAL_LOCATION"
    ]
  }
}

resource "databricks_grants" "active_schema" {
  provider = databricks.sbox-00

  schema = "${databricks_catalog.aria_catalog_sbox00.name}.active"

  grant {
    principal = databricks_group.aria_admins.display_name

    privileges = [
      "USE_SCHEMA",
      "MANAGE",
      "CREATE_TABLE",
      "CREATE_MATERIALIZED_VIEW",
      "MODIFY",
      "SELECT"
    ]
  }

  grant {
    principal = data.azurerm_client_config.current.client_id

    privileges = [
      "USE_SCHEMA",
      "MANAGE",
      "CREATE_TABLE",
      "CREATE_MATERIALIZED_VIEW",
      "MODIFY",
      "SELECT"
    ]
  }
}

##stg00









##stg01














#prod00

