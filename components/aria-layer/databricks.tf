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


# resource "databricks_dbfs_file" "config_file" {
#   for_each = var.landing_zones


#   content = templatefile("${path.module}/config.json.tmpl", {
#     env    = var.env
#     lz_key = each.key
#   })
#   filename = "${path.module}/config.json"
# }


resource "local_file" "config_file" {
  for_each = var.landing_zones

  content = templatefile("${path.module}/config.json.tmpl", {
    env    = var.env
    lz_key = each.key
  })

  filename = "${path.module}/config-${each.key}-${var.env}.json"
}

resource "databricks_dbfs_file" "config_file_00" {
  provider = databricks.sbox-00

  content_base64 = base64encode(templatefile("${path.module}/config.json.tmpl", {
    env    = "sbox"
    lz_key = "00"
  }))

  path = "/configs/config.json"
}


# resource "databricks_dbfs_file" "config_file_sbox-00" {
#   provider = databricks.sbox-00

#   source = local_file.config_file["00"].filename
#   path   = "/configs/config.json"

#   depends_on = [
#     local_file.config_file["00"]
#   ]

# }

# resource "databricks_dbfs_file" "config_file_sbox-02" {
#   provider = databricks.sbox-02

#   source = local_file.config_file["02"].filename
#   path   = "/configs/config.json"

#   depends_on = [
#     local_file.config_file["02"]
#   ]

# }


