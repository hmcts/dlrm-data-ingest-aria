# removed {
#   from = azurerm_linux_function_app.example

#   lifecycle {
#     destroy = false
#   }
# }

#Define TF resources to import to state
# locals {
#   function_apps_import = {
#     "01-af-td"     = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest01-main-sbox/providers/Microsoft.Web/sites/af-td-sbox01-uks-dlrm-01"
#     "02-af-td"     = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest02-main-sbox/providers/Microsoft.Web/sites/af-td-sbox02-uks-dlrm-01"
#     "02-af-joh"    = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest02-main-sbox/providers/Microsoft.Web/sites/af-joh-sbox02-uks-dlrm-01"
#     "02-af-apluta" = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest02-main-sbox/providers/Microsoft.Web/sites/af-apluta-sbox02-uks-dlrm-01"
#     "00-af-bails"  = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest00-main-sbox/providers/Microsoft.Web/sites/af-bails-sbox00-uks-dlrm-01"
#     "00-af-sbails" = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest00-main-sbox/providers/Microsoft.Web/sites/af-sbails-sbox00-uks-dlrm-01"
#     "02-af-sbails" = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest02-main-sbox/providers/Microsoft.Web/sites/af-sbails-sbox02-uks-dlrm-01"
#     "00-af-aplfpa" = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest00-main-sbox/providers/Microsoft.Web/sites/af-aplfpa-sbox00-uks-dlrm-01"
#     "00-af-aplfta" = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest00-main-sbox/providers/Microsoft.Web/sites/af-aplfta-sbox00-uks-dlrm-01"
#     "00-af-joh"    = "/subscriptions/df72bb30-d6fb-47bd-82ee-5eb87473ddb3/resourceGroups/ingest00-main-sbox/providers/Microsoft.Web/sites/af-joh-sbox00-uks-dlrm-01"
#   }
# }

# import {
#   for_each = local.function_apps_import
#   to       = azurerm_linux_function_app.example[each.key]
#   id       = each.value
# }
#



###########################
#STG STATE FIX
##########################


locals {
  # Eventhub Topics (aria_topic)
  aria_eventhubs_import = {
    # Add all keys and full IDs here
    "00-apluta-ack"   = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-apluta-ack-00-uks-dlrm-01"
    "00-aplfta-ack"   = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-aplfta-ack-00-uks-dlrm-01"
    "00-apluta-dl"    = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-apluta-dl-00-uks-dlrm-01"
    "00-joh-pub"      = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-joh-pub-00-uks-dlrm-01"
    "00-aplfta-dl"    = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-aplfta-dl-00-uks-dlrm-01"
    "00-td-dl"        = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-td-dl-00-uks-dlrm-01"
    "00-td-pub"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-td-pub-00-uks-dlrm-01"
    "00-aplfpa-pub"   = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-aplfpa-pub-00-uks-dlrm-01"
    "00-aplfpa-dl"    = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-aplfpa-dl-00-uks-dlrm-01"
    "00-bl-ack"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-bl-ack-00-uks-dlrm-01"
    "00-sbl-ack"      = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-sbl-ack-00-uks-dlrm-01"
    "00-aplfta-pub"   = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-aplfta-pub-00-uks-dlrm-01"
    "00-joh-ack"      = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-joh-ack-00-uks-dlrm-01"
    "00-joh-dl"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-joh-dl-00-uks-dlrm-01"
    "00-sbl-dl"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-sbl-dl-00-uks-dlrm-01"
    "00-td-ack"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-td-ack-00-uks-dlrm-01"
    "00-apluta-pub"   = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-apluta-pub-00-uks-dlrm-01"
    "00-bl-pub"       = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-bl-pub-00-uks-dlrm-01"
    "00-bl-dl"        = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-bl-dl-00-uks-dlrm-01"
    "00-sbl-pub"      = "/subscriptions/da8a21e5-d260-4162-9391-6bdadf9103f8/resourceGroups/ingest00-main-stg/providers/Microsoft.EventHub/namespaces/ingest00-integration-eventHubNamespace001-stg/eventhubs/evh-sbl-pub-00-uks-dlrm-01"
  }

  # Key Vault Secrets
  key_vault_secrets_import = {
    "client_id_00"         = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-CLIENT-ID/2fd623addd904004b7a6d218b0e6f051"
    "tenant_id_00"         = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-TENANT-ID/c6291a5eac7c4ba8a8521cbaf26fd116"
    "eh_root_key_00"       = "https://ingest00-meta002-stg.vault.azure.net/secrets/RootManageSharedAccessKey/d4d52eebe3014066bfa804bd366ff070"
    "curated_sas_token_00" = "https://ingest00-meta002-stg.vault.azure.net/secrets/CURATED-SAS-TOKEN"
    "env_00"               = "https://ingest00-meta002-stg.vault.azure.net/secrets/ENV/80b4ba2a7ff942a0abdae1d80c5d76c4"
    "lz_00"                = "https://ingest00-meta002-stg.vault.azure.net/secrets/LZ-KEY/75dad6b7794d4e5bac25b55a09741131"
    "client_secret_00"     = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-CLIENT-SECRET/9c0e29c216054199b2795a8da91809f6"
  }

  # Storage Containers
  storage_containers_import = {
    "00-silver"            = "https://ingest00curatedstg.blob.core.windows.net/silver"
    "00-gold"              = "https://ingest00curatedstg.blob.core.windows.net/gold"
    "00-bronze"            = "https://ingest00curatedstg.blob.core.windows.net/bronze"
    "00-db-ack-checkpoint" = "https://ingest00xcuttingstg.blob.core.windows.net/db-ack-checkpoint"
    "00-db-rsp-checkpoint" = "https://ingest00xcuttingstg.blob.core.windows.net/db-rsp-checkpoint"
  }

  # Role Assignments: rbac_write and rbac_owner
  # (Assuming you have these maps with keys like "00-curated", "00-xcutting", etc. and their corresponding role assignment IDs)
  rbac_write_assignments = {
    "00-curated"  = "role-assignment-id-1"
    "00-xcutting" = "role-assignment-id-2"
    "00-landing"  = "role-assignment-id-3"
    "00-external" = "role-assignment-id-4"
  }

  rbac_owner_assignments = {
    "00-xcutting" = "role-assignment-id-5"
    "00-curated"  = "role-assignment-id-6"
    "00-external" = "role-assignment-id-7"
    "00-landing"  = "role-assignment-id-8"
  }
}

