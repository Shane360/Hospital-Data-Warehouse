-- ==============================================================================================
-- Create Centralized ETL load log table
-- ==============================================================================================
-- Purpose:
--  For Audit and to track load metadata for all tables in each layer
-- ----------------------------------------------------------------------------------------------

-- DDL for ETL Log Table
IF OBJECT_ID ('etl.metadata_load_log', 'U') IS NOT NULL
	DROP TABLE etl.metadata_load_log;
CREATE TABLE etl.metadata_load_log (
	log_id INT IDENTITY(1,1) PRIMARY KEY,
	load_name NVARCHAR(255) NOT NULL,
	target_table NVARCHAR(255) NOT NULL,
	start_time DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
	end_time DATETIME2(3) NULL,
	duration_seconds AS DATEDIFF(SECOND, start_time, end_time) PERSISTED, -- auto-calculated
	status NVARCHAR(50) NOT NULL DEFAULT 'Started',
	rows_inserted INT NULL,
	rows_updated INT NULL,
	rows_deleted INT NULL,
	error_message NVARCHAR(MAX) NULL,
	created_at DATETIME2(3) DEFAULT SYSUTCDATETIME(),
	updated_at DATETIME2(3) NULL
);




-- STORED PROCEDURE FOR ETL Table
-- This automates the load into the ETL log table

CREATE OR ALTER PROCEDURE etl.log_metadata_event
	@load_name NVARCHAR(255),
	@target_table NVARCHAR(255),
	@status NVARCHAR(50),
	@rows_inserted INT = NULL,
	@rows_updated INT = NULL,
	@rows_deleted INT = NULL,
	@error_message NVARCHAR(MAX) = NULL,
	@log_id INT OUTPUT
AS
BEGIN
	DECLARE @existing_log_id INT;

	SELECT TOP 1 @existing_log_id = log_id
	FROM etl.metadata_load_log
	WHERE load_name = @load_name
		AND target_table = @target_table
		AND status = 'Started'
	ORDER BY start_time DESC;

	IF @status = 'Started'
	BEGIN
		INSERT INTO etl.metadata_load_log(load_name, target_table, start_time, status)
		VALUES (@load_name, @target_table, SYSUTCDATETIME(), 'Started');

		SET @log_id = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN -- When status = 'Succeeded' pr 'Failed' : Update existing record
		UPDATE etl.metadata_load_log
		SET 
			end_time = SYSUTCDATETIME(),
			updated_at = SYSUTCDATETIME(),
			status = @status,
			rows_inserted = @rows_inserted,
			rows_updated = @rows_updated,
			rows_deleted = @rows_deleted,
			error_message = @error_message
		WHERE log_id = @log_id;
	END
END;


