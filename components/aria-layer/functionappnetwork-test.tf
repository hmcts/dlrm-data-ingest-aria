resource "azurerm_storage_account" "example1" {
  for_each = var.landing_zones

  name                = "testfunctionapp12345${each.key}"
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.key}-main-${var.env}"].name

  location                 = "UK South"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [data.azurerm_subnet.lz["ingest${each.key}-data-product-001-${var.env}"].id]
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
  storage_account_name       = azurerm_storage_account.example1[each.value.lz_key].name               #azurerm_storage_account.example[each.key].name               
  storage_account_access_key = azurerm_storage_account.example1[each.value.lz_key].primary_access_key #azurerm_storage_account.example[each.key].primary_access_key 
  virtual_network_subnet_id  = data.azurerm_subnet.lz["ingest${each.value.lz_key}-data-product-001-${var.env}"].id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.example[each.key].connection_string
    AzureWebJobsFeatureFlags              = "EnableWorkerIndexing"
    AzureWebJobsStorage                   = azurerm_storage_account.example1[each.value.lz_key].primary_connection_string
    # BUILD_FLAGS                                           = "UseExpressBuild"
    ENABLE_ORYX_BUILD                                     = "true"
    ENVIRONMENT                                           = var.env
    FUNCTIONS_EXTENSION_VERSION                           = "~4"
    FUNCTIONS_WORKER_RUNTIME                              = "python"
    LZ_KEY                                                = each.value.lz_key
    PYTHON_ENABLE_WORKER_EXTENSIONS                       = 1
    sboxdlrmeventhubns_RootManageSharedAccessKey_EVENTHUB = data.azurerm_eventhub_namespace_authorization_rule.lz[each.value.lz_key].primary_connection_string
    # SCM_DO_BUILD_DURING_DEPLOYMENT                        = 1
    # XDG_CACHE_HOME                                        = "/tmp/.cache"
    # WEBSITE_RUN_FROM_PACKAGE                              = 1
    # WEBSITE_RUN_FROM_PACKAGE                              = "https://${data.azurerm_storage_account.xcutting[each.value.lz_key].name}.blob.core.windows.net/data/af-zip/${each.value.base_name}.zip${coalesce(data.azurerm_storage_account_sas.xcutting[each.value.lz_key].sas, "")}"
    # WEBSITE_CONTENTOVERVNET = 1
    # WEBSITE_CONTENTSHARE                     = each.value.full_name
    # WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = zurerm_storage_account.example1[each.value.lz_key].primary_connection_string
  }

  # identity {
  #   type = "SystemAssigned"
  # }

  site_config {
    application_stack {
      python_version = "3.11"
    }

    always_on = true
    # ftps_state                  = "FtpsOnly"
    # vnet_route_all_enabled      = true
  }

  # https_only = true

  tags = module.ctags.common_tags

  depends_on = [
    azurerm_storage_account.example1
  ]
}
