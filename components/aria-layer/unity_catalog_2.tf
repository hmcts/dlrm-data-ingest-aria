# # ##account level databricks api for metastore, group permissions, users
# # provider "databricks" {
# #   alias      = "account"
# #   host       = "https://accounts.azuredatabricks.net"
# #   account_id = var.databricks_account_id
# # }

# # data "databricks_metastore" "this" {
# #   count        = var.assign_account == "true" ? 1 : 0
# #   provider     = databricks.account
# #   metastore_id = var.metastore_id
# # }

# # ## create list of aria users
# # data "databricks_user" "aria_uc_admins" {
# #   provider = databricks.account
# #   for_each = toset(var.aria_uc_admins)

# #   user_name = each.value
# # }

# # ##create workspace level groups for aria admins and aria users -> these groups will be used to assign permissions to the catalog, storage credentials and external locations
# # resource "databricks_group" "aria_admins" {
# #   provider     = databricks.account
# #   display_name = "aria_admin_${var.env}"
# # }

# # resource "databricks_group" "aria_users" {
# #   provider     = databricks.account
# #   display_name = "aria_users_${var.env}"
# # }

# # ## add aria admins to the group -> will get UC permissions
# # resource "databricks_group_member" "aria_admins" {
# #   provider = databricks.account
# #   for_each = data.databricks_user.aria_uc_admins

# #   group_id  = databricks_group.aria_admins.id
# #   member_id = each.value.id
# # }

# # ##workspace level resources##

# # ##create databricks access connector
# # resource "azurerm_databricks_access_connector" "ext_access_connector" {
# #   for_each = var.landing_zones

# #   name                = "${var.env}${each.key}-ext-access-connector"
# #   resource_group_name = "ingest${each.key}-main-${var.env}"
# #   location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location

# #   identity {
# #     type = "SystemAssigned"
# #   }
# # }

# # provider "databricks" {
# #   alias = "workspace_00"
# #   host  = try(data.azurerm_databricks_workspace.db_ws["${var.env}-00"].workspace_url, null)

# #   skip_verify = var.landing_zones != "00"
# # }

# # provider "databricks" {
# #   alias = "workspace_01"
# #   host  = try(data.azurerm_databricks_workspace.db_ws["${var.env}-01"].workspace_url, null)

# #   skip_verify = var.landing_zones != "01"
# # }

# # ##assign metastore to workspaces
# # resource "databricks_metastore_assignment" "workspace_00" {
# #   provider     = databricks.workspace_00
# #   workspace_id = data.azurerm_databricks_workspace.db_ws["${var.env}-00"].workspace_id
# #   metastore_id = var.metastore_id
# # }

# # resource "databricks_metastore_assignment" "workspace_01" {
# #   count        = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider     = databricks.workspace_01
# #   workspace_id = data.azurerm_databricks_workspace.db_ws["${var.env}-01"].workspace_id
# #   metastore_id = var.metastore_id
# # }

# # ##assign workspace metastore permissions to service principal
# # resource "databricks_grants" "metastore_grants_00" {
# #   provider  = databricks.workspace_00
# #   metastore = var.metastore_id

# #   grant {
# #     principal = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG",
# #       "CREATE_EXTERNAL_LOCATION",
# #     "CREATE_STORAGE_CREDENTIAL"]
# #   }
# # }

# # resource "databricks_grants" "metastore_grants_01" {
# #   provider  = databricks.workspace_01
# #   metastore = var.metastore_id

# #   grant {
# #     principal = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG",
# #       "CREATE_EXTERNAL_LOCATION",
# #     "CREATE_STORAGE_CREDENTIAL"]
# #   }
# # }

# # ##create catalogs
# # resource "databricks_catalog" "aria_catalog_00" {
# #   provider = databricks.workspace_00

# #   name    = "aria_${var.env}00"
# #   comment = "this catalog is managed by terraform"
# #   properties = {
# #     purpose = "Aria catalog for ${var.env}00"
# #   }

# #   storage_root   = "abfss://landing@ingest00landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"
# #   isolation_mode = "ISOLATED"

# #   depends_on = [databricks_metastore_assignment.workspace_00,
# #     databricks_external_location.landing_external_00,
# #   databricks_grants.metastore_grants_00]
# # }

# # resource "databricks_catalog" "aria_catalog_01" {
# #   count    = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider = databricks.workspace_01

