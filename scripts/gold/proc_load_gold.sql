/*
------------------------------------------------------------------------
LOADING INTO THE GOLD LAYER
------------------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
			DECLARE @batch_start_time DATETIME2,
					@batch_end_time DATETIME2,
					@start_time DATETIME2,
					@end_time DATETIME2,
					@load_name NVARCHAR(100),
					@rows_updated INT;

			SET @batch_start_time = SYSUTCDATETIME();

			-- Gold Patients
			PRINT '=====================================================================';
			PRINT '----------- Load from silver.patients into the Gold layer -----------';
			SET @start_time = SYSUTCDATETIME();
			SET @load_name = 'gold.dim_patients';

			INSERT INTO etl.metadata_load_log (load_name, start_time, status)
			VALUES (@load_name, @start_time, 'Started');

			BEGIN TRY
			IF OBJECT_ID ('gold.dim_patients', 'U') IS NOT NULL
				DELETE FROM gold.dim_patients;
			INSERT INTO gold.dim_patients(
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
				email
			)
			SELECT
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
				email
			FROM silver.patients;
	
			SET @end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Load complete into gold.patients >>>>>>>>';
			PRINT 'Total load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '=================================================================';

			INSERT INTO etl.metadata_load_log(load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, @end_time, 'Success', NULL);
		END TRY 
		BEGIN CATCH
			INSERT INTO etl.metadata_load_log (load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, GETDATE(), 'Failed', ERROR_MESSAGE());
			THROW;
		END CATCH;

			-- Gold Doctors
			PRINT '----------- Load from silver.doctors into gold layer ------------';
			SET @start_time = SYSUTCDATETIME();
			SET @load_name = 'gold.dim_doctors';
			
			INSERT INTO etl.metadata_load_log (load_name, start_time, status)
			VALUES (@load_name, @start_time, 'Started');

			BEGIN TRY
			IF OBJECT_ID ('gold.dim_doctors', 'U') IS NOT NULL
				DELETE FROM gold.dim_doctors;
			INSERT INTO gold.dim_doctors (
				doctor_id,
				first_name,
				last_name,
				specialization,
				phone_number,
				years_experience,
				hospital_branch,
				email
			)
			SELECT
				doctor_id,
				first_name,
				last_name,
				specialization,
				phone_number,
				years_experience,
				hospital_branch,
				email
			FROM silver.doctors;

			SET @end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Load complete into gold.doctors >>>>>>>>';
			PRINT 'Total load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '=================================================================';
			
			INSERT INTO etl.metadata_load_log(load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, @end_time, 'Success', NULL);
		END TRY 
		BEGIN CATCH
			INSERT INTO etl.metadata_load_log (load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, GETDATE(), 'Failed', ERROR_MESSAGE());
			THROW;
		END CATCH;

			-- Gold Appointments	
			PRINT '----------- Load from silver.appointments into gold layer ------------';
			SET @start_time = SYSUTCDATETIME();
			SET @load_name = 'gold.fact_appointments';

			INSERT INTO etl.metadata_load_log (load_name, start_time, status)
			VALUES (@load_name, @start_time, 'Started');

			BEGIN TRY
			IF OBJECT_ID ('gold.fact_appointments', 'U') IS NOT NULL
				DELETE FROM gold.fact_appointments;
			INSERT INTO gold.fact_appointments (
				appointment_id,
				patient_id,
				doctor_id,
				appointment_date,
				appointment_time,
				reason_for_visit,
				status
			)
			SELECT
				appointment_id,
				patient_id,
				doctor_id,
				appointment_date,
				CAST(appointment_time AS TIME(0)) AS appointment_time,
				reason_for_visit,
				status
			FROM silver.appointments;

			SET @end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Load complete into gold.appointments >>>>>>>>';
			PRINT 'Total load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '=================================================================';


			INSERT INTO etl.metadata_load_log(load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, @end_time, 'Success', NULL);
		END TRY 
		BEGIN CATCH
			INSERT INTO etl.metadata_load_log (load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, GETDATE(), 'Failed', ERROR_MESSAGE());
			THROW;
		END CATCH;

			-- Gold Treatments
			PRINT '----------- Load from silver.treatments into gold layer ------------';
			SET @start_time = SYSUTCDATETIME();
			SET @load_name = 'gold.fact_treatment';

			INSERT INTO etl.metadata_load_log (load_name, start_time, status)
			VALUES (@load_name, @start_time, 'Started');

			BEGIN TRY
			IF OBJECT_ID ('gold.fact_treatments', 'U') IS NOT NULL
				DELETE FROM gold.fact_treatments;
			INSERT INTO gold.fact_treatments (
				treatment_id,
				appointment_id,
				treatment_type,
				description,
				cost,
				treatment_date
			)
			SELECT 
				treatment_id,
				appointment_id,
				treatment_type,
				description,
				cost,
				treatment_date
			FROM silver.treatments;
	
			SET @end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Load complete into gold.treatments >>>>>>>>';
			PRINT 'Total load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '=================================================================';

			INSERT INTO etl.metadata_load_log(load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, @end_time, 'Success', NULL);
		END TRY 
		BEGIN CATCH
			INSERT INTO etl.metadata_load_log (load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, GETDATE(), 'Failed', ERROR_MESSAGE());
			THROW;
		END CATCH;

			-- Gold Billing
			PRINT '----------- Load from silver.billing into gold layer ------------';
			SET @start_time = SYSUTCDATETIME();
			SET @load_name = 'gold.fact_billing';

			INSERT INTO etl.metadata_load_log (load_name, start_time, status)
			VALUES (@load_name, @start_time, 'Started');

			BEGIN TRY
			IF OBJECT_ID ('gold.fact_billing', 'U') IS NOT NULL
				DELETE FROM gold.fact_billing;
			INSERT INTO gold.fact_billing (
				bill_id,
				patient_id,
				treatment_id,
				bill_date,
				amount,
				payment_method,
				payment_status
			)
			SELECT
				bill_id,
				patient_id,
				treatment_id,
				bill_date,
				amount,
				payment_method,
				payment_status
			FROM silver.billing;
	
			SET @end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Load complete into gold.billing >>>>>>>>';
			PRINT 'Total load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '=================================================================';

			INSERT INTO etl.metadata_load_log(load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, @end_time, 'Success', NULL);
		END TRY 
		BEGIN CATCH
			INSERT INTO etl.metadata_load_log (load_name, start_time, end_time, status, error_message)
			VALUES (@load_name, @start_time, GETDATE(), 'Failed', ERROR_MESSAGE());
			THROW;
		END CATCH;

			SET @batch_end_time = SYSUTCDATETIME();
			PRINT '>>>>>>>>> Gold Layer Load Complete >>>>>>>>>>>>>>>>>';
			PRINT 'Total Load time: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
			PRINT '>>>>>>>>> >>>>>>>>>>> >>>>>>>>>>> >>>>>>>>>>>>>>>>>';
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			PRINT '=================================================================';
			PRINT 'THERE WAS AN ERROR IN LOADING';
			PRINT 'Error Message: ' + ERROR_MESSAGE();
			PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
			PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
			PRINT '=================================================================';
			THROW;
			RETURN;
		END;
	END CATCH;

END;
