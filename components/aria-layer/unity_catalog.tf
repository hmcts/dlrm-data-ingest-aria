##account level databricks api for metastore, group permissions, users
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

resource "databricks_grants" "metastore_grants" {
  provider  = databricks.account
  metastore = var.metastore_id

  grant {
    principal  = data.azurerm_client_config.current.client_id
    privileges = ["CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
  }
}

## create list of aria users
data "databricks_user" "aria_uc_admins" {
  provider = databricks.account
  for_each = toset(var.aria_uc_admins)

  user_name = each.value
}

##create workspace level groups for aria admins and aria users -> these groups will be used to assign permissions to the catalog, storage credentials and external locations
resource "databricks_group" "aria_admins" {
  provider     = databricks.account
  display_name = "aria_admin_${var.env}"
}

resource "databricks_group" "aria_users" {
  provider     = databricks.account
  display_name = "aria_users_${var.env}"
}

## add aria admins to the group -> will get UC permissions
resource "databricks_group_member" "aria_admins" {
  provider = databricks.account
  for_each = data.databricks_user.aria_uc_admins

  group_id  = databricks_group.aria_admins.id
  member_id = each.value.id
}

##workspace level resources##

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

provider "databricks" {
  alias = "workspace_00"
  host  = try(data.azurerm_databricks_workspace.db_ws["${var.env}-00"].workspace_url, "https://placeholder.azuredatabricks.net")
}

provider "databricks" {
  alias = "workspace_01"
  host  = try(data.azurerm_databricks_workspace.db_ws["${var.env}-01"].workspace_url, "https://placeholder.azuredatabricks.net")
}

##assign metastore to workspaces
resource "databricks_metastore_assignment" "workspace_00" {
  provider     = databricks.workspace_00
  workspace_id = data.azurerm_databricks_workspace.db_ws["${var.env}-00"].workspace_id
  metastore_id = var.metastore_id
}

resource "databricks_metastore_assignment" "workspace_01" {
  count        = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider     = databricks.workspace_01
  workspace_id = data.azurerm_databricks_workspace.db_ws["${var.env}-01"].workspace_id
  metastore_id = var.metastore_id
}

##create catalogs
resource "databricks_catalog" "aria_catalog_00" {
  provider = databricks.workspace_00

  name    = "aria_${var.env}00"
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "Aria catalog for ${var.env}00"
  }

  storage_root   = "abfss://landing@ingest00landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"
  isolation_mode = "ISOLATED"

  depends_on = [databricks_metastore_assignment.workspace_00,
  databricks_external_location.landing_external_00]
}

resource "databricks_catalog" "aria_catalog_01" {
  count    = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider = databricks.workspace_01

  name    = "aria_${var.env}01"
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "Aria catalog for ${var.env}01"
  }

  storage_root   = "abfss://landing@ingest01landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"
  isolation_mode = "ISOLATED"

  depends_on = [databricks_metastore_assignment.workspace_01,
  databricks_external_location.landing_external_01]
}

## storage credentials
resource "databricks_storage_credential" "external_00" {
  provider = databricks.workspace_00

  name = "aria_uc_${var.env}00"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"

  depends_on = [databricks_metastore_assignment.workspace_00]
}

resource "databricks_storage_credential" "external_01" {
  count    = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider = databricks.workspace_01

  name = "aria_uc_${var.env}01"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["01"].id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by TF"

  depends_on = [databricks_metastore_assignment.workspace_01]
}

## external locations
resource "databricks_external_location" "landing_external_00" {
  provider = databricks.workspace_00

  name = "external_storage_location_${var.env}00"

  url             = format("abfss://%s@%s.dfs.core.windows.net", "landing", data.azurerm_storage_account.landing["00"].name)
  credential_name = databricks_storage_credential.external_00.name
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

resource "databricks_external_location" "landing_external_01" {
  count    = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider = databricks.workspace_01

  name = "external_storage_location_${var.env}01"

  url             = format("abfss://%s@%s.dfs.core.windows.net", "landing", data.azurerm_storage_account.landing["01"].name)
  credential_name = databricks_storage_credential.external_01[0].name
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
}

## grants: storage credential
resource "databricks_grants" "storage_cred_grants_00" {
  provider           = databricks.workspace_00
  storage_credential = databricks_storage_credential.external_00.id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["READ_FILES"]
  }
}

resource "databricks_grants" "storage_cred_grants_01" {
  count              = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider           = databricks.workspace_01
  storage_credential = databricks_storage_credential.external_01[0].id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["READ_FILES"]
  }
}

## grants: external location
resource "databricks_grants" "external_location_admin_grants_00" {
  provider          = databricks.workspace_00
  external_location = databricks_external_location.landing_external_00.id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["BROWSE", "READ_FILES"]
  }
}

resource "databricks_grants" "external_location_admin_grants_01" {
  count             = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider          = databricks.workspace_01
  external_location = databricks_external_location.landing_external_01[0].id

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["BROWSE", "READ_FILES"]
  }
}

## grants: catalog
resource "databricks_grants" "catalog_aria_grants_00" {
  provider = databricks.workspace_00
  catalog  = databricks_catalog.aria_catalog_00.name

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
  }
}

resource "databricks_grants" "catalog_aria_grants_01" {
  count    = contains(keys(var.landing_zones), "01") ? 1 : 0
  provider = databricks.workspace_01
  catalog  = databricks_catalog.aria_catalog_01[0].name

  grant {
    principal  = databricks_group.aria_admins.display_name
    privileges = ["ALL_PRIVILEGES"]
  }

  grant {
    principal  = databricks_group.aria_users.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
  }
}








