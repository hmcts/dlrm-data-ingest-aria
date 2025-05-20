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

variable "client_id_test" {
  type = string
  default = ""
}
variable "client_secret_test" {
    type = string
    default = ""
}
variable "tenant_id_test" {
    type = string
    default = ""
}