# Import eventhub topics
import {
  for_each = local.aria_eventhubs_import
  to       = azurerm_eventhub.aria_topic[each.key]
  id       = each.value
}

# KeyVault

import {
  to = azurerm_key_vault_secret.client_id["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-CLIENT-ID/2fd623addd904004b7a6d218b0e6f051"
}

import {
  to = azurerm_key_vault_secret.tenant_id["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-TENANT-ID/c6291a5eac7c4ba8a8521cbaf26fd116"
}

import {
  to = azurerm_key_vault_secret.eh_root_key["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/RootManageSharedAccessKey/d4d52eebe3014066bfa804bd366ff070"
}

import {
  to = azurerm_key_vault_secret.curated_sas_token["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/CURATED-SAS-TOKEN"
}

import {
  to = azurerm_key_vault_secret.env["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/ENV/80b4ba2a7ff942a0abdae1d80c5d76c4"
}

import {
  to = azurerm_key_vault_secret.lz["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/LZ-KEY/75dad6b7794d4e5bac25b55a09741131"
}

import {
  to = azurerm_key_vault_secret.client_secret_copy["00"]
  id = "https://ingest00-meta002-stg.vault.azure.net/secrets/SERVICE-PRINCIPLE-CLIENT-SECRET/9c0e29c216054199b2795a8da91809f6"
}

#storage container

import {
  to = azurerm_storage_container.curated_extra["00-silver"]
  id = "https://ingest00curatedstg.blob.core.windows.net/silver"
}

import {
  to = azurerm_storage_container.curated_extra["00-gold"]
  id = "https://ingest00curatedstg.blob.core.windows.net/gold"
}

import {
  to = azurerm_storage_container.curated_extra["00-bronze"]
  id = "https://ingest00curatedstg.blob.core.windows.net/bronze"
}

import {
  to = azurerm_storage_container.curated_extra["00-db-ack-checkpoint"]
  id = "https://ingest00xcuttingstg.blob.core.windows.net/db-ack-checkpoint"
}

import {
  to = azurerm_storage_container.curated_extra["00-db-rsp-checkpoint"]
  id = "https://ingest00xcuttingstg.blob.core.windows.net/db-rsp-checkpoint"
}

# RBAC write

import {
  to = azurerm_role_assignment.rbac_write["00-curated"]
  id = "role-assignment-id-1"
}

import {
  to = azurerm_role_assignment.rbac_write["00-xcutting"]
  id = "role-assignment-id-2"
}

import {
  to = azurerm_role_assignment.rbac_write["00-landing"]
  id = "role-assignment-id-3"
}

import {
  to = azurerm_role_assignment.rbac_write["00-external"]
  id = "role-assignment-id-4"
}

# Rbac read

import {
  to = azurerm_role_assignment.rbac_owner["00-xcutting"]
  id = "role-assignment-id-5"
}

import {
  to = azurerm_role_assignment.rbac_owner["00-curated"]
  id = "role-assignment-id-6"
}

import {
  to = azurerm_role_assignment.rbac_owner["00-external"]
  id = "role-assignment-id-7"
}

import {
  to = azurerm_role_assignment.rbac_owner["00-landing"]
  id = "role-assignment-id-8"
}