# #   name    = "aria_${var.env}01"
# #   comment = "this catalog is managed by terraform"
# #   properties = {
# #     purpose = "Aria catalog for ${var.env}01"
# #   }

# #   storage_root   = "abfss://landing@ingest01landing${var.env}.dfs.core.windows.net/aria_uc_${var.env}"
# #   isolation_mode = "ISOLATED"

# #   depends_on = [databricks_metastore_assignment.workspace_01,
# #     databricks_external_location.landing_external_01,
# #   databricks_grants.metastore_grants_01]
# # }

# # ## storage credentials
# # resource "databricks_storage_credential" "external_00" {
# #   provider = databricks.workspace_00

# #   name = "aria_uc_${var.env}00"
# #   azure_managed_identity {
# #     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
# #   }
# #   isolation_mode = "ISOLATION_MODE_ISOLATED"
# #   comment        = "Managed by TF"

# #   depends_on = [databricks_metastore_assignment.workspace_00]
# # }

# # resource "databricks_storage_credential" "external_01" {
# #   count    = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider = databricks.workspace_01

# #   name = "aria_uc_${var.env}01"
# #   azure_managed_identity {
# #     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["01"].id
# #   }
# #   isolation_mode = "ISOLATION_MODE_ISOLATED"
# #   comment        = "Managed by TF"

# #   depends_on = [databricks_metastore_assignment.workspace_01]
# # }

# # ## external locations
# # resource "databricks_external_location" "landing_external_00" {
# #   provider = databricks.workspace_00

# #   name = "external_storage_location_${var.env}00"

# #   url             = format("abfss://%s@%s.dfs.core.windows.net", "landing", data.azurerm_storage_account.landing["00"].name)
# #   credential_name = databricks_storage_credential.external_00.name
# #   comment         = "Managed by TF"
# #   isolation_mode  = "ISOLATION_MODE_ISOLATED"
# # }

# # resource "databricks_external_location" "landing_external_01" {
# #   count    = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider = databricks.workspace_01

# #   name = "external_storage_location_${var.env}01"

# #   url             = format("abfss://%s@%s.dfs.core.windows.net", "landing", data.azurerm_storage_account.landing["01"].name)
# #   credential_name = databricks_storage_credential.external_01[0].name
# #   comment         = "Managed by TF"
# #   isolation_mode  = "ISOLATION_MODE_ISOLATED"
# # }

# # ## grants: storage credential
# # resource "databricks_grants" "storage_cred_grants_00" {
# #   provider           = databricks.workspace_00
# #   storage_credential = databricks_storage_credential.external_00.id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES", "MANAGE"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["READ_FILES"]
# #   }
# # }

# # resource "databricks_grants" "storage_cred_grants_01" {
# #   count              = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider           = databricks.workspace_01
# #   storage_credential = databricks_storage_credential.external_01[0].id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES", "MANAGE"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["READ_FILES"]
# #   }
# # }

# # ## grants: external location
# # resource "databricks_grants" "external_location_admin_grants_00" {
# #   provider          = databricks.workspace_00
# #   external_location = databricks_external_location.landing_external_00.id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES", "MANAGE"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["BROWSE", "READ_FILES"]
# #   }
# # }

# # resource "databricks_grants" "external_location_admin_grants_01" {
# #   count             = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider          = databricks.workspace_01
# #   external_location = databricks_external_location.landing_external_01[0].id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES", "MANAGE"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["BROWSE", "READ_FILES"]
# #   }
# # }

# # ## grants: catalog
# # resource "databricks_grants" "catalog_aria_grants_00" {
# #   provider = databricks.workspace_00
# #   catalog  = databricks_catalog.aria_catalog_00.name

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
# #   }
# # }

# # resource "databricks_grants" "catalog_aria_grants_01" {
# #   count    = contains(keys(var.landing_zones), "01") ? 1 : 0
# #   provider = databricks.workspace_01
# #   catalog  = databricks_catalog.aria_catalog_01[0].name

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["ALL_PRIVILEGES"]
# #   }

# #   grant {
# #     principal  = databricks_group.aria_users.display_name
# #     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
# #   }
# # }


# ##account level databricks api for metastore, group permissions, users
# provider "databricks" {
#   alias      = "account"
#   host       = "https://accounts.azuredatabricks.net"
#   account_id = var.databricks_account_id
# }

