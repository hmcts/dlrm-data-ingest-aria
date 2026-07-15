data "databricks_metastore" "sbox00" {
  provider     = databricks.sbox-00
  metastore_id = var.metastore_id
}

resource "databricks_metastore_assignment" "sbox00" {
  provider     = databricks.sbox-00
  workspace_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].id
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