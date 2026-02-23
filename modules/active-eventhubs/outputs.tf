output "eventhub_ids" {
  description = "IDs of the active case link event hubs, keyed by '{lz_key}-{suffix}'."
  value = {
    for k, v in azurerm_eventhub.aria_active_case_link_topic :
    k => v.id
  }
}

# output "sas_keys" {
#   description = "Primary SAS keys and connection strings for the active case link event hubs."
#   sensitive   = true
#   value = {
#     for k, v in azurerm_eventhub_authorization_rule.aria_active_case_link_topic_sas :
#     k => {
#       primary_key               = v.primary_key
#       primary_connection_string = v.primary_connection_string
#     }
#   }
# }
