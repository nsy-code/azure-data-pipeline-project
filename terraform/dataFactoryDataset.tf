##################
# Source Dataset #
##################

resource "azurerm_data_factory_dataset_sql_server_table" "address" {
  name                = "address"
  data_factory_id     = azurerm_data_factory.data_eng_prj_df.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.data_eng_prj_ls.name
  table_name          = "SalesLT.address"
}

##################
#  Sink Dataset  #
##################

resource "azurerm_data_factory_dataset_parquet" "address" {
  name                = "address_parquet"
  data_factory_id     = azurerm_data_factory.data_eng_prj_df.id
  compression_codec   = "snappy"
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.address_table_parquet.name

  azure_blob_fs_location {
    dynamic_file_system_enabled = false
    dynamic_filename_enabled    = false
    dynamic_path_enabled        = false
    file_system                 = "bronze"
    filename                    = null
    path                        = null
  }

}
