# Creating Service Principal values (client_id, client_secret, tenant_id, tenant_url)
resource "azurerm_key_vault_secret" "client_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPLE-CLIENT-ID"
  value        = var.ClientId
  key_vault_id = data.azurerm_client_config.current.client_id #data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

resource "azurerm_key_vault_secret" "tenant_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPLE-TENANT-ID"
  value        = data.azurerm_client_config.current.tenant_id #var.TenantId
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

# resource "azurerm_key_vault_secret" "tenant_url" {
#   for_each = var.landing_zones

#   name         = "SERVICE-PRINCIPLE-TENANT-URL"
#   value        = var.TenantURL
#   key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

#   tags = module.ctags.common_tags
# }

# resource "azurerm_key_vault_secret" "client_secret" {
#   for_each = var.landing_zones

#   name         = "SERVICE-PRINCIPLE-CLIENT-SECRET"
#   value        = var.ClientSecret
#   key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

#   tags = module.ctags.common_tags
# }

resource "azurerm_key_vault_secret" "eh_root_key" {
  for_each = var.landing_zones

  name         = data.azurerm_eventhub_namespace_authorization_rule.lz[each.key].name
  value        = data.azurerm_eventhub_namespace_authorization_rule.lz[each.key].primary_connection_string
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

resource "azurerm_key_vault_secret" "eventhub_topic_secrets" {
  for_each = {
    for k, v in azurerm_eventhub_authorization_rule.aria_topic_sas :
    k => {
      name   = v.eventhub_name
      value  = v.primary_connection_string
      lz_key = split("-", k)[0]
    }
  }

  name         = "${each.value.name}-key"
  value        = each.value.value
  key_vault_id = data.azurerm_key_vault.logging_vault[each.value.lz_key].id

  tags = module.ctags.common_tags
}

resource "azurerm_key_vault_secret" "curated_sas_token" {
  for_each = var.landing_zones

  name         = "CURATED-${var.env}-SAS-TOKEN"
  value        = "BlobEndpoint=${data.azurerm_storage_account.curated[each.key].primary_blob_endpoint};SharedAccessSignature=${data.azurerm_storage_account_sas.curated[each.key].sas}"
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

# Add in ENV to keyvault

resource "azurerm_key_vault_secret" "env" {
  for_each = var.landing_zones

  name         = "ENV"
  value        = "env=${var.env}"
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

# Add in LZ key to keyvault
resource "azurerm_key_vault_secret" "lz" {
  for_each = var.landing_zones

  name         = "LZ-KEY"
  value        = "lz${each.key}"
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

}

#Retrieve Client Secret and push into KV

locals {
  control_kv_name = (
    var.env == "sbox" ? "cdf72bb305eb87473ddb3kv" :
    var.env == "stg" ? "cda8a21e56bdadf9103f8kv" :
    var.env == "prod" ? "ce96749381917658e468ckv" :
    (throw("Unsupported environment: ${var.env}"))
  )
}

# Read KV depending on environment
data "azurerm_key_vault" "control_kv" {
  provider            = azurerm.hmcts-control
  name                = local.control_kv_name
  resource_group_name = "azure-control-${var.env}-rg"
}

# Data sources for each env secret (adjust names and KV ids accordingly)
data "azurerm_key_vault_secret" "client_secret" {
  provider     = azurerm.hmcts-control
  name         = "sp-token"
  key_vault_id = data.azurerm_key_vault.control_kv.id
}

resource "azurerm_key_vault_secret" "client_secret_copy" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPLE-CLIENT-SECRET"
  value        = data.azurerm_key_vault_secret.client_secret.value
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}
