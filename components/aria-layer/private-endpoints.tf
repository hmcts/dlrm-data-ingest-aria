# create a private endpoint in same region as vnet
# approve pe on storage acc if manual approval required
# vnet configure dns to resolve .blob.windows.core
# fnctionapp needs to be intergated

# Create DNS zones using existing DNS zone
data "azurerm_private_dns_zone" "webapps" {
for_each = var.landing_zones

name = "privatelink.azurewebsites.net"
resource_group_name = "ingest${each.key}-network-${var.env}"
}

# Reference existing vnet and create link between DNS and vnet
resource "azurerm_private_dns_zone_virtual_network_link" "webapps" {
  for_each = var.landing_zones

  name                  = "vnet-link-${each.key}-webapps"
  resource_group_name   = data.azurerm_private_dns_zone.webapps[each.key].resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.webapps[each.key].name
  virtual_network_id    = data.azurerm_virtual_network.lz[each.key].id

  registration_enabled = false
}

# Create Private endpoint for functionapp
resource "azurerm_private_endpoint" "functionapp" {
  for_each = var.landing_zones

  name                = "pe-${each.key}-functionapp"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
  subnet_id           = data.azurerm_subnet.lz["ingest${each.value.lz_key}-data-product-001-${var.env}"].id

  private_service_connection {
    name                           = "psc-${each.key}-blob"
    private_connection_resource_id = data.azurerm_storage_account.xcutting[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.webapps[each.key].id]
  }
}