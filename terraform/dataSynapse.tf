resource "azurerm_storage_data_lake_gen2_filesystem" "synapse" {
  name               = "data"
  storage_account_id = azurerm_storage_account.synapse.id
}

resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "data-synw"
  resource_group_name                  = azurerm_resource_group.data_eng_prj.name
  location                             = azurerm_resource_group.data_eng_prj.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse.id
  sql_administrator_login              = "sqladminuser"

  identity {
    type = "SystemAssigned"
  }
}
