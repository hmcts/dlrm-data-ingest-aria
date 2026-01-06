
#Storage account is required for function_app provisioning

locals {
  container_name = ["bronze", "silver", "gold"]

  container_matrix = {
    for pair in setproduct(keys(var.landing_zones), local.container_name) :
    "${pair[0]}-${pair[1]}" => {
      lz_key         = pair[0]
      container_name = pair[1]
    }
    #if !contains(["01"], pair[0]) #exclude deploying to 01 as resources exist. State file was locked and is confused / wont destroy or create. Easy work-around as we don't need for other envs
  }
}

data "azurerm_storage_account" "curated" {

  for_each = var.landing_zones

  name                = "ingest${each.key}curated${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_storage_container" "curated_extra" {
  for_each = local.container_matrix

  name                  = each.value.container_name
  storage_account_name  = data.azurerm_storage_account.curated[each.value.lz_key].name
  container_access_type = "private"
}


data "azurerm_storage_account_sas" "curated" {
  for_each = var.landing_zones

  connection_string = data.azurerm_storage_account.curated[each.key].primary_connection_string

  https_only = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2025-03-21T00:00:00Z"
  expiry = "2026-03-21T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

#reference SAS token for the functionapp for the data container in each xcutting
data "azurerm_storage_account_sas" "xcutting" {
  for_each = var.landing_zones

  connection_string = azurerm_storage_account.xcutting[each.key].primary_connection_string
  https_only        = true

  services {
    blob  = true
    file  = true
    queue = true
    table = true
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }

  start  = "2024-01-01T00:00:00Z"
  expiry = "2027-12-31T23:59:59Z"
}

# # add in containers for landing

data "azurerm_storage_account" "landing" {
  for_each = var.landing_zones

  name                = "ingest${each.key}landing${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_storage_container" "landing" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for container in ["html-template"] : {
          key       = "${lz_key}-${container}"
          lz_key    = lz_key
          container = container
        }
      ]
    ]) :
    combo.key => combo
    if !(var.env == "sbox" && combo.lz_key == "00") #|| combo.lz_key == "01"
  }

  name                  = each.value.container
  storage_account_name  = data.azurerm_storage_account.landing[each.value.lz_key].name
  container_access_type = "private"
}

# # add in containers for external

data "azurerm_storage_account" "external" {
  for_each = var.landing_zones

  name                = "ingest${each.key}external${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}

resource "azurerm_storage_container" "external" {
  for_each = {
    for lz_key in keys(var.landing_zones) :
    lz_key => {
      lz_key = lz_key
    }
    if lz_key != "00" #&& lz_key != "01"
  }

  name                  = "external-csv"
  storage_account_name  = data.azurerm_storage_account.external[each.value.lz_key].name
  container_access_type = "private"
}

resource "azurerm_storage_container" "xcutting" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for container in ["db-ack-checkpoint", "db-rsp-checkpoint", "af-idempotency"] : {
          key       = "${lz_key}-${container}"
          lz_key    = lz_key
          container = container
        }
      ]
    ]) :
  combo.key => combo }

  name                  = each.value.container
  storage_account_name  = azurerm_storage_account.xcutting[each.value.lz_key].name
  container_access_type = "private"
}


#Add raw storage container to raw storage account

data "azurerm_storage_account" "raw" {
  for_each = var.landing_zones

  name                = "ingest${each.key}raw${var.env}"
  resource_group_name = "ingest${each.key}-main-${var.env}"
}


resource "azurerm_storage_container" "raw" {
  for_each = {
    for combo in flatten([
      for lz_key, _ in var.landing_zones : [
        for container in ["raw"] : {
          key       = "${lz_key}-${container}"
          lz_key    = lz_key
          container = container
        }
      ]
    ]) :
    combo.key => combo
    if !(var.env == "sbox")
  }

  name                  = each.value.container
  storage_account_name  = data.azurerm_storage_account.raw[each.value.lz_key].name
  container_access_type = "private"
}
