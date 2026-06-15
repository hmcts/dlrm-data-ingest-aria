variable "segments" {
  description = "llist of segment alias for eventhubs"
  type        = list(string)
  default     = ["bl", "sbl", "joh", "aplfta", "apluta", "aplfpa", "td"]
}

variable "eventhub_topic_suffixes" {
  description = "list of suffixs to add per segment for an eventhub"
  type        = list(string)
  default     = ["pub", "ack", "dl"]
}

variable "eventhub_active_topic_suffixes" {
  description = "list of suffixs to add per segment for an eventhub"
  type        = list(string)
  default     = ["pub", "ack"]
}

variable "ia_vault_subscription" {
  description = "Subscription ID for the subscription the IA vault to access for System user secrets is stored in."
  type        = string
}

variable "ClientId" {
  type    = string
  default = ""
}

variable "ClientSecret" {
  type    = string
  default = ""
}

variable "TenantId" {
  type    = string
  default = ""
}

variable "TenantURL" {
  type    = string
  default = ""
}
