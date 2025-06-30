# create a private endpoint in same region as vnet
# approve pe on storage acc if manual approval required
# vnet configure dns to resolve .blob.windows.core
# fnctionapp needs to be intergated

# Create DNS zones using existing DNS zone
data "azurerm_private_dns_zone" "webapps" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = "ingest00-network-sbox"
}

# Reference existing vnet and create link between DNS and vnet
data "azurerm_private_dns_zone_virtual_network_link" "webapps_sbox00" {
  name                  = "b42dd139fa457"
  resource_group_name   = "ingest00-network-sbox"
  private_dns_zone_name = "privatelink.azurewebsites.net"
}

locals {
  dns_links_to_create01 = {
    for k, v in var.landing_zones :
    k => v
    if !(k == "00" && var.env == "sbox")
  }

  dns_links_to_create00 = {
    for k, v in var.landing_zones :
    k => v
    if(k == "00" && var.env == "sbox")
  }
}

# Create vnet link for all but sbox00 as already exists
resource "azurerm_private_dns_zone_virtual_network_link" "webapps" {
  for_each = local.dns_links_to_create01

  name                  = "vnet-link-${each.key}-webapps"
  resource_group_name   = data.azurerm_private_dns_zone.webapps.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.webapps.name
  virtual_network_id    = data.azurerm_virtual_network.lz[each.key].id

  registration_enabled = false
}

#Reference non-delegated subnet
data "azurerm_subnet" "pe" {
  for_each = var.landing_zones

  name                 = "ingest${each.key}-services-${var.env}"
  virtual_network_name = "ingest${each.key}-vnet-${var.env}"
  resource_group_name  = "ingest${each.key}-network-${var.env}"
}

# Create Private endpoint for functionapp for all but sbox00 as vnet link already exists
resource "azurerm_private_endpoint" "functionapp" {
  for_each = local.dns_links_to_create01

  name                = "pe-${each.key}-functionapp"
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
  subnet_id           = data.azurerm_subnet.pe[each.key].id

  private_service_connection {
    name                           = "psc-${each.key}-blob"
    private_connection_resource_id = data.azurerm_storage_account.xcutting[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.webapps.id]
  }
}

# Create pe for sbox and 00 seperately
resource "azurerm_private_endpoint" "functionapp00" {
  for_each = local.dns_links_to_create00

  name                = "pe-${each.key}-functionapp"
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
  subnet_id           = data.azurerm_subnet.pe[each.key].id

  private_service_connection {
    name                           = "psc-${each.key}-blob"
    private_connection_resource_id = data.azurerm_storage_account.xcutting[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.webapps.id]
  }
}