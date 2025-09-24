
/*
=================================================================================
CREATE STAGING TABLES - FOR FULL LOAD
=================================================================================*/

-- bronze.stage_appointments
IF OBJECT_ID ('bronze.stage_appointments', 'U') IS NULL
CREATE TABLE bronze.stage_appointments (
	appointment_id NVARCHAR(50),
	patient_id NVARCHAR(50),
	doctor_id NVARCHAR(50),
	appointment_date DATE,
	appointment_time TIME,
	reason_for_visit NVARCHAR(255),
	status NVARCHAR(50)
);


-- bronze.stage_billing
IF OBJECT_ID ('bronze.stage_billing', 'U') IS NULL
CREATE TABLE bronze.stage_billing (
	bill_id NVARCHAR(50),
	patient_id NVARCHAR(50),
	treatment_id NVARCHAR(50),
	bill_date DATE,
	amount DECIMAL(10,2),
	payment_method NVARCHAR(50),
	payment_status NVARCHAR(50)
);


-- bronze.stage_doctors
IF OBJECT_ID ('bronze.stage_doctors', 'U') IS NULL
CREATE TABLE bronze.stage_doctors (
	doctor_id NVARCHAR(50),
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	specialization NVARCHAR(50),
	phone_number NVARCHAR(25),
	years_experience INT,
	hospital_branch NVARCHAR(50),
	email NVARCHAR(100)
);


-- bronze.stage_patients
IF OBJECT_ID ('bronze.stage_patients', 'U') IS NULL
CREATE TABLE bronze.stage_patients (
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
	email NVARCHAR(100)
);


-- bronze.stage_treatments
IF OBJECT_ID ('bronze.stage_treatments' , 'U') IS NULL
CREATE TABLE bronze.stage_treatments (
	treatment_id NVARCHAR(50),
	appointment_id NVARCHAR(50),
	treatment_type NVARCHAR(100),
	description NVARCHAR(255),
	cost DECIMAL(10,2),
	treatment_date DATE
);

