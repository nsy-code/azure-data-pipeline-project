variable "subscription_id" {
  type        = string
  description = "The ID of the Azure subscription"
}

variable "mssql_server_resource_id" {
  type        = string
  description = "The ID of the Azure SQL Server"
}

variable "source_db_username" {
  type        = string
  description = "The username for the source database"
}

variable "source_db_connection_string" {
  type        = string
  description = "The connection string for the source database"
}

variable "datalake_access_key" {
  type = string
  description = "The access key for the Data Lake Storage account"
}

variable "databricks_cluster_id" {
  type = string
  description = "The ID of the Databricks cluster"
}
