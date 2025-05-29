resource "local_file" "config" {
  for_each = var.landing_zones
  content = jsonencode({
    env = var.env
    lz  = each.key
  })
  filename = "${path.module}/tmp/config_${var.env}_${each.key}.json"
}

resource "azurerm_storage_blob" "config_json" {
  for_each = var.landing_zones

  name = "configs/env_config.json"

  type = "Block"

  source                 = local_file.config[each.key].filename
  storage_account_name   = data.azurerm_storage_account.curated[each.key].name
  storage_container_name = azurerm_storage_container.curated_extra["${each.key}-bronze"].name


}