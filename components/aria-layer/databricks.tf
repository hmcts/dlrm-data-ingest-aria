locals {
  db_workspace_configs = {
    for lz_key in keys(var.landing_zones) :
    "${var.env}-${lz_key}" => {
      databricks_ws_name = "ingest${lz_key}-product-databricks001-${var.env}"
      databricks_rg_name = "ingest${lz_key}-main-${var.env}"
      key_vault_name     = "ingest${lz_key}-meta002-${var.env}"
      key_vault_rg_name  = "ingest${lz_key}-main-${var.env}"
    }
  }
}

data "azurerm_databricks_workspace" "db_ws" {
  for_each = local.db_workspace_configs

  name                = each.value.databricks_ws_name
  resource_group_name = each.value.databricks_rg_name
}

output "workspace_host" {
  value = {
    for key, ws in data.azurerm_databricks_workspace.db_ws :
    key => {
      ws_rl               = ws.workspace_url
      name                = ws.name
      resource_group_name = ws.resource_group_name

    }
  }
}