# data "databricks_metastore" "this" {
#   count        = var.assign_account == "true" ? 1 : 0
#   provider     = databricks.account
#   metastore_id = var.metastore_id
# }

# ## create list of aria users
# data "databricks_user" "aria_uc_admins" {
#   provider = databricks.account
#   for_each = toset(var.aria_uc_admins)

#   user_name = each.value
# }

# ##create account level groups for aria admins and aria users
# resource "databricks_group" "aria_admins" {
#   provider     = databricks.account
#   display_name = "aria_admin_${var.env}"
# }

# resource "databricks_group" "aria_users" {
#   provider     = databricks.account
#   display_name = "aria_users_${var.env}"
# }

# ## add aria admins to the group -> will get UC permissions
# resource "databricks_group_member" "aria_admins" {
#   provider = databricks.account
#   for_each = data.databricks_user.aria_uc_admins

#   group_id  = databricks_group.aria_admins.id
#   member_id = each.value.id
# }

# ##workspace level resources##

# ##create databricks access connector
# resource "azurerm_databricks_access_connector" "ext_access_connector" {
#   for_each = var.landing_zones

#   name                = "${var.env}${each.key}-ext-access-connector"
#   resource_group_name = "ingest${each.key}-main-${var.env}"
#   location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location

#   identity {
#     type = "SystemAssigned"
#   }
# }

# ##workspace-scoped providers, one static alias per env+LZ
# # provider "databricks" {
# #   alias                       = "sbox-00"
# #   azure_workspace_resource_id = try(data.azurerm_databricks_workspace.db_ws["sbox-00"].id, null)
# #   host                        = try(data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_url, null)

# #   azure_client_id     = data.azurerm_client_config.current.client_id
# #   azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
# #   azure_tenant_id     = data.azurerm_client_config.current.tenant_id

# #   skip_verify = var.env != "sbox"
# # }

# # provider "databricks" {
# #   alias                       = "stg-00"
# #   azure_workspace_resource_id = try(data.azurerm_databricks_workspace.db_ws["stg-00"].id, null)
# #   host                        = try(data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_url, null)

# #   azure_client_id     = data.azurerm_client_config.current.client_id
# #   azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
# #   azure_tenant_id     = data.azurerm_client_config.current.tenant_id

# #   skip_verify = var.env != "stg"
# # }

# # provider "databricks" {
# #   alias                       = "stg-01"
# #   azure_workspace_resource_id = try(data.azurerm_databricks_workspace.db_ws["stg-01"].id, null)
# #   host                        = try(data.azurerm_databricks_workspace.db_ws["stg-01"].workspace_url, null)

# #   azure_client_id     = data.azurerm_client_config.current.client_id
# #   azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
# #   azure_tenant_id     = data.azurerm_client_config.current.tenant_id

# #   skip_verify = var.env != "stg"
# # }

# # provider "databricks" {
# #   alias                       = "prod-00"
# #   azure_workspace_resource_id = try(data.azurerm_databricks_workspace.db_ws["prod-00"].id, null)
# #   host                        = try(data.azurerm_databricks_workspace.db_ws["prod-00"].workspace_url, null)

# #   azure_client_id     = data.azurerm_client_config.current.client_id
# #   azure_client_secret = data.azurerm_key_vault_secret.client_secret.value
# #   azure_tenant_id     = data.azurerm_client_config.current.tenant_id

# #   skip_verify = var.env != "prod"
# # }

# ##assign metastore to workspaces
# resource "databricks_metastore_assignment" "sbox00" {
#   count        = var.env == "sbox" ? 1 : 0
#   provider     = databricks.sbox-00
#   workspace_id = data.azurerm_databricks_workspace.db_ws["sbox-00"].workspace_id
#   metastore_id = var.metastore_id
# }

# resource "databricks_metastore_assignment" "stg00" {
#   count        = var.env == "stg" ? 1 : 0
#   provider     = databricks.stg-00
#   workspace_id = data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_id
#   metastore_id = var.metastore_id
# }

# resource "databricks_metastore_assignment" "stg01" {
#   count        = var.env == "stg" ? 1 : 0
#   provider     = databricks.stg-01
#   workspace_id = data.azurerm_databricks_workspace.db_ws["stg-01"].workspace_id
#   metastore_id = var.metastore_id
# }

