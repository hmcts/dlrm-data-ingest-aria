locals {
    base_name = 
}



data "azure_eventhub_namespace" "aria_eventhub_ns" {
    for_each = var.landing
    name = ""
}