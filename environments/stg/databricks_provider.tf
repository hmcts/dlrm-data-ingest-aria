provider "databricks" {
  alias                       = "stg-00"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.db_ws["stg-00"].id
  host                        = data.azurerm_databricks_workspace.db_ws["stg-00"].workspace_url

  azure_client_id     = var.ClientId
  azure_client_secret = var.ClientSecret # TODO: for stg, request client secret value from platops
  azure_tenant_id     = var.TenantId
}
