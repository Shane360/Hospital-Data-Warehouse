/*===============================================================================
CREATE AUDIT LOG TABLE FOR THE BRONZE LAYER LOADS
================================================================================*/

IF OBJECT_ID ('bronze.etl_log', 'U')IS NOT NULL
	DROP TABLE bronze.etl_log;
CREATE TABLE bronze.etl_log (
	log_id INT IDENTITY(1,1) PRIMARY KEY,
	table_name NVARCHAR(100),
	batch_id NVARCHAR(50),
	rows_inserted INT,
	rows_updated INT,
	load_status NVARCHAR(50),
	load_date DATETIME DEFAULT GETDATE(),
	file_name NVARCHAR(255)
);
