resource "azurerm_data_factory_pipeline" "copy_all_tables" {
  name            = "copy_all_tables"
  data_factory_id = azurerm_data_factory.data_eng_prj_df.id
  activities_json = <<JSON
  [
    {
      "name": "look for all tables",
      "type": "Lookup",
      "dependsOn": [],
      "policy": {
          "timeout": "0.12:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "source": {
              "type": "SqlServerSource",
              "sqlReaderQuery": "SELECT \ns.name AS SchemaName,\nt.name AS TableName\nFROM sys.tables t\nINNER JOIN sys.schemas s ON t.schema_id = s.schema_id \nWHERE s.name = 'SalesLT'",
              "queryTimeout": "02:00:00",
              "partitionOption": "None"
          },
          "dataset": {
              "referenceName": "SqlServerTable1",
              "type": "DatasetReference"
          },
          "firstRowOnly": false
      }
    },
    {
      "name": "foreach schema table",
      "type": "ForEach",
      "dependsOn": [
          {
              "activity": "look for all tables",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "userProperties": [],
      "typeProperties": {
          "items": {
              "value": "@activity('look for all tables').output.value",
              "type": "Expression"
          },
          "activities": [
              {
                  "name": "copy each table",
                  "type": "Copy",
                  "dependsOn": [],
                  "policy": {
                      "timeout": "0.12:00:00",
                      "retry": 0,
                      "retryIntervalInSeconds": 30,
                      "secureOutput": false,
                      "secureInput": false
                  },
                  "userProperties": [],
                  "typeProperties": {
                      "source": {
                          "type": "SqlServerSource",
                          "sqlReaderQuery": {
                              "value": "@concat('SELECT * FROM ',item().SchemaName,'.',item().TableName)",
                              "type": "Expression"
                          },
                          "queryTimeout": "02:00:00",
                          "partitionOption": "None"
                      },
                      "sink": {
                          "type": "ParquetSink",
                          "storeSettings": {
                              "type": "AzureBlobFSWriteSettings"
                          },
                          "formatSettings": {
                              "type": "ParquetWriteSettings"
                          }
                      },
                      "enableStaging": false,
                      "translator": {
                          "type": "TabularTranslator",
                          "typeConversion": true,
                          "typeConversionSettings": {
                              "allowDataTruncation": true,
                              "treatBooleanAsNumber": false
                          }
                      }
                  },
                  "inputs": [
                      {
                          "referenceName": "SqlServerCopy",
                          "type": "DatasetReference"
                      }
                  ],
                  "outputs": [
                      {
                          "referenceName": "parquetTables",
                          "type": "DatasetReference",
                          "parameters": {
                              "schemaname": {
                                  "value": "@item().SchemaName",
                                  "type": "Expression"
                              },
                              "tablename": {
                                  "value": "@item().TableName",
                                  "type": "Expression"
                              }
                          }
                      }
                  ]
              }
          ]
      }
    },
    {
      "name": "Bronze to Silver",
      "type": "DatabricksNotebook",
      "dependsOn": [
          {
              "activity": "foreach schema table",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "policy": {
          "timeout": "0.12:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "notebookPath": "/Shared/bronze to silver"
      },
      "linkedServiceName": {
          "referenceName": "AzureDatabricks1",
          "type": "LinkedServiceReference"
      }
    },
    {
      "name": "Silver to Gold",
      "type": "DatabricksNotebook",
      "dependsOn": [
          {
              "activity": "Bronze to Silver",
              "dependencyConditions": [
                  "Succeeded"
              ]
          }
      ],
      "policy": {
          "timeout": "0.12:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "notebookPath": "/Shared/silver to gold"
      },
      "linkedServiceName": {
          "referenceName": "AzureDatabricks1",
          "type": "LinkedServiceReference"
      }
    }
  ]
  JSON
}