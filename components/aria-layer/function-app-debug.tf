locals {
  functionapp_00 = {
    for k, v in var.landing_zones :
    k => v
    if !(k == "01" && k == "02")
  }
}

# Creating service plan for function app - looping over each function_app per landing zone
resource "azurerm_service_plan" "test" {
  for_each = local.functionapp_00

  name                = "functionapp-test"
  resource_group_name = "ingest${each.key}-main-${var.env}"
  location            = "UK South"
  os_type             = "Linux"
  sku_name            = "EP1"

  tags = module.ctags.common_tags
}

resource "azurerm_linux_function_app" "test" {
  for_each = local.functionapp_00

  name                       = "test-function"
  resource_group_name        = "ingest${each.key}-main-${var.env}"
  location                   = "UK South"
  service_plan_id            = azurerm_service_plan.test[each.key].id
  storage_account_name       = data.azurerm_storage_account.xcutting[each.key].name
  storage_account_access_key = data.azurerm_storage_account.xcutting[each.key].primary_access_key
  virtual_network_subnet_id  = data.azurerm_subnet.lz["ingest${each.key}-data-product-001-${var.env}"].id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING                 = azurerm_application_insights.test[each.key].connection_string
    AzureWebJobsFeatureFlags                              = "EnableWorkerIndexing"
    AzureWebJobsStorage                                   = data.azurerm_storage_account.xcutting[each.key].primary_connection_string #"BlobEndpoint=https://${data.azurerm_storage_account.xcutting[each.key].name}.blob.core.windows.net/;QueueEndpoint=https://${data.azurerm_storage_account.xcutting[each.key].name}.queue.core.windows.net/;FileEndpoint=https://${data.azurerm_storage_account.xcutting[each.key].name}.file.core.windows.net/;TableEndpoint=https://${data.azurerm_storage_account.xcutting[each.key].name}.table.core.windows.net/;SharedAccessSignature=${data.azurerm_storage_account_sas.xcutting[each.key].sas}"
    BUILD_FLAGS                                           = "UseExpressBuild"
    ENABLE_ORYX_BUILD                                     = "true"
    ENVIRONMENT                                           = var.env
    FUNCTIONS_EXTENSION_VERSION                           = "~4"
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    LZ_KEY                                                = each.key
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.key].primary_connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT                        = 1
    # XDG_CACHE_HOME                                        = "/tmp/.cache"
    WEBSITE_RUN_FROM_PACKAGE = 1
    WEBSITE_CONTENTOVERVNET  = 1
    # WEBSITE_CONTENTSHARE                                  = each.value.full_name
    # WEBSITE_CONTENTAZUREFILECONNECTIONSTRING              = data.azurerm_storage_account.xcutting[each.key].primary_connection_string
  }
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }

    ftps_state             = "FtpsOnly"
    vnet_route_all_enabled = true
  }

  https_only = true

  tags = module.ctags.common_tags
}


resource "azurerm_application_insights" "test" {
  for_each = local.functionapp_00

  name                = each.value.full_name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].location
  workspace_id        = data.azurerm_log_analytics_workspace.lz[each.key].id
  application_type    = "web"

  tags = module.ctags.common_tags
}




############################################



resource "azurerm_service_plan" "example1" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                = each.value.full_name
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  os_type             = "Linux"
  sku_name            = "EP1"

  tags = module.ctags.common_tags
}

resource "azurerm_linux_function_app" "example1" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                       = each.value.full_name
  resource_group_name        = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                   = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  service_plan_id            = azurerm_service_plan.example1[each.key].id
  storage_account_name       = azurerm_storage_account.example[each.key].name               #data.azurerm_storage_account.xcutting[each.value.lz_key].name                                     
  storage_account_access_key = azurerm_storage_account.example[each.key].primary_access_key #data.azurerm_storage_account.xcutting[each.value.lz_key].primary_access_key 
  virtual_network_subnet_id  = data.azurerm_subnet.lz["ingest${each.value.lz_key}-data-product-001-${var.env}"].id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING                 = azurerm_application_insights.example[each.key].connection_string
    AzureWebJobsFeatureFlags                              = "EnableWorkerIndexing"
    BUILD_FLAGS                                           = "UseExpressBuild"
    ENABLE_ORYX_BUILD                                     = true
    ENVIRONMENT                                           = var.env
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    LZ_KEY                                                = each.value.lz_key
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.value.lz_key].primary_connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT                        = 1
    XDG_CACHE_HOME                                        = "/tmp/.cache"
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
    always_on = false

    scm_use_main_ip_restriction = false
    ftps_state                  = "FtpsOnly"
  }

  tags = module.ctags.common_tags
}

