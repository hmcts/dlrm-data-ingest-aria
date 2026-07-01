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

variable "node_type_id" {
  description = "VM SKU for pool nodes"
  type        = string
  default     = "Standard_D8ds_v5"
}

variable "max_capacity" {
  description = "Max total instances in the pool"
  type        = number
  default     = 27
}