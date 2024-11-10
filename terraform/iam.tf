resource "azurerm_role_assignment" "databricks_access_datalake" {
  name                 = "93467850-12c6-5ee5-ac03-0c43ds625832"
  scope                = azurerm_storage_account.synapse.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_application_registration.databricks_app.object_id
}