# resource "databricks_metastore_assignment" "prod00" {
#   count        = var.env == "prod" ? 1 : 0
#   provider     = databricks.prod-00
#   workspace_id = data.azurerm_databricks_workspace.db_ws["prod-00"].workspace_id
#   metastore_id = var.metastore_id
# }

# ##assign workspace metastore permissions to service principal
# # resource "databricks_grants" "metastore_grants_sbox00" {
# #   count     = var.env == "sbox" ? 1 : 0
# #   provider  = databricks.account
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
# #   }

# #   depends_on = [time_sleep.wait_for_uc]
# # }

# # resource "databricks_grants" "metastore_grants_stg00" {
# #   count     = var.env == "stg" ? 1 : 0
# #   provider  = databricks.account
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
# #   }

# #   depends_on = [time_sleep.wait_for_uc]
# # }

# # resource "databricks_grants" "metastore_grants_stg01" {
# #   count     = var.env == "stg" ? 1 : 0
# #   provider  = databricks.account
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
# #   }

# #   depends_on = [time_sleep.wait_for_uc]
# # }

# # resource "databricks_grants" "metastore_grants_prod00" {
# #   count     = var.env == "prod" ? 1 : 0
# #   provider  = databricks.account
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = data.azurerm_client_config.current.client_id
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL"]
# #   }

# #   depends_on = [time_sleep.wait_for_uc]
# # }

# ##create catalogs
# resource "databricks_catalog" "aria_catalog_sbox00" {
#   count    = var.env == "sbox" ? 1 : 0
#   provider = databricks.sbox-00

#   name    = "aria_sbox00"
#   comment = "this catalog is managed by terraform"
#   properties = {
#     purpose = "Aria catalog for sbox00"
#   }

#   storage_root   = "abfss://landing@ingest00landingsbox.dfs.core.windows.net/aria_uc_sbox"
#   isolation_mode = "ISOLATED"

#   depends_on = [
#     databricks_metastore_assignment.sbox00,
#     databricks_external_location.landing_external_sbox00
#   ]
# }

# resource "databricks_catalog" "aria_catalog_stg00" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-00

#   name    = "aria_stg00"
#   comment = "this catalog is managed by terraform"
#   properties = {
#     purpose = "Aria catalog for stg00"
#   }

#   storage_root   = "abfss://landing@ingest00landingstg.dfs.core.windows.net/aria_uc_stg"
#   isolation_mode = "ISOLATED"

#   depends_on = [
#     databricks_metastore_assignment.stg00,
#     databricks_external_location.landing_external_stg00
#   ]
# }

# resource "databricks_catalog" "aria_catalog_stg01" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-01

#   name    = "aria_stg01"
#   comment = "this catalog is managed by terraform"
#   properties = {
#     purpose = "Aria catalog for stg01"
#   }

#   storage_root   = "abfss://landing@ingest01landingstg.dfs.core.windows.net/aria_uc_stg"
#   isolation_mode = "ISOLATED"

#   depends_on = [
#     databricks_metastore_assignment.stg01,
#     databricks_external_location.landing_external_stg01
#   ]
# }

# resource "databricks_catalog" "aria_catalog_prod00" {
#   count    = var.env == "prod" ? 1 : 0
#   provider = databricks.prod-00

#   name    = "aria_prod00"
#   comment = "this catalog is managed by terraform"
#   properties = {
#     purpose = "Aria catalog for prod00"
#   }

#   storage_root   = "abfss://landing@ingest00landingprod.dfs.core.windows.net/aria_uc_prod"
#   isolation_mode = "ISOLATED"

#   depends_on = [
#     databricks_metastore_assignment.prod00,
#     databricks_external_location.landing_external_prod00
#   ]
# }

# ## storage credentials
# resource "databricks_storage_credential" "external_sbox00" {
#   count    = var.env == "sbox" ? 1 : 0
#   provider = databricks.sbox-00

#   name = "aria_uc_sbox00"
#   azure_managed_identity {
#     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
#   }
#   isolation_mode = "ISOLATION_MODE_ISOLATED"
#   comment        = "Managed by TF"

#   #   depends_on = [databricks_metastore_assignment.sbox00]
#   depends_on = [time_sleep.wait_for_uc]

# }

# resource "databricks_storage_credential" "external_stg00" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-00

