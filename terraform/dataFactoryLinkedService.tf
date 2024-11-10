##################
# Linked Service #
##################

resource "azurerm_data_factory_linked_service_azure_databricks" "adb" {
  name            = "AzureDatabricks1"
  data_factory_id = azurerm_data_factory.data_eng_prj_df.id
  adb_domain      = "https://${azurerm_databricks_workspace.transform.workspace_url}"
  existing_cluster_id = var.databricks_cluster_id

  key_vault_password {
    linked_service_name="AzureKeyVault1"
    secret_name="databricks-token"
  }
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "address_table_parquet" {
  name                = "AzureDataLakeStorage1"
  data_factory_id     = azurerm_data_factory.data_eng_prj_df.id
  url                 = azurerm_storage_account.datalake.primary_dfs_endpoint
  storage_account_key = var.datalake_access_key
}

resource "azurerm_data_factory_linked_service_sql_server" "data_eng_prj_ls" {
  name              = "SqlServer1"
  data_factory_id   = azurerm_data_factory.data_eng_prj_df.id
  user_name         = var.source_db_username
  connection_string = var.source_db_connection_string

  key_vault_password {
    linked_service_name = "AzureKeyVault1"
    secret_name         = "source-DB-Password"
  }
}