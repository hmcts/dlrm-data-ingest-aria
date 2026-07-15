##create metastore per lz/env
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

##create access groups

resource "databricks_group" "aria_uc_admins_sbox00" {
  count        = var.env == "sbox" ? 1 : 0
  provider     = databricks.sbox-00
  display_name = "aria-admins-${var.env}00"
}

resource "databricks_group" "aria_uc_admins_stg00" {
  count        = var.env == "stg" ? 1 : 0
  provider     = databricks.stg-00
  display_name = "aria-admins-${var.env}00"
}

resource "databricks_group" "aria_uc_admins_stg01" {
  count        = var.env == "stg" ? 1 : 0
  provider     = databricks.stg-01
  display_name = "aria-admins-${var.env}01"
}

resource "databricks_group" "aria_uc_admins_prod00" {
  count        = var.env == "prod" ? 1 : 0
  provider     = databricks.prod-00
  display_name = "aria-admins-${var.env}00"
}

##create catalogues

resource "databricks_storage_credential" "curated_sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  name = "aria_databricks_catalogue_sbox00"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
  }

  comment = "Managed by TF"
}

resource "databricks_storage_credential" "curated_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  name = "aria_databricks_catalogue_stg00"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
  }

  comment = "Managed by TF"
}

resource "databricks_storage_credential" "curated_stg01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  name = "aria_databricks_catalogue_stg01"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["01"].id
  }

  comment = "Managed by TF"
}

resource "databricks_storage_credential" "prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  name = "aria_databricks_catalogue_${var.env}00"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
  }

  comment = "Managed by TF"
}

##grant all privelege access for users on the catalogues

resource "databricks_grants" "storage_cred_grants_sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  storage_credential = databricks_storage_credential.curated_sbox00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_sbox00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "storage_cred_grants_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  storage_credential = databricks_storage_credential.curated_stg00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "storage_cred_grants_stg01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  storage_credential = databricks_storage_credential.curated_stg01[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg01[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "storage_cred_grants_prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  storage_credential = databricks_storage_credential.prod00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_prod00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

##create external locations for delta tables to live

resource "databricks_external_location" "bronze_sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  name = "bronze_sbox_00"

  url = "abfss://bronze@ingest00curatedsbox.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_sbox00[0].name
}

resource "databricks_external_location" "bronze_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  name = "bronze_stg_00"

  url = "abfss://bronze@ingest00curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg00[0].name
}

resource "databricks_external_location" "bronze_stg01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  name = "bronze_stg_01"

  url = "abfss://bronze@ingest01curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg01[0].name
}

resource "databricks_external_location" "bronze_prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  name = "bronze_prod_00"

  url = "abfss://bronze@ingest00curatedprod.dfs.core.windows.net"

  credential_name = databricks_storage_credential.prod00[0].name
}

resource "databricks_external_location" "silver_sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  name = "silver_sbox_00"

  url = "abfss://silver@ingest00curatedsbox.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_sbox00[0].name
}


resource "databricks_external_location" "silver_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  name = "silver_stg_00"

  url = "abfss://silver@ingest00curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg00[0].name
}


resource "databricks_external_location" "silver_stg01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  name = "silver_stg_01"

  url = "abfss://silver@ingest01curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg01[0].name
}


resource "databricks_external_location" "silver_prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  name = "silver_prod_00"

  url = "abfss://silver@ingest00curatedprod.dfs.core.windows.net"

  credential_name = databricks_storage_credential.prod00[0].name
}

resource "databricks_external_location" "gold_sbox00" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  name = "gold_sbox_00"

  url = "abfss://gold@ingest00curatedsbox.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_sbox00[0].name
}


resource "databricks_external_location" "gold_stg00" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  name = "gold_stg_00"

  url = "abfss://gold@ingest00curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg00[0].name
}


