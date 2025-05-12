locals {
  resource_group_names        = ["network", "logic", "management", "logging", "runtimes", "storage", "external-storage", "metadata", "shared-integration", "shared-product", "di001", "di002", "dp001", "dp002"]
  ip_kit_resource_group_names = ["network", "logic", "main"]

  flattened_resource_groups = flatten([
    for lz_key, lz in var.landing_zones : [
      for rg in lz.use_microsoft_ip_kit_structure ? local.ip_kit_resource_group_names : local.resource_group_names : "ingest${lz_key}-${rg}-${var.env}"
    ]
  ])

  subnets = ["data-bricks-private", "data-bricks-product-private", "data-bricks-product-public", "data-bricks-public", "data-integration-001", "data-integration-002", "data-product-001", "data-product-002", "services-mysql", "services"]
  flattened_subnets = flatten([
    for lz_key, lz in var.landing_zones : [
      for subnet in local.subnets : {
        name   = "ingest${lz_key}-${subnet}-${var.env}"
        lz_key = lz_key
      }
    ]
  ])

  # Function App 
<<<<<<< HEAD
=======
  # Function App 
>>>>>>> 18cc577ba336d045c398b5f408396dc5877d48d3
  function_apps_base = [
    "af-sbails",
    "af-apflpa",
    "af-apluta",
    "af-apl",
    "af-bails",
    "af-joh",
    "af-td"
  ]

  flattened_function_apps = flatten([
    for lz_key, lz in var.landing_zones : [ # 00, 02 in sbox
      for app in local.function_apps_base :
      {
        base_name = app
        lz_key    = lz_key
        full_name = "${app}-${var.env}${lz_key}-uks-dlrm-01"
      }
    ]
  ])
}
