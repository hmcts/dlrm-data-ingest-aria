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