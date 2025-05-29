resource "azurerm_key_vault_access_policy" "example-principal" {
  for_each = azurerm_linux_function_app.example

  key_vault_id = data.azurerm_key_vault.logging_vault[split("-", each.key)[0]].id
  tenant_id    = var.TenantId
  object_id    = each.value.identity[0].principal_id

  key_permissions = [
    "Get", "List", "Encrypt", "Decrypt", "Backup", "Create", "Delete", "Import", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate"
  ] #Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy.

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ] #Backup, Delete, Get, List, Purge, Recover, Restore and Set

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ] #Backup, Delete, DeleteSAS, Get, GetSAS, List, ListSAS, Purge, Recover, RegenerateKey, Restore, Set, SetSAS and Update.
}
