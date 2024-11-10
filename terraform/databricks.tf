resource "azurerm_databricks_workspace" "transform" {
  name                = "data-databricks-01"
  resource_group_name = azurerm_resource_group.data_eng_prj.name
  location            = azurerm_resource_group.data_eng_prj.location
  sku                 = "premium"
}