#   name = "aria_uc_stg00"
#   azure_managed_identity {
#     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
#   }
#   isolation_mode = "ISOLATION_MODE_ISOLATED"
#   comment        = "Managed by TF"

#   depends_on = [databricks_metastore_assignment.stg00]
# }

# resource "databricks_storage_credential" "external_stg01" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-01

#   name = "aria_uc_stg01"
#   azure_managed_identity {
#     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["01"].id
#   }
#   isolation_mode = "ISOLATION_MODE_ISOLATED"
#   comment        = "Managed by TF"

#   depends_on = [databricks_metastore_assignment.stg01]
# }

# resource "databricks_storage_credential" "external_prod00" {
#   count    = var.env == "prod" ? 1 : 0
#   provider = databricks.prod-00

#   name = "aria_uc_prod00"
#   azure_managed_identity {
#     access_connector_id = azurerm_databricks_access_connector.ext_access_connector["00"].id
#   }
#   isolation_mode = "ISOLATION_MODE_ISOLATED"
#   comment        = "Managed by TF"

#   depends_on = [databricks_metastore_assignment.prod00]
# }

# resource "databricks_external_location" "landing_external_sbox00" {
#   count    = var.env == "sbox" ? 1 : 0
#   provider = databricks.sbox-00

#   name = "external_storage_location_sbox00"

#   url = format(
#     "abfss://%s@%s.dfs.core.windows.net",
#     "landing",
#     data.azurerm_storage_account.landing["00"].name
#   )

#   credential_name = databricks_storage_credential.external_sbox00[0].name
#   comment         = "Managed by TF"
#   isolation_mode  = "ISOLATION_MODE_ISOLATED"

#   depends_on = [
#     time_sleep.wait_for_uc,
#     databricks_storage_credential.external_sbox00
#   ]
# }

# resource "databricks_external_location" "landing_external_stg00" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-00

#   name = "external_storage_location_stg00"

#   url = format(
#     "abfss://%s@%s.dfs.core.windows.net",
#     "landing",
#     data.azurerm_storage_account.landing["00"].name
#   )

#   credential_name = databricks_storage_credential.external_stg00[0].name
#   comment         = "Managed by TF"
#   isolation_mode  = "ISOLATION_MODE_ISOLATED"

#   depends_on = [
#     time_sleep.wait_for_uc,
#     databricks_storage_credential.external_stg00
#   ]
# }

# resource "databricks_external_location" "landing_external_stg01" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-01

#   name = "external_storage_location_stg01"

#   url = format(
#     "abfss://%s@%s.dfs.core.windows.net",
#     "landing",
#     data.azurerm_storage_account.landing["01"].name
#   )

#   credential_name = databricks_storage_credential.external_stg01[0].name
#   comment         = "Managed by TF"
#   isolation_mode  = "ISOLATION_MODE_ISOLATED"

#   depends_on = [
#     time_sleep.wait_for_uc,
#     databricks_storage_credential.external_stg00
#   ]
# }

# resource "databricks_external_location" "landing_external_prod00" {
#   count    = var.env == "prod" ? 1 : 0
#   provider = databricks.prod-00

#   name = "external_storage_location_prod00"

#   url = format(
#     "abfss://%s@%s.dfs.core.windows.net",
#     "landing",
#     data.azurerm_storage_account.landing["00"].name
#   )

#   credential_name = databricks_storage_credential.external_prod00[0].name
#   comment         = "Managed by TF"
#   isolation_mode  = "ISOLATION_MODE_ISOLATED"

#   depends_on = [
#     time_sleep.wait_for_uc,
#     databricks_storage_credential.external_prod00
#   ]
# }

# ## grants: metastore grants
# resource "databricks_grants" "metastore_grants" {
#   provider  = databricks.account
#   metastore = var.metastore_id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_SERVICE_CREDENTIAL", "CREATE_STORAGE_CREDENTIAL"]
#   }
# }

# # resource "databricks_grants" "metastore_grants_stg00" {
# #   count     = var.env == "stg" ? 1 : 0
# #   provider  = databricks.account
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_SERVICE_CREDENTIAL", "CREATE_STORAGE_CREDENTIAL"]
# #   }
# # }

# # resource "databricks_grants" "metastore_grants_stg01" {
# #   count     = var.env == "stg" ? 1 : 0
# #   provider  = databricks.stg-01
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_SERVICE_CREDENTIAL", "CREATE_STORAGE_CREDENTIAL"]
# #   }
# # }

