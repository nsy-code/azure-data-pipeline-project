
# Azure Data Pipeline Project

<img src="./asset/architecture.png">

# Tools:
	1. SQL Server & SQL Database
	2. Azure Data Factory
	2. Azure Data Lake Storage Gen2
	3. Azure Databricks
	4. Azure Synapse Analytics
	5. Azure Key vault
	6. Microsoft Entra ID

# Folder Structure:
1. `/asset`: contains docs, images, etc.
2. `/terraform`: contains terraform scripts that will be used to setup resources
3. `/databricks`: contains databricks notebooks

# Steps to build the pipeline:
## 1. Setup Source SQL DB
- Setup SQL-server and SQL Database
- Using sample data `AdventureWorksLT` \
 ref: https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms 

	<img src="./asset/source_db.png" width="250">

- Create User
	```sql
		-- In master db
		CREATE LOGIN readonlyuser WITH password='password';
		-- In source db
		CREATE USER readonlyuser FROM LOGIN readonlyuser;
		EXEC sp_addrolemember 'db_datareader', 'readonlyuser';
	```
- Disable Microsoft Entra authentication only

## 2. Add Source SQL DB Login info into Azure Key vault
<img src="./asset/azure_kv_add_secrets.png">
- Assign "Key Vault Administrator" role to current user 
- Create a secret for db user name
- Create a secret for db password

## 3. Data Ingestion
### Setup Data Factory Copy tables from Source SQL DB to Azure Data Lake Storage Gen2
<img src="./asset/relationship-between-data-factory-entities.png">
<img src="./asset/load_all_tables.png" width="350">

1. #### Using Lookup Activity to get all table name in source database.
- In Setting tab, select `Use Query`
```sql
SELECT 
s.name AS SchemaName,
t.name AS TableName
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 			WHERE s.name = 'SalesLT'
```

1. #### Using ForEach Activity to copy each table
- Pipeline expression builder
`@activity('look for all tables').output.value`

1. #### Using Copy Activity to copy each table from the Source SQL Server to the Azure Data Lake Storage Gen2.
- Setup Source
- Create dataset by using Pipeline expression builder.
```@concat('SELECT * FROM ', item().SchemaName,'.',item().TableName)```
- Setup Sink
- Create dataset for Azure Data Lake Storage Gen2.
- To create a file structure like 
	```bash
	bronze/{Schema}/{TableName}/{TableName}.parquet
	``` 
	Create a parameter for SchemaName and TableName. Connect 2 parameters to `item().SchemaName` and ``item().TableName`.

	<img src="./asset/sink_create_parameters.png">

	Set file path `@concat(dataset().schemaname, '/', dataset().tablename)`

	Set file name `@concat(dataset().tablename, '.parquet')`

	<img src="./asset/set_filepath_filename.png">

- #### Publish all
- #### Trigger and Monitor

## 4. Data Transformation
- Create Databricks Cluster
- Create service principal and connect to Azure Data Lake Storage Gen2 \
  ref: https://learn.microsoft.com/en-us/azure/databricks/connect/storage/tutorial-azure-storage
  - When try to get secrets from Azure Key Vault-backed secret scope, it needs to set Permission model to Vault access policy
	```
	Creating an Azure Key Vault-backed secret scope role grants the Get and List permissions to the application ID for the Azure Databricks service using key vault access policies. The Azure role-based access control permission model is not currently supported with Azure Databricks.

	https://learn.microsoft.com/en-us/azure/databricks/security/secrets/secret-scopes#akv-ss
	```
- Create Databricks workspace and notebook
  - `databricks/storage_mount.ipynb`: mount Data Lake Storage account to Databricks File System (DBFS)
	ref: https://learn.microsoft.com/en-us/azure/databricks/connect/storage/azure-storage
  - `databricks/bronze_to_silver.ipynb`: transform data from bronze to silver
  - `databricks/silver_to_gold.ipynb`: transform data from silver to gold

- Create Databricks linked service in Data Factory Pipeline
	
	<img src="./asset/adf_pipeline.png">

- Create Schedule Tigger for Data pipeline 

	<img src="./asset/schedule.png" width="350">

## 5. Data Mart building
- Create Table Views in Azure Synapse Analytics
  - Create serverless SQL database
  - Create Name convension stored procedure for Views
	```sql
	USE gold_db
	GO
	CREATE OR ALTER PROC CreateSQLServerlessView_gold @ViewName nvarchar(100)
	AS
	BEGIN
	DECLARE @statement VARCHAR(MAX)
		SET @statement = N'CREATE OR ALTER VIEW '+ @viewName + ' AS
			SELECT *
			FROM
				OPENROWSET(
					BULK ''https://datalakesf01.dfs.core.windows.net/gold/SalesLT/' + @ViewName + '/'',
					FORMAT = ''DELTA''
				) AS [result]
		'
	EXEC (@statement)
	END
	GO
	```
  - Setup pipelines to create Views 

	<img src="./asset/asy_pipeline.png" width="350">

## 6. Infastructure as Code
Terraform automates the provisioning of resources like Azure Data Lake and Synapse Analytics, ensuring consistency across environments. With reusable modules and parameterization, teams can streamline setups and adapt configurations easily.
