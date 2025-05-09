data "azurerm_eventhub_namespace" "lz" {
  for_each = var.landing_zones

  name                = "ingest${each.key}-integration-eventHubNamespace001-${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_eventhub" "aria_topic" {
  for_each = {
    for combination in flatten([
      for lz_key in keys(var.landing_zones) : [
        for segment in var.segments : [
          for suffix in var.eventhub_topic_suffixes : {
            key     = "${lz_key}-${segment}-${suffix}"
            lz_key  = lz_key
            name    = "evh-${segment}-${suffix}-${lz_key}-uks-dlrm-01"
            segment = segment
            suffix  = suffix
          }
        ]
      ]]
    ) : combination.key => combination
  }
  name                = each.value.name
  namespace_name      = data.azurerm_eventhub_namespace.lz[each.key].name
  resource_group_name = data.azurerm_eventhub_namespace.lz[each.value.lz_key].resource_group_name
  partition_count     = 2
  message_retention   = 1

  #   tags = module.ctags.common_tags
}


data "azurerm_eventhub_namespace_authorization_rule" "lz" {
  for_each = var.landing_zones

  name                = "RootManageSharedAccessKey"
  namespace_name      = "ingest${each.key}-integration-eventHubNamespace001-${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}



# data "azure_eventhub_namespace" "aria_eventhub_ns" {
#     for_each = var.landing_zones

#     name = "ingest${each.key}-integration-eventHubNamspace001-${var.env}"
#     resource_group_name = ""
# }