# # resource "databricks_grants" "metastore_grants_prod00" {
# #   count     = var.env == "prod" ? 1 : 0
# #   provider  = databricks.prod-00
# #   metastore = var.metastore_id

# #   grant {
# #     principal  = databricks_group.aria_admins.display_name
# #     privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_SERVICE_CREDENTIAL", "CREATE_STORAGE_CREDENTIAL"]
# #   }
# # }

# ## grants: storage credential
# resource "databricks_grants" "storage_cred_grants_sbox00" {
#   count              = var.env == "sbox" ? 1 : 0
#   provider           = databricks.sbox-00
#   storage_credential = databricks_storage_credential.external_sbox00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["READ_FILES"]
#   }
# }

# resource "databricks_grants" "storage_cred_grants_stg00" {
#   count              = var.env == "stg" ? 1 : 0
#   provider           = databricks.stg-00
#   storage_credential = databricks_storage_credential.external_stg00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["READ_FILES"]
#   }
# }

# resource "databricks_grants" "storage_cred_grants_stg01" {
#   count              = var.env == "stg" ? 1 : 0
#   provider           = databricks.stg-01
#   storage_credential = databricks_storage_credential.external_stg01[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["READ_FILES"]
#   }
# }

# resource "databricks_grants" "storage_cred_grants_prod00" {
#   count              = var.env == "prod" ? 1 : 0
#   provider           = databricks.prod-00
#   storage_credential = databricks_storage_credential.external_prod00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["READ_FILES"]
#   }
# }

# ## grants: external location
# resource "databricks_grants" "external_location_admin_grants_sbox00" {
#   count             = var.env == "sbox" ? 1 : 0
#   provider          = databricks.sbox-00
#   external_location = databricks_external_location.landing_external_sbox00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["BROWSE", "READ_FILES"]
#   }
# }

# resource "databricks_grants" "external_location_admin_grants_stg00" {
#   count             = var.env == "stg" ? 1 : 0
#   provider          = databricks.stg-00
#   external_location = databricks_external_location.landing_external_stg00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["BROWSE", "READ_FILES"]
#   }
# }

# resource "databricks_grants" "external_location_admin_grants_stg01" {
#   count             = var.env == "stg" ? 1 : 0
#   provider          = databricks.stg-01
#   external_location = databricks_external_location.landing_external_stg01[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["BROWSE", "READ_FILES"]
#   }
# }

# resource "databricks_grants" "external_location_admin_grants_prod00" {
#   count             = var.env == "prod" ? 1 : 0
#   provider          = databricks.prod-00
#   external_location = databricks_external_location.landing_external_prod00[0].id

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES", "MANAGE"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["BROWSE", "READ_FILES"]
#   }
# }

# ## grants: catalog
# resource "databricks_grants" "catalog_aria_grants_sbox00" {
#   count    = var.env == "sbox" ? 1 : 0
#   provider = databricks.sbox-00
#   catalog  = databricks_catalog.aria_catalog_sbox00[0].name

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
#   }
# }

# resource "databricks_grants" "catalog_aria_grants_stg00" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-00
#   catalog  = databricks_catalog.aria_catalog_stg00[0].name

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
#   }
# }

# resource "databricks_grants" "catalog_aria_grants_stg01" {
#   count    = var.env == "stg" ? 1 : 0
#   provider = databricks.stg-01
#   catalog  = databricks_catalog.aria_catalog_stg01[0].name

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
#   }
# }

# resource "databricks_grants" "catalog_aria_grants_prod00" {
#   count    = var.env == "prod" ? 1 : 0
#   provider = databricks.prod-00
#   catalog  = databricks_catalog.aria_catalog_prod00[0].name

#   grant {
#     principal  = databricks_group.aria_admins.display_name
#     privileges = ["ALL_PRIVILEGES"]
#   }

#   grant {
#     principal  = databricks_group.aria_users.display_name
#     privileges = ["USE_CATALOG", "USE_SCHEMA", "BROWSE", "SELECT", "EXTERNAL_USE_SCHEMA", "READ_VOLUME", "EXECUTE"]
#   }
# }

# resource "time_sleep" "wait_for_uc" {
#   depends_on = [
#     databricks_metastore_assignment.sbox00
#   ]

#   create_duration = "90s"
# }

