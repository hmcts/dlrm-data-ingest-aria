# resource "azurerm_key_vault_access_policy" "example-principal" {
#   for_each = azurerm_linux_function_app.example

#   key_vault_id = data.azurerm_key_vault.logging_vault[split("-", each.key)[0]].id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = each.value.identity[0].principal_id

#   key_permissions = [
#     "Get", "List", "Encrypt", "Decrypt", "Backup", "Create", "Delete", "Import", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate"
#   ] #Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy.

#   secret_permissions = [
#     "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
#   ] #Backup, Delete, Get, List, Purge, Recover, Restore and Set

#   storage_permissions = [
#     "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
#   ] #Backup, Delete, DeleteSAS, Get, GetSAS, List, ListSAS, Purge, Recover, RegenerateKey, Restore, Set, SetSAS and Update.

#   depends_on = [azurerm_linux_function_app.example]
# }


# Below assigns RBAC permissions to use the Service Principle (object_id) access to Contribute/Own permissions to the storage accounts highlighted in locals below.
locals {
  storage_accounts = ["landing", "curated", "external", "xcutting"]
}

resource "azurerm_role_assignment" "rbac_write" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for sa in local.storage_accounts : {
          key             = "${lz_key}-${sa}"
          lz_key          = lz_key
          storage_account = sa
        }
      ]
    ]) : combo.key => combo
  }

  # Assign scope per LZ, use current_config as run in CICD, giving SP the permissions required for Databricks
  scope = {
    "landing"  = data.azurerm_storage_account.landing[each.value.lz_key].id
    "curated"  = data.azurerm_storage_account.curated[each.value.lz_key].id
    "external" = data.azurerm_storage_account.external[each.value.lz_key].id
    "xcutting" = data.azurerm_storage_account.xcutting[each.value.lz_key].id
    "zcutting" = azurerm_storage_account.zcutting[each.value.lz_key].id
  }[each.value.storage_account]

  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "rbac_owner" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for sa in local.storage_accounts : {
          key             = "${lz_key}-${sa}"
          lz_key          = lz_key
          storage_account = sa
        }
      ]
    ]) : combo.key => combo
  }

  scope = {
    "landing"  = data.azurerm_storage_account.landing[each.value.lz_key].id
    "curated"  = data.azurerm_storage_account.curated[each.value.lz_key].id
    "external" = data.azurerm_storage_account.external[each.value.lz_key].id
    "xcutting" = data.azurerm_storage_account.xcutting[each.value.lz_key].id
    "zcutting" = azurerm_storage_account.zcutting[each.value.lz_key].id
  }[each.value.storage_account]

  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "rbac_queue" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for sa in local.storage_accounts : {
          key             = "${lz_key}-${sa}"
          lz_key          = lz_key
          storage_account = sa
        }
      ]
    ]) : combo.key => combo
  }

  scope = {
    "landing"  = data.azurerm_storage_account.landing[each.value.lz_key].id
    "curated"  = data.azurerm_storage_account.curated[each.value.lz_key].id
    "external" = data.azurerm_storage_account.external[each.value.lz_key].id
    "xcutting" = data.azurerm_storage_account.xcutting[each.value.lz_key].id
    "zcutting" = azurerm_storage_account.zcutting[each.value.lz_key].id
  }[each.value.storage_account]

  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "rbac_table" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for sa in local.storage_accounts : {
          key             = "${lz_key}-${sa}"
          lz_key          = lz_key
          storage_account = sa
        }
      ]
    ]) : combo.key => combo
  }

  scope = {
    "landing"  = data.azurerm_storage_account.landing[each.value.lz_key].id
    "curated"  = data.azurerm_storage_account.curated[each.value.lz_key].id
    "external" = data.azurerm_storage_account.external[each.value.lz_key].id
    "xcutting" = data.azurerm_storage_account.xcutting[each.value.lz_key].id
    "zcutting" = azurerm_storage_account.zcutting[each.value.lz_key].id
  }[each.value.storage_account]

  role_definition_name = "Storage Table Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "rbac_account" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for sa in local.storage_accounts : {
          key             = "${lz_key}-${sa}"
          lz_key          = lz_key
          storage_account = sa
        }
      ]
    ]) : combo.key => combo
  }

  scope = {
    "landing"  = data.azurerm_storage_account.landing[each.value.lz_key].id
    "curated"  = data.azurerm_storage_account.curated[each.value.lz_key].id
    "external" = data.azurerm_storage_account.external[each.value.lz_key].id
    "xcutting" = data.azurerm_storage_account.xcutting[each.value.lz_key].id
    "zcutting" = azurerm_storage_account.zcutting[each.value.lz_key].id
  }[each.value.storage_account]

  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}