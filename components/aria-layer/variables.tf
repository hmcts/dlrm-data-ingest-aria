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

variable "sboxClientId" {
  type    = string
  default = ""
}

variable "sboxClientSecret" {
  type    = string
  default = ""
}

variable "sboxTenantId" {
  type    = string
  default = ""
}

variable "sboxTenantURL" {
  type    = string
  default = ""
}