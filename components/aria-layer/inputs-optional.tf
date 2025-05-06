variable "landing_zones" {
  description = "Identifiers for the landing zones to apply the project specific configuration to."
  type = map(object({
    use_microsoft_ip_kit_structure = optional(bool, false)
  }))
  default = {}
}
