CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_batch_time DATETIME = GETDATE(),
            @end_batch_time   DATETIME,
            @start_time       DATETIME,
            @end_time         DATETIME;

    BEGIN TRY
		SET @start_batch_time = GETDATE();
        ------------------------------------------------------------
        -- 1) DIMENSION - 
		--    a. Patients
        ------------------------------------------------------------
        PRINT '>>> MERGE silver.patients';
		SET @start_time = GETDATE();
        ;MERGE INTO silver.patients AS T
        USING bronze.patients AS S
            ON T.patient_id = S.patient_id
        WHEN MATCHED AND (
            ISNULL(T.gender,'') <> ISNULL(
                CASE WHEN TRIM(S.gender) = 'M' THEN 'Male'
                     WHEN TRIM(S.gender) = 'F' THEN 'Female'
                     ELSE 'N/A' END, ''
            )
            OR ISNULL(T.contact_number,'') <> ISNULL(TRIM(S.contact_number),'')
            OR ISNULL(T.address,'') <> ISNULL(TRIM(S.address),'')
            OR ISNULL(T.insurance_provider,'') <> ISNULL(TRIM(S.insurance_provider),'')
            OR ISNULL(T.insurance_number,'') <> ISNULL(TRIM(S.insurance_number),'')
        )
        THEN
            UPDATE SET
                T.gender = CASE WHEN TRIM(S.gender) = 'M' THEN 'Male'
                                WHEN TRIM(S.gender) = 'F' THEN 'Female'
                                ELSE 'N/A' END,
                T.contact_number = TRIM(S.contact_number),
                T.address = TRIM(S.address),
                T.insurance_provider = TRIM(S.insurance_provider),
                T.insurance_number = TRIM(S.insurance_number),
                T.updated_at = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                patient_id, first_name, last_name, gender,
                date_of_birth, contact_number, address, registration_date,
                insurance_provider, insurance_number, email,
                created_at, updated_at
            )
            VALUES (
                TRIM(S.patient_id),
                TRIM(S.first_name),
                TRIM(S.last_name),
                CASE WHEN TRIM(S.gender) = 'M' THEN 'Male'
                     WHEN TRIM(S.gender) = 'F' THEN 'Female'
                     ELSE 'N/A' END,
                S.date_of_birth,
                TRIM(S.contact_number),
                TRIM(S.address),
                S.registration_date,
                TRIM(S.insurance_provider),
                TRIM(S.insurance_number),
                TRIM(S.email),
                GETDATE(),
                GETDATE()
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE
        ; 
        PRINT '>>> silver.patients MERGE complete';

		SET @end_time = GETDATE();
		PRINT 'Patients Load time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds.'

        ------------------------------------------------------------
        -- b. DIMENSION - Doctors
        ------------------------------------------------------------
        SET @start_time = GETDATE();
		PRINT '>>> MERGE silver.doctors';
        ;MERGE INTO silver.doctors AS T
        USING bronze.doctors AS S
            ON T.doctor_id = S.doctor_id
        WHEN MATCHED AND (
            ISNULL(T.phone_number,'') <> ISNULL(TRIM(S.phone_number),'')
            OR ISNULL(T.years_experience,-1) <> ISNULL(S.years_experience,-1)
            OR ISNULL(T.hospital_branch,'') <> ISNULL(TRIM(S.hospital_branch),'')
        )
        THEN
            UPDATE SET
                T.phone_number = TRIM(S.phone_number),
                T.years_experience = S.years_experience,
                T.hospital_branch = TRIM(S.hospital_branch),
                T.updated_at = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                doctor_id, first_name, last_name, specialization,
                phone_number, years_experience, hospital_branch, email,
                created_at, updated_at
            )
            VALUES (
                TRIM(S.doctor_id),
                TRIM(S.first_name),
                TRIM(S.last_name),
                TRIM(S.specialization),
                TRIM(S.phone_number),
                S.years_experience,
                TRIM(S.hospital_branch),
                TRIM(S.email),
                GETDATE(),
                GETDATE()
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE
        ;
        PRINT '>>> silver.doctors MERGE complete';
		SET @end_time = GETDATE();

		PRINT 'Doctors Load Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds.'

        ------------------------------------------------------------
        -- 2) FACTS - Clear & reload (FK-safe)
        -- Delete children first: billing -> treatments -> appointments
        -- Then insert parents then children: appointments -> treatments -> billing
        ------------------------------------------------------------

        -- a) Delete child facts first to avoid FK errors
        PRINT '>>> Deleting child facts (billing -> treatments -> appointments if needed)';
        DELETE FROM silver.billing;
        DELETE FROM silver.treatments;
        DELETE FROM silver.appointments;

        ------------------------------------------------------------
        -- b) Insert appointments (parents for treatments)
        ------------------------------------------------------------
        PRINT '>>> Inserting into silver.appointments';
        INSERT INTO silver.appointments (
            appointment_id, patient_id, doctor_id,
            appointment_date, appointment_time,
            reason_for_visit, status, created_at
        )
        SELECT
            TRIM(appointment_id),
            TRIM(patient_id),
            TRIM(doctor_id),
            appointment_date,
            CAST(appointment_time AS TIME(0)),
            reason_for_visit,
            status,
            GETDATE()
        FROM bronze.appointments;
        PRINT '>>> silver.appointments loaded';

        ------------------------------------------------------------
        -- c) Insert treatments (child of appointments)
        ------------------------------------------------------------
        PRINT '>>> Inserting into silver.treatments';
        INSERT INTO silver.treatments (
            treatment_id, appointment_id, treatment_type,
            description, cost, treatment_date, created_at
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
        PRINT '>>> silver.treatments loaded';

        ------------------------------------------------------------
        -- d) Insert billing (child of treatments & patients)
        ------------------------------------------------------------
        PRINT '>>> Inserting into silver.billing';
        INSERT INTO silver.billing (
            bill_id, patient_id, treatment_id,
            bill_date, amount, payment_method, payment_status, created_at
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
        PRINT '>>> silver.billing loaded';

        ------------------------------------------------------------
        -- Wrap up
        ------------------------------------------------------------
        SET @end_batch_time = GETDATE();
        PRINT '>>> Bronze -> Silver load complete';
        PRINT 'Total time (s): ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50));

    END TRY

    BEGIN CATCH
        PRINT 'xxxxx ERROR during silver.load_silver xxxxx';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        THROW; 
    END CATCH
END;
