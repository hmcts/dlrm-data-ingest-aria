variable "env" {
  description = "Environment resources are deployed into."
  type        = string
}

variable "evh_name" {
  description = "Name to insert into the event hub for topic differentiation."
  type        = string
}

variable "landing_zones" {
  description = "Per-landing-zone configuration required to create the event hubs and their secrets."
  type = map(object({
    eventhub_namespace_name                = string
    eventhub_namespace_resource_group_name = string
    key_vault_id                           = string
  }))
}

variable "tags" {
  description = "Tags to apply to Key Vault secrets."
  type        = map(string)
  default     = {}
}
