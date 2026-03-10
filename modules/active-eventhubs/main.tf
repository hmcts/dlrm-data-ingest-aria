resource "azurerm_eventhub" "aria_active_topic" {
  for_each = {
    for combination in flatten([
      for lz_key in keys(var.landing_zones) : [
        for suffix in ["res", "pub"] : {
          key    = "${lz_key}-${suffix}"
          lz_key = lz_key
          name   = "evh-${var.evh_name}-${suffix}-${var.env}-${lz_key}-uks-dlrm-01"
          suffix = suffix
        }
      ]]
    ) : combination.key => combination
  }

  name                = each.value.name
  namespace_name      = var.landing_zones[each.value.lz_key].eventhub_namespace_name
  resource_group_name = var.landing_zones[each.value.lz_key].eventhub_namespace_resource_group_name
  partition_count     = 8
  message_retention   = 7
}

resource "azurerm_eventhub_authorization_rule" "aria_active_topic_sas" {
  for_each = azurerm_eventhub.aria_active_topic

  name                = "aria_manage_sas"
  namespace_name      = each.value.namespace_name
  eventhub_name       = each.value.name
  resource_group_name = each.value.resource_group_name

  listen = true
  send   = true
  manage = true
}

resource "azurerm_key_vault_secret" "eventhub_active_topic_secrets" {
  for_each = {
    for k, v in azurerm_eventhub_authorization_rule.aria_active_topic_sas :
    k => {
      name   = v.eventhub_name
      value  = v.primary_connection_string
      lz_key = split("-", k)[0]
    }
  }

  name         = "${each.value.name}-key"
  value        = each.value.value
  key_vault_id = var.landing_zones[each.value.lz_key].key_vault_id

  tags = var.tags
}
