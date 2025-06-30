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
data "azurerm_private_dns_zone_virtual_network_link" "webapps_sbox" {
  name                  = "ingest00-vnet-sbox" 
  resource_group_name   = "ingest00-network-sbox"
  private_dns_zone_name = "privatelink.azurewebsites.net"
}


#Reference non-delegated subnet
data "azurerm_subnet" "pe" {
  for_each = var.landing_zones

  name                 = "ingest${each.key}-services${var.env}"
  virtual_network_name = "ingest${each.key}-vnet-${var.env}"
  resource_group_name  = "ingest${each.key}-network-${var.env}"
}


resource "azurerm_private_dns_zone_virtual_network_link" "webapps" {
  for_each = var.landing_zones

  name                  = "vnet-link-${each.key}-webapps"
  resource_group_name   = data.azurerm_private_dns_zone.webapps.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.webapps.name
  virtual_network_id    = data.azurerm_virtual_network.lz[each.key].id

  registration_enabled = false
}

# Create Private endpoint for functionapp
resource "azurerm_private_endpoint" "functionapp" {
  for_each = var.landing_zones

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