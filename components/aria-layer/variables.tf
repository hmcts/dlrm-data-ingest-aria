variable "client_secret" {
  description = "The client secret to store in Key Vault"
  type        = string
  sensitive   = true
  default     = ""
}

variable "segments" {
  description = "llist of segment alias for eventhubs"
  type        = list(string)
  default     = ["bl", "joh", "ap", "td"]
}

variable "eventhub_topic_suffixes" {
  description = "list of suffixs to add per segment for an eventhub"
  type        = list(string)
  default     = ["pub", "ack", "dl"]
}

/* variable "storageaccount_primary_access_key" {
  description = "The primary access key for the storage account."
  type        = string
  sensitive   = true
  default     = "curated"
} */