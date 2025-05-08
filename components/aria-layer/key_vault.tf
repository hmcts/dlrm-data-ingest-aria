# Creating Service Principal values (client_id, client_secret, tenant_id, tenant_url)
resource "azurerm_key_vault_secret" "client_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-CLIENT-ID"
  value        = data.azurerm_client_config.current.client_id
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

resource "azurerm_key_vault_secret" "tenant_id" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-TENANT-ID"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

resource "azurerm_key_vault_secret" "tenant_url" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-TENANT-URL"
  value        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/token"
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}

resource "azurerm_key_vault_secret" "client_secret" {
  for_each = var.landing_zones

  name         = "SERVICE-PRINCIPAL-CLIENT-SECRET"
  value        = var.client_secret
  key_vault_id = data.azurerm_key_vault.logging_vault[each.key].id
}