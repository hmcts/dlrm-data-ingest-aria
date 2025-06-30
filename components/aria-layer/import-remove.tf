removed {
  from = azurerm_linux_function_app.example

  lifecycle {
    destroy = false
  }
}

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
