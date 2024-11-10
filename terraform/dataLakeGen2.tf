resource "azurerm_storage_account" "datalake" {
  name                            = "datalakesf01"
  resource_group_name             = azurerm_resource_group.data_eng_prj.name
  location                        = azurerm_resource_group.data_eng_prj.location
  account_tier                    = "Standard"
  account_replication_type        = "RAGRS"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = "true"
}

##################
#   Containers   #
##################

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}