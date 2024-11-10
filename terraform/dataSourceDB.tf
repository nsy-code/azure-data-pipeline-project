resource "azurerm_mssql_database" "data_source_db" {
  name                 = "data-sourcesql"
  server_id            = var.mssql_server_resource_id
  storage_account_type = "Local"
}
