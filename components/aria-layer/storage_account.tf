
#Storage account is required for function_app provisioning

resource "azurerm_storage_account" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
  }

  name                     = each.key
  resource_group_name      = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                 = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
