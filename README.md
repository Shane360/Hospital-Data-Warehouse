# Hospital-Data-Warehouse
Building a modern hospital management warehouse using SQL Server, including ETL processes, data modeling, and analytics.

![Hospital DWH Architecture](https://github.com/user-attachments/assets/02570c33-ae46-437f-ace8-627aeb9b8ce8)


This project implements the medalion architecture in developing the ETL pipeline:
## a. Bronze Layer: 
* Staging tables were created to store raw patient data straight from each data source
* Historical tables were created to keep a record of patient data in the event of future change.
* An ETL Log table was created to track changes. This table is visible only to the Data Engineer.

  
## b. Silver Layer:
* UPSERT was used to combine new data with the schemas in the warehouse to ensure that Data Analysts and other authorised professionals can access the most recent data.
* Initial cleaning was carried out in this stage.
  

## c. Gold Layer:
* Comprehensive preprocessing of the data to prepare it for analysis.
* The proper designations were given to the dimension (dim_tablename) and fact (fact_tablename) tables.
* The data is now ready for Ad hoc analyses, BI reporting, and querying by Analysts, Engineers, and Business-level end-users.
  
![Hospital Data Integration Model](https://github.com/user-attachments/assets/009ecf98-ac67-4a4a-a6d4-523398d034f0)


The final deliverable is a hospital data model with one-to-many relationships from the dimension tables to the fact tables. End-users can safely query the data, analyze, and implement BI reports using the data without having to clean excet where feature engineering is necessary for specific analysis requirements.
![Hospital Data Model](https://github.com/user-attachments/assets/4196aaca-a8fa-4a5c-b9cf-40d366c9dbed)