resource "databricks_external_location" "gold_stg01" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  name = "gold_stg_01"

  url = "abfss://gold@ingest01curatedstg.dfs.core.windows.net"

  credential_name = databricks_storage_credential.curated_stg01[0].name
}


resource "databricks_external_location" "gold_prod00" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  name = "gold_prod_00"

  url = "abfss://gold@ingest00curatedprod.dfs.core.windows.net"

  credential_name = databricks_storage_credential.prod00[0].name
}

##bronze,silver,gold sbox00

resource "databricks_grants" "bronze_sbox00_grants" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  external_location = databricks_external_location.bronze_sbox00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_sbox00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver_sbox00_grants" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  external_location = databricks_external_location.silver_sbox00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_sbox00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "gold_sbox00_grants" {
  count    = var.env == "sbox" ? 1 : 0
  provider = databricks.sbox-00

  external_location = databricks_external_location.gold_sbox00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_sbox00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

##bronze,silver,gold stg00

resource "databricks_grants" "bronze_stg00_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  external_location = databricks_external_location.bronze_stg00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver_stg00_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  external_location = databricks_external_location.silver_stg00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "gold_stg00_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-00

  external_location = databricks_external_location.gold_stg00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

##bronze,silver,gold stg01

resource "databricks_grants" "bronze_stg01_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  external_location = databricks_external_location.bronze_stg01[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg01[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver_stg01_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  external_location = databricks_external_location.silver_stg01[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg01[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "gold_stg01_grants" {
  count    = var.env == "stg" ? 1 : 0
  provider = databricks.stg-01

  external_location = databricks_external_location.gold_stg01[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_stg01[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

##bronze, silver, gold prod

resource "databricks_grants" "bronze_prod00_grants" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  external_location = databricks_external_location.bronze_prod00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_prod00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver_prod00_grants" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  external_location = databricks_external_location.silver_prod00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_prod00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "gold_prod00_grants" {
  count    = var.env == "prod" ? 1 : 0
  provider = databricks.prod-00

  external_location = databricks_external_location.gold_prod00[0].id

  grant {
    principal  = databricks_group.aria_uc_admins_prod00[0].display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

##create group members for the admin groups and assign per env/lz.

data "databricks_user" "aria_uc_admins_sbox00" {
  provider = databricks.sbox-00

  for_each = var.env == "sbox" ? toset(var.aria_uc_admins) : toset([])

  user_name = each.value
}

resource "databricks_group_member" "sbox00" {
  provider = databricks.sbox-00

  for_each = var.env == "sbox" ? data.databricks_user.aria_uc_admins_sbox00 : {}

  group_id  = databricks_group.aria_uc_admins_sbox00[0].id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_stg00" {
  provider = databricks.stg-00

  for_each = var.env == "stg" ? toset(var.aria_uc_admins) : toset([])

  user_name = each.value
}

resource "databricks_group_member" "stg00" {
  provider = databricks.stg-00

  for_each = var.env == "stg" ? data.databricks_user.aria_uc_admins_stg00 : {}

  group_id  = databricks_group.aria_uc_admins_stg00[0].id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_stg01" {
  provider = databricks.stg-01

  for_each = var.env == "stg" ? toset(var.aria_uc_admins) : toset([])

  user_name = each.value
}

resource "databricks_group_member" "stg01" {
  provider = databricks.stg-01

  for_each = var.env == "stg" ? data.databricks_user.aria_uc_admins_stg01 : {}

  group_id  = databricks_group.aria_uc_admins_stg01[0].id
  member_id = each.value.id
}

data "databricks_user" "aria_uc_admins_prod00" {
  provider = databricks.prod-00

  for_each = var.env == "prod" ? toset(var.aria_uc_admins) : toset([])

  user_name = each.value
}

resource "databricks_group_member" "prod00" {
  provider = databricks.prod-00

  for_each = var.env == "prod" ? data.databricks_user.aria_uc_admins_prod00 : {}

  group_id  = databricks_group.aria_uc_admins_prod00[0].id
  member_id = each.value.id
}