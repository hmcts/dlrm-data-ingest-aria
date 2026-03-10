output "eventhub_ids" {
  description = "IDs of the active event hubs, keyed by '{lz_key}-{suffix}'."
  value = {
    for k, v in azurerm_eventhub.aria_active_topic :
    k => v.id
  }
}
