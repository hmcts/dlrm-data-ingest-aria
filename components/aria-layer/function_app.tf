
# Creating service plan for function app - looping over each function_app per landing zone
resource "azurerm_service_plan" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                = each.value.full_name # pulls function_app names from locals
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  os_type             = "Linux"
  sku_name            = "EP1"

  tags = module.ctags.common_tags
}

# log analytics workspace - query via platops - needs permissions to read from the 
#azure cant access logs via app service and is timing out

# Define the function app 
resource "azurerm_linux_function_app" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                       = each.value.full_name
  resource_group_name        = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                   = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  service_plan_id            = azurerm_service_plan.example[each.key].id
  storage_account_name       = data.azurerm_storage_account.xcutting[each.value.lz_key].name                       #azurerm_storage_account.example[each.key].name        
  storage_account_access_key = data.azurerm_storage_account.xcutting[each.value.lz_key].primary_access_key         #azurerm_storage_account.example[each.key].primary_access_key
  virtual_network_subnet_id  = data.azurerm_subnet.lz["ingest${each.value.lz_key}-data-product-001-${var.env}"].id #ingest02-data-product-001-sbox

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING                 = azurerm_application_insights.example[each.key].connection_string
    AzureWebJobsFeatureFlags                              = "EnableWorkerIndexing"
    BUILD_FLAGS                                           = "UseExpressBuild"
    ENABLE_ORYX_BUILD                                     = true
    ENVIRONMENT                                           = var.env
    FUNCTIONS_EXTENSION_VERSION                           = "~4"
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    LZ_KEY                                                = each.value.lz_key
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.value.lz_key].primary_connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT                        = true
    XDG_CACHE_HOME                                        = "/tmp/.cache"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING              = data.azurerm_storage_account.xcutting[each.value.lz_key].primary_connection_string
    WEBSITE_CONTENTSHARE                                  = each.value.full_name
    WEBSITE_CONTENTOVERVNET                               = "1"
    WEBSITE_RUN_FROM_PACKAGE                              = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true

    scm_use_main_ip_restriction = false
    ftps_state                  = "FtpsOnly"

    runtime_scale_monitoring_enabled = true
    vnet_route_all_enabled           = true
  }

  timeouts {
    read   = "10m"
    update = "40m"
  }

  tags = module.ctags.common_tags
}


resource "azurerm_application_insights" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                = each.value.full_name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  workspace_id        = data.azurerm_log_analytics_workspace.lz[each.value.lz_key].id
  application_type    = "web"

  tags = module.ctags.common_tags
}

# Define an action group to use in the smart_detector
# resource "azurerm_monitor_action_group" "example" {
#   for_each = {
#     for app in local.flattened_function_apps :
#     "${app.lz_key}-${app.base_name}" => app
#   }
#   name                = each.value.full_name
#   resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
#   short_name          = element(split("-", each.value.full_name), 1)

#   tags = module.ctags.common_tags
# }


# resource "azurerm_monitor_smart_detector_alert_rule" "example" {
#   for_each = {
#     for app in local.flattened_function_apps :
#     "${app.lz_key}-${app.base_name}" => app
#   }

#   name                = each.value.full_name
#   resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
#   severity            = "Sev3"
#   scope_resource_ids  = [azurerm_application_insights.example[each.key].id]
#   frequency           = "PT1M"
#   detector_type       = "FailureAnomaliesDetector"

#   action_group {
#     ids = [azurerm_monitor_action_group.example[each.key].id]
#   }

#   tags = module.ctags.common_tags
# }
