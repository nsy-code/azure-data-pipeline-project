resource "azurerm_data_factory" "data_eng_prj_df" {
  name                = "data-datafactory-ts01"
  location            = azurerm_resource_group.data_eng_prj.location
  resource_group_name = azurerm_resource_group.data_eng_prj.name
  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }

}