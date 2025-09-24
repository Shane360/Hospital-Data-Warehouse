
-- -------------------------------------------------------------------------------
-- Historical tables: to capture new data from the staging and retain old data
-- -------------------------------------------------------------------------------
-- Appointments
IF OBJECT_ID ('bronze.appointments', 'U') IS NOT NULL
	DROP TABLE bronze.appointments;
CREATE TABLE bronze.appointments (
	appointment_id NVARCHAR(50),
	patient_id NVARCHAR(50),
	doctor_id NVARCHAR(50),
	appointment_date DATE,
	appointment_time TIME,
	reason_for_visit NVARCHAR(255),
	status NVARCHAR(50),
	-- SCD2 audit columns
	valid_from DATETIME DEFAULT GETDATE(),
	valid_to DATETIME NULL,
	is_current BIT DEFAULT 1,
	load_date DATETIME DEFAULT GETDATE(),  -- This makes tracking for Audit purposes easier
	batch_id NVARCHAR(50) -- ETL traceability
);


-- Billing
IF OBJECT_ID ('bronze.billing', 'U') IS NOT NULL
	DROP TABLE bronze.billing;
CREATE TABLE bronze.billing (
	bill_id NVARCHAR(50),
	patient_id NVARCHAR(50),
	treatment_id NVARCHAR(50),
	bill_date DATE,
	amount DECIMAL(10,2),
	payment_method NVARCHAR(50),
	payment_status NVARCHAR(50),
	valid_from DATETIME DEFAULT GETDATE(),
	valid_to DATETIME NULL,
	is_current BIT DEFAULT 1,
	load_date DATETIME DEFAULT GETDATE(),
	batch_id NVARCHAR(50)
);



-- Doctors
IF OBJECT_ID ('bronze.doctors', 'U') IS NOT NULL
	DROP TABLE bronze.doctors;
CREATE TABLE bronze.doctors (
	doctor_id NVARCHAR(50),
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	specialization NVARCHAR(50),
	phone_number NVARCHAR(25),
	years_experience INT,
	hospital_branch NVARCHAR(50),
	email NVARCHAR(100),
	valid_from DATETIME DEFAULT GETDATE(),
	valid_to DATETIME NULL,
	is_current BIT DEFAULT 1,
	load_date DATETIME DEFAULT GETDATE(),
	batch_id NVARCHAR(50)
);


-- Patients
IF OBJECT_ID  ('bronze.patients', 'U') IS NOT NULL
	DROP TABLE bronze.patients
CREATE TABLE bronze.patients (
	patient_id NVARCHAR(50),
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	gender NVARCHAR(10),
	date_of_birth DATE,
	contact_number NVARCHAR(25),
	address NVARCHAR(255),
	registration_date DATE,
	insurance_provider NVARCHAR(50),
	insurance_number NVARCHAR(50),
	email NVARCHAR(100),
	valid_from DATETIME DEFAULT GETDATE(),
	valid_to DATETIME NULL,
	is_current BIT DEFAULT 1,
	load_date DATETIME DEFAULT GETDATE(),
	batch_id NVARCHAR(50)
);


-- Treatments

IF OBJECT_ID ('bronze.treatments', 'U') IS NOT NULL
	DROP TABLE bronze.treatments;
CREATE TABLE bronze.treatments (
	treatment_id NVARCHAR(50),
	appointment_id NVARCHAR(50),
	treatment_type NVARCHAR(100),
	description NVARCHAR(255),
	cost DECIMAL(10,2),
	treatment_date DATE,
	valid_from DATETIME DEFAULT GETDATE(),
	valid_to DATETIME NULL,
	is_current BIT DEFAULT 1,
	load_date DATETIME DEFAULT GETDATE(),
	batch_id NVARCHAR(50)
);


