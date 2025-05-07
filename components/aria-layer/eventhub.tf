resource "azurerm_eventhub_namespace" "this" {
  name                 = length("${local.name}-integration-eventHubNamespace001-${var.env}") > 50 ? "${local.short_name}-integration-eventHubNamespace001-${var.env}" : "${local.name}-integration-eventHubNamespace001-${var.env}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.this[local.shared_integration_resource_group].name
  sku                  = "Premium"
  capacity             = 1
  auto_inflate_enabled = false
}

# create link to namespace, for each lz, pull eh namespace per entity