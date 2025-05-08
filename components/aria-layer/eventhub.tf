data "azurerm_eventhub_namespace" "lz" {
  for_each = var.landing_zones

  name                = "ingest${each.key}-integration-eventHubNamespace001-${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

data "azurerm_eventhub_namespace_authorization_rule" "lz" {
  for_each = var.landing_zones

  name                = "RootManageSharedAccessKey"
  namespace_name      = "ingest${each.key}-integration-eventHubNamespace001-${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

# test 
output "eh_connection_string" {
  value = {
    for key, rule in data.azurerm_eventhub_namespace_authorization_rule.lz :
    key => rule.primary_connection_string
  }
}

