# # Create DNS zones
# resource "azurerm_private_dns_zone" "blob" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = "ingest00-main-sbox"
# }

# resource "azurerm_private_dns_zone" "file" {
#   name                = "privatelink.file.core.windows.net"
#   resource_group_name = "ingest00-main-sbox"
# }

# # Link DNS zones to vnet
# resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
#   for_each = var.landing_zones

#   name                  = "blob-link-${each.key}"
#   resource_group_name   = "ingest00-main-sbox"
#   private_dns_zone_name = azurerm_private_dns_zone.blob.name
#   virtual_network_id    = data.azurerm_virtual_network.lz[each.key].id
# }


# #Link DNS zones to vnet
# resource "azurerm_private_dns_zone_virtual_network_link" "file_link" {
#   for_each = var.landing_zones

#   name                  = "link-file-${each.key}"
#   resource_group_name   = "ingest00-main-sbox"
#   private_dns_zone_name = azurerm_private_dns_zone.file.name
#   virtual_network_id    = data.azurerm_virtual_network.lz[each.key].id
# }

# #Private endpoint for blob storage (per app)
# resource "azurerm_private_endpoint" "storage_blob" {
#   for_each = var.landing_zones

#   name                = "pe-${each.key}-blob"
#   location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
#   resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
#   subnet_id           = data.azurerm_subnet.lz["ingest${each.key}-data-product-001-${var.env}"].id

#   private_service_connection {
#     name                           = "psc-${each.key}-blob"
#     private_connection_resource_id = data.azurerm_storage_account.xcutting[each.key].id
#     subresource_names              = ["blob"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
#   }

#   tags = module.ctags.common_tags
# }

# resource "azurerm_private_endpoint" "storage_file" {
#   for_each = var.landing_zones

#   name                = "pe-${each.key}-file"
#   location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
#   resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
#   subnet_id           = data.azurerm_subnet.lz["ingest${each.key}-data-product-001-${var.env}"].id

#   private_service_connection {
#     name                           = "psc-${each.key}-file"
#     private_connection_resource_id = data.azurerm_storage_account.xcutting[each.key].id
#     subresource_names              = ["file"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
#   }

#   tags = module.ctags.common_tags
# }
