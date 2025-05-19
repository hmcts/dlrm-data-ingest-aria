variable "client_secret" {
  description = "The client secret to store in Key Vault"
  type        = string
  sensitive   = true
  default     = ""
}

variable "segments" {
  description = "llist of segment alias for eventhubs"
  type        = list(string)
  default     = ["bl", "sbl", "joh", "aplfta", "apluta", "aplfpa", "td", ]
}

variable "eventhub_topic_suffixes" {
  description = "list of suffixs to add per segment for an eventhub"
  type        = list(string)
  default     = ["pub", "ack", "dl"]
}

# variable "db_workspace_configs" {
#   type = map(object({
#     databricks_ws_name = string
#     databriks_rg_name = string
#     key_vault_name = string
#     key_vault_rg_name = string
#   }))

# }

variable "client_id_test" {
  description = "Pulling the client ID fromt the Azure Devops Pipeline variable group"

  type = string
  default = $(client_id_test)

}

variable "client_secret_test" {
  description = "Pulling the client ID fromt the Azure Devops Pipeline variable group"
  
  type = string
  default = $(client_secret_test)

}

variable "tenant_id_test" {
  description = "Pulling the client ID fromt the Azure Devops Pipeline variable group"
  
  type = string
  default = $(tenant_id_test)

}