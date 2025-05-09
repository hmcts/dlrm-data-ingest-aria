
# Creating service plan for function app - looping over each function_app per landing zone
resource "azurerm_service_plan" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
  }

  name                = each.value.name # pulls function_app names from locals
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  os_type             = "Linux"
  sku_name            = "EP1"

  tags = module.ctags.common_tags
}

# Define the function app 
resource "azurerm_linux_function_app" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
    if !(var.env == "sbox" && app.lz_key == "00")
  }

  name                       = each.value.name 
  resource_group_name        = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                   = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  service_plan_id            = azurerm_service_plan.example[each.key].id
  storage_account_name       = data.azurerm_storage_account.xcutting[each.value.lz_key].name
  storage_account_access_key = data.azurerm_storage_account.xcutting[each.value.lz_key].primary_access_key

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING                 = azurerm_application_insights.example[each.key].connection_string
    AzureWebJobsFeatureFlags                              = "EnableWorkerIndexing"
    BUILD_FLAGS                                           = "UseExpressBuild"
    ENABLE_ORYX_BUILD                                     = true
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.value.lz_key].primary_connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT                        = 1
    XDG_CACHE_HOME                                        = "/tmp/.cache"
    WEBSITE_RUN_FROM_PACKAGE                              = "1"
  }

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = false
  }

  tags = module.ctags.common_tags
}


resource "azurerm_application_insights" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
  }

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  workspace_id        = data.azurerm_log_analytics_workspace.lz[each.value.lz_key].id
  application_type    = "web"

  tags = module.ctags.common_tags
}

# Define an action group to use in the smart_detector
resource "azurerm_monitor_action_group" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
  }
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  short_name          = element(split("-", each.value.name), 1)

  tags = module.ctags.common_tags
}


resource "azurerm_monitor_smart_detector_alert_rule" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.name}" => app
  }

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.example[each.key].id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"

  action_group {
    ids = [azurerm_monitor_action_group.example[each.key].id]
  }

  tags = module.ctags.common_tags
}


#resource "azurerm_storage_account" "this" {
#  for_each                 = var.landing_zones
#  name                     = "ingest${each.key}${var.env}example"
#  resource_group_name      = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
#  location                 = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
#  account_tier             = "Standard"
#  account_kind             = "StorageV2"
#  account_replication_type = "LRS"
#  tags                     = module.ctags.common_tags
#}