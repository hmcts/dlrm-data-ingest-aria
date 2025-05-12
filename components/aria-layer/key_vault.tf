# Creating Service Principal values (client_id, client_secret, tenant_id, tenant_url)
resource "azurerm_key_vault_secret" "client_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-CLIENT-ID"
  value        = data.azurerm_client_config.current.client_id
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

resource "azurerm_key_vault_secret" "tenant_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-TENANT-ID"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

resource "azurerm_key_vault_secret" "tenant_url" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-TENANT-URL"
  value        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/token"
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

# Waiting for PlatOps to resolve
resource "azurerm_key_vault_secret" "client_secret" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-CLIENT-SECRET"
  value        = var.client_secret
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id

  tags = module.ctags.common_tags
}

data "azurerm_storage_account_sas" "curated" {
    for_each = toset(local.curated_containers)

    connection string = azurerm_storage_account.curated.primary_connection_string

    https_only        = true
    start             = "2024-01-01"
    expiry            = "2027-01-01"

  services {
    blob  = true
    queue = true
    table = true
    file  = true
  }

  resource_types {
    service   = false
    container = true
    object    = true
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
  }
}

resource "azurerm_key_vault_secret" "curated-sas-tokens" {
    for_each  = data.azurerm_storage_account_sas.curated

    name = "${each.key}-SAS-TOKEN"
    value = each.value.sas
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
