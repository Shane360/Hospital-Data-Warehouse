
/*=======================================================================================
	CREATE STAGING LOAD STORED PROCEDURE - To run a Full load from CSV files into staging tables
========================================================================================*/


CREATE OR ALTER PROCEDURE bronze.staging_load
AS 
BEGIN
	DECLARE @batch_start_time DATETIME,
			@batch_end_time DATETIME,
			@start_time DATETIME,
			@end_time DATETIME

	SET @batch_start_time = GETDATE();
	BEGIN TRY
		---------------------------------------------------------
		-- Appointments (Stage)
		---------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---------------- Loading raw data from CSV into bronze.stage_appointments -----------------';

		IF OBJECT_ID ('bronze.stage_appointments','U') IS NOT NULL
			TRUNCATE TABLE bronze.stage_appointments;

		BULK INSERT bronze.stage_appointments
		FROM 'C:\Datasets\appointments.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---------------- Load into bronze.stage_appointments completed ------------------------------';
		PRINT '>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

	
		---------------------------------------------------------
		-- Billing (Stage)
		---------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---------------- Loading raw data from CSV into bronze.stage_billing ------------------------';

		IF OBJECT_ID ('bronze.stage_billing', 'U') IS NOT NULL
			TRUNCATE TABLE bronze.stage_billing;

		BULK INSERT bronze.stage_billing
		FROM 'C:\Datasets\billing.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		)
		SET @end_time = GETDATE();
		PRINT '---------------- Load into bronze.stage_billing completed ------------------------------------';
		PRINT '>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		---------------------------------------------------------
		-- Doctors (Stage)
		---------------------------------------------------------

		SET @start_time = GETDATE();
		PRINT '---------------- Loading raw data from CSV into bronze.stage_doctors ------------------------';

		IF OBJECT_ID ('bronze.stage_doctors', 'U') IS NOT NULL
			TRUNCATE TABLE bronze.stage_doctors;

		BULK INSERT bronze.stage_doctors
		FROM 'C:\Datasets\doctors.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---------------- Load into bronze.stage_doctors completed -----------------------------------------';
		PRINT '>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


		---------------------------------------------------------
		-- Patients (Stage)
		---------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---------------- Loading raw data from CSV into bronze.stage_patients ------------------------';
		IF OBJECT_ID ('bronze.stage_patients', 'U') IS NOT NULL
		TRUNCATE TABLE bronze.stage_patients;

		BULK INSERT bronze.stage_patients
		FROM 'C:\Datasets\patients.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---------------- Load into bronze.stage_patients completed -----------------------------------------';
		PRINT '>>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


		---------------------------------------------------------
		-- Treatments (Stage)
		---------------------------------------------------------
		SET @start_time = GETDATE();
		PRINT '---------------- Loading raw data from CSV into bronze.stage_treatments -----------------------';
		IF OBJECT_ID ('bronze.stage_treatments', 'U') IS NOT NULL
		TRUNCATE TABLE bronze.stage_treatments;

		BULK INSERT bronze.stage_treatments
		FROM 'C:\Datasets\treatments.csv'
			WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '---------------- Load into bronze.stage_treatments completed ------------------------------------------';
		PRINT '>>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @batch_end_time = GETDATE();

		PRINT '---------------- Load into ALL staging tables completed ---------------------------------------';
		PRINT '>>>>>>>> Total Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	END TRY

	BEGIN CATCH
		PRINT '======================================================';
		PRINT 'AN ERROR OCCURRED DURING THE LOAD'
		PRINT 'Error: ' + ERROR_MESSAGE();
		PRINT 'Error Code: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Status: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '======================================================';
		THROW;
	END CATCH
END;

