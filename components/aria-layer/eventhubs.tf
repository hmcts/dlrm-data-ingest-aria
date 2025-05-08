data "azurerm_eventhub_namespace" "lz" {
  for_each = var.landing_zones

  name                = "ingest${each.key}-integration-eventHubNamespace001-${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_eventhub" "aria_topic" {
  for_each            = var.landing_zones
  name                = "test-evh-joh-dl-${var.env}-uks-dlrm-01"
  name_space_name     = data.azurerm_eventhub_namespace.lz[each.key].name
  resource_group_name = data.azurerm_eventhub_namespace.lz[each.key].resource_group_name
  partition_count     = 2
  message_retention   = 1

  #   tags = module.ctags.common_tags
}


# data "azure_eventhub_namespace" "aria_eventhub_ns" {
#     for_each = var.landing_zones

#     name = "ingest${each.key}-integration-eventHubNamspace001-${var.env}"
#     resource_group_name = ""
# }