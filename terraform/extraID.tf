####################
# App Registration #
####################

resource "azuread_application_registration" "databricks_app" {
  display_name = "databricks-app"
  description  = "For Databricks access datalake files"
}
