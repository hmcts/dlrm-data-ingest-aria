data "azurerm_resource_group" "lz" {
  for_each = { for rg in local.flattened_resource_groups : rg => rg }
  name     = each.value
}

data "azurerm_virtual_network" "lz" {
  for_each            = var.landing_zones
  name                = "ingest${each.key}-vnet-${var.env}"
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-network-${var.env}"].name
}

data "azurerm_subnet" "lz" {
  for_each             = { for subnet in local.flattened_subnets : subnet.name => subnet }
  virtual_network_name = data.azurerm_virtual_network.lz[each.value.lz_key].name
  resource_group_name  = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-network-${var.env}"].name
  name                 = each.value.name
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}
