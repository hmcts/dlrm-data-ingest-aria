
#Storage account is required for function_app provisioning

locals {
  container_name = ["bronze", "silver", "gold"]

  container_matrix = {
    for pair in setproduct(keys(var.landing_zones), local.container_name) :
    "${pair[0]}-${paor[1]}" => {
      lz_key         = pair[0]
      container_name = pair[1]
    } if pair[0] != "00"
  }
}

resource "azurerm_storage_account" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
    if !(var.env == "sbox" && app.lz_key == "00")
  }

  name                     = replace(each.value.full_name, "-", "")
  resource_group_name      = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                 = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = module.ctags.common_tags
}

data "azurerm_storage_account" "curated" {

  for_each = var.landing_zones

  name                = "ingest${each.key}curated${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_storage_container" "curated_extra" {
  for_each = local.container_matrix

  name                  = each.value.container_name
  storage_account_name  = data.azurerm_storage_account.curated[each.value.lz_key].name
  container_access_type = "private"
}
