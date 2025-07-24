
# # Creating service plan for function app - looping over each function_app per landing zone
resource "azurerm_service_plan" "example" {
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

resource "azurerm_storage_account" "xcutting" {
  for_each = var.landing_zones

  name                = "ingest${each.key}xcutting${var.env}"
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name

  location                 = "UK South"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow" #Allow
    virtual_network_subnet_ids = []      #data.azurerm_subnet.lz["ingest${each.key}-data-product-001-${var.env}"].id] 
  }
}

resource "azurerm_linux_function_app" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    "${app.lz_key}-${app.base_name}" => app
  }

  name                       = each.value.full_name
  resource_group_name        = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location                   = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  service_plan_id            = azurerm_service_plan.example[each.key].id
  storage_account_name       = azurerm_storage_account.xcutting[each.value.lz_key].name
  storage_account_access_key = azurerm_storage_account.xcutting[each.value.lz_key].primary_access_key
  virtual_network_subnet_id  = data.azurerm_subnet.lz["ingest${each.value.lz_key}-data-product-001-${var.env}"].id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING                 = azurerm_application_insights.example[each.key].connection_string
    AzureWebJobsFeatureFlags                              = "EnableWorkerIndexing"
    AzureWebJobsStorage                                   = azurerm_storage_account.xcutting[each.value.lz_key].primary_connection_string
    ENABLE_ORYX_BUILD                                     = true
    ENVIRONMENT                                           = var.env
    FUNCTIONS_EXTENSION_VERSION                           = "~4"
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    LZ_KEY                                                = each.value.lz_key
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.value.lz_key].primary_connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT                        = 1
    # XDG_CACHE_HOME                                        = "/tmp/.cache"
    WEBSITE_RUN_FROM_PACKAGE = 1
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }

    always_on = true
  }

  # https_only = true

  tags = module.ctags.common_tags

  depends_on = [
    azurerm_storage_account.xcutting
  ]
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