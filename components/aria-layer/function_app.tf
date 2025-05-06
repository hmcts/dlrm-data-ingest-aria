
# Creating service plan for function app - looping over each function_app per landing zone
resource "azurerm_service_plan" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    app.name => app
  }

  name                = each.key # pulls function_app names from locals
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  os_type             = "Linux"
  sku_name            = "B1" # to verify sku with Ara - premium required? (ElasticPremium)
}

# Define the function app 
resource "azurerm_linux_function_app" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    app.name => app
  }

  name                = each.key
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  service_plan_id     = azurerm_service_plan.example[each.key].id

  site_config = {
    always_on = false
  } 
}

resource "azurerm_application_insights" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    app.name => app
  }

  name                = each.key
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  location            = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_monitor_smart_detector_alert_rule" "example" {
  for_each = {
    for app in local.flattened_function_apps :
    app.name => app
  }

  name                = each.key
  resource_group_name = data.azurerm_resource_group.lz["ingest${each.value.lz_key}-main-${var.env}"].name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.example[each.key].id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
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