
/*
=====================================================================================================
CREATE HISTORICAL TABLE STORED PROCEDURE: To load data from staging tables into Historical tables
=====================================================================================================*/

CREATE OR ALTER PROCEDURE bronze.full_load
AS
BEGIN
	DECLARE @batch_id NVARCHAR(50),
			@batch_start_time DATETIME,
			@batch_end_time DATETIME,
			@start_time DATETIME,
			@end_time DATETIME
	
	PRINT '------------ Loading data from Staging Tables to Historical Tables ----------------------';
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	-- ----------------------------------------------------
	-- Appointments: from staging to historical table
	-- ----------------------------------------------------
	SET @start_time = GETDATE();
	SET @batch_id = CAST(NEWID() AS NVARCHAR(50));
	PRINT '------------ Loading data from bronze.stage_appointments to bronze.appointments ----------';


		MERGE bronze.appointments AS target
	USING bronze.stage_appointments AS source
		ON target.appointment_id = source.appointment_id
		AND target.is_current = 1
	WHEN MATCHED AND (
			target.doctor_id <> source.doctor_id
		OR	target.patient_id <> source.patient_id
		OR	target.appointment_date <> source.appointment_date
	)
	THEN
		UPDATE SET target.valid_to = GETDATE(),
					target.is_current = 0
	
	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, status,
				valid_from, valid_to, is_current, load_date, batch_id)
		VALUES (source.appointment_id, source.patient_id, source.doctor_id, source.appointment_date, source.appointment_time,
				source.reason_for_visit, source.status, GETDATE(), NULL, 1, GETDATE(), @batch_id);


	SET @end_time = GETDATE();
	PRINT '----------------- Load into bronze.appointments completed ----------------------------'
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time)AS NVARCHAR) + ' seconds'


	-- ----------------------------------------------------
	-- Billing: from staging to historical table
	-- ----------------------------------------------------
	SET @start_time = GETDATE();
	SET @batch_id = CAST(NEWID() AS NVARCHAR(50));
	PRINT '------------ Loading data from bronze.stage_billing to bronze.billing ----------';

	MERGE bronze.billing as target
	USING bronze.stage_billing as source
		ON target.bill_id = source.bill_id
		AND target.is_current = 1
	WHEN MATCHED AND (
			target.patient_id <> source.patient_id
		OR	target.bill_date <> source.bill_date
		)
	THEN
		UPDATE SET target.valid_to = GETDATE(),
					target.is_current = 0

	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (bill_id, patient_id, treatment_id, bill_date, amount, payment_method, payment_status,
				valid_from, valid_to, is_current, load_date, batch_id)

		VALUES (source.bill_id, source.patient_id, source.treatment_id, source.bill_date, source.amount, source.payment_method,
				source.payment_status, GETDATE(), NULL, 1, GETDATE(), @batch_id);


	SET @end_time = GETDATE();
	PRINT '-------------- Load into bronze.billing completed --------------------------------';
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

	   

	-- ----------------------------------------------------
	-- Doctors: from staging to historical table
	-- ----------------------------------------------------
	SET @start_time = GETDATE();
	SET @batch_id = CAST(NEWID() AS NVARCHAR(50));
	PRINT '------------ Loading data from bronze.stage_doctors to bronze.doctors ----------';

	MERGE bronze.doctors as target
	USING bronze.stage_doctors as source
		ON target.doctor_id = source.doctor_id
		AND target.is_current = 1
	WHEN MATCHED AND (
		target.first_name <> source.first_name
		OR target.last_name <> source.last_name
		OR target.specialization <> source.specialization
		)
	THEN 
		UPDATE SET target.valid_to = GETDATE(),
					target.is_current = 0

	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (doctor_id, first_name, last_name, specialization, phone_number, years_experience, hospital_branch,
				email, valid_from, valid_to, is_current, load_date, batch_id)
		VALUES (source.doctor_id, source.first_name, source.last_name, source.specialization, source.phone_number, 
				source.years_experience, source.hospital_branch, source.email, GETDATE(), NULL, 1, GETDATE(), @batch_id);


	SET @end_time = GETDATE();
	PRINT '-------------- Load into bronze.doctors completed --------------------------------';
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';



	-- ----------------------------------------------------
	-- Patients: from staging to historical table
	-- ----------------------------------------------------
	SET @start_time = GETDATE();
	SET @batch_id = CAST(NEWID() AS NVARCHAR(50));
	PRINT '------------ Loading data from bronze.stage_patients to bronze.patients ----------';

	MERGE bronze.patients as target
	USING bronze.stage_patients as source
		ON target.patient_id = source.patient_id
		AND target.is_current = 1
	
	WHEN MATCHED AND(
			target.first_name <> source.first_name
		OR	target.last_name <> source.last_name
		OR	target.date_of_birth <> source.date_of_birth
		)

	THEN 
		UPDATE SET target.valid_to = GETDATE(),
					target.is_current = 0

	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (patient_id, first_name, last_name, gender, date_of_birth, contact_number, address, registration_date, 
		insurance_provider, insurance_number, email, valid_from, valid_to, is_current, load_date, batch_id)
		VALUES (source.patient_id, source.first_name, source.last_name, source.gender, source.date_of_birth, source.contact_number, 
				source.address, source.registration_date, source.insurance_provider, source.insurance_number, source.email,
				GETDATE(), NULL, 1, GETDATE(), @batch_id);

	SET @end_time = GETDATE();
	PRINT '-------------- Load into bronze.patients completed --------------------------------';
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		

	-- ----------------------------------------------------
	-- Treatments: from staging to historical table
	-- ----------------------------------------------------
	SET @start_time = GETDATE();
	SET @batch_id = CAST(NEWID() AS NVARCHAR(50));
	PRINT '------------ Loading data from bronze.stage_treatments to bronze.treatments ----------';


	MERGE bronze.treatments as target
	USING bronze.stage_treatments as source
		ON target.treatment_id = source.treatment_id
		AND target.is_current = 1
		
	WHEN MATCHED AND (
			target.appointment_id <> source.appointment_id
		OR	target.description <> source.description
		OR	target.treatment_date <> source.treatment_date
		)
	THEN
		UPDATE SET target.valid_to = GETDATE(),
					target.is_current = 0

	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (treatment_id, appointment_id, treatment_type, description, cost, treatment_date,
				valid_from, valid_to, is_current, load_date, batch_id)
		VALUES (source.treatment_id, source.appointment_id, source.treatment_type, source.description, source.cost, 
				source.treatment_date, GETDATE(), NULL, 1, GETDATE(), @batch_id);
	
	SET @end_time = GETDATE();
	PRINT '-------------- Load into bronze.treatments completed --------------------------------';
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	
	SET @batch_end_time = GETDATE();
	PRINT '>>>>>>> Load into ALL Historical tables completed --------------------------------';
	PRINT '>>>>>>> Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT '====================================================================================';
		PRINT 'Error Message: ' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Code:' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '====================================================================================';
		THROW
	END CATCH
END
