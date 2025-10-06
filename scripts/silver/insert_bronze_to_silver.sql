/*
========================================================
INSERT FROM BRONZE TO SILVER  - Create Silver layer tables
========================================================
Purpose:
	These scripts clean data from the bronze layer and 
	insert them into the silver layer.

-------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_batch_time DATETIME,
		@end_batch_time DATETIME,
		@start_time DATETIME,
		@end_time DATETIME;

	SET @start_batch_time = GETDATE();

	BEGIN TRY
	PRINT '----------- UPSERT into the silver.patients table -----------------';
	PRINT '-------- Inserting from bronze.patients to silver.patients --------';
	;MERGE silver.patients as T
	USING bronze.patients as S
		ON T.patient_id = S.patient_id
	
	WHEN MATCHED AND 
		(T.gender <> S.gender OR
		T.contact_number <> S.contact_number OR
		T.address <> S.address OR
		T.insurance_provider <> S.insurance_provider OR
		T.insurance_number <> S.insurance_number)
	THEN	
	UPDATE
	SET
		T.gender = S.gender,
		T.contact_number = S.contact_number,
		T.address = S.address,
		T.insurance_provider = S.insurance_provider,
		T.insurance_number = S.insurance_number,
		T.updated_at = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (
		patient_id,
		first_name,
		last_name,
		gender,
		date_of_birth,
		contact_number,
		address,
		registration_date,
		insurance_provider,
		insurance_number,
		email,
		created_at,
		updated_at
	)

	VALUES (
		TRIM(patient_id),
		TRIM(first_name),
		TRIM(last_name),
		CASE
			WHEN TRIM(gender) = 'M' THEN 'Male'
			WHEN TRIM(gender) = 'F' THEN 'Female'
			ELSE gender
		END,
		date_of_birth,
		TRIM(contact_number),
		TRIM(address),
		registration_date,
		TRIM(insurance_provider),
		TRIM(insurance_number),
		TRIM(email),
		GETDATE(),
		GETDATE())
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	SET @end_time = GETDATE();
	PRINT '--------------- Insert into silver.patients complete ---------------';

	
	-- Doctors
	PRINT '--------------- Loading from bronze.doctors ----------------------------';
	SET @start_time = GETDATE();
	PRINT '-------- Inserting from bronze.doctors to silver.doctors --------';

	;MERGE silver.doctors AS T
	USING bronze.doctors AS S
		ON T.doctor_id = S.doctor_id
	WHEN MATCHED AND (T.phone_number <> S.phone_number
		OR T.years_experience <> S.years_experience
		OR T.hospital_branch <> S.hospital_branch)
	THEN
	UPDATE 
	SET T.phone_number = S.phone_number,
		T.years_experience = S.years_experience,
		T.hospital_branch = S.hospital_branch,
		T.updated_at = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		doctor_id,
		first_name,
		last_name,
		specialization,
		phone_number,
		years_experience,
		hospital_branch,
		email,
		created_at,
		updated_at
		)
	VALUES ( 
		TRIM(doctor_id),
		TRIM(first_name),
		TRIM(last_name),
		TRIM(specialization),
		phone_number,
		years_experience,
		TRIM(hospital_branch),
		TRIM(email),
		GETDATE(),
		GETDATE()
	)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	SET @end_time = GETDATE();
	PRINT '--------------- Insert into silver.doctors complete ---------------';
	



	-- Appointments
	PRINT '--------------- Loading from bronze.appointments ----------------------------';
	SET @start_time = GETDATE();
	PRINT '----------- Truncating the silver.appointments table -----------------';
	TRUNCATE TABLE silver.appointments;
	PRINT '-------- Inserting from bronze.appointments to silver.appointments --------';
	INSERT INTO silver.appointments(
		appointment_id,
		patient_id,
		doctor_id,
		appointment_date,
		appointment_time,
		reason_for_visit,
		status,
		created_at
	)
	-- Data cleaning and transformation
	SELECT 
		TRIM(ba.appointment_id),
		TRIM(ba.patient_id),
		TRIM(ba.doctor_id),
		ba.appointment_date,
		CAST(ba.appointment_time AS TIME(0)),
		ba.reason_for_visit,
		ba.status,
		GETDATE()
	FROM bronze.appointments ba;

	SET @end_time = GETDATE();
	
	PRINT '--------------- Insert into silver.appointments complete ---------------';
	

	-- Billing
	PRINT '--------------- Loading from bronze.billing ----------------------------';
	SET @start_time = GETDATE();
	PRINT '--------------- Truncate silver.billing --------------------------------';
	TRUNCATE TABLE silver.billing;
	INSERT INTO silver.billing (
		bill_id,
		patient_id,
		treatment_id,
		bill_date,
		amount,
		payment_method,
		payment_status,
		created_at
	)
	SELECT
		TRIM(bill_id),
		TRIM(patient_id),
		TRIM(treatment_id),
		bill_date,
		amount,
		TRIM(payment_method),
		TRIM(payment_status),
		GETDATE()
	FROM bronze.billing;
	SET @end_time = GETDATE();
	
	PRINT '--------------- Insert into silver.billing complete ---------------';
	

	-- Treatments
	PRINT '--------------- Loading from bronze.treatments ----------------------------';
	SET @start_time = GETDATE();
	PRINT '--------------- Truncate silver.treatments --------------------------------';
	TRUNCATE TABLE silver.treatments;
	INSERT INTO silver.treatments (
		treatment_id,
		appointment_id,
		treatment_type,
		description,
		cost,
		treatment_date,
		created_at
	)
	SELECT
		TRIM(treatment_id),
		TRIM(appointment_id),
		TRIM(treatment_type),
		TRIM(description),
		cost,
		treatment_date,
		GETDATE()
	FROM bronze.treatments;
	
	SET @end_time = GETDATE();
	
	PRINT '--------------- Insert into silver.treatments complete ---------------';

	SET @end_batch_time = GETDATE();
	
	PRINT '--------------- Insert From bronze to silver layer complete ---------------';
	PRINT 'Total Insert time is: ' + CAST(DATEDIFF(second, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';

	END TRY

	BEGIN CATCH
		PRINT 'xxxxx An Error occurred when inserting from bronze to silver layer complete xxxxx';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
		PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
		PRINT 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
	THROW;
	END CATCH
END;

