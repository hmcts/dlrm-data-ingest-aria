// Resources in this file are purely for example purposes, remove these and replace with your own resources.

resource "azurerm_storage_account" "this" {
  for_each                 = var.landing_zones
  name                     = "ingest${each.key}${var.env}example"
  resource_group_name      = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
  location                 = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  tags                     = module.ctags.common_tags
}
