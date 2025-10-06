/*
========================================================
DDL SCRIPT - Create Silver layer tables
========================================================
Purpose:
	These scripts create tables for the silver layer
	dropping them if they already exist.

-------------------------------------------------------
*/




-- Create Silver tables
-- Doctors
IF OBJECT_ID ('silver.doctors', 'U') IS NOT NULL
	DROP TABLE silver.doctors;
CREATE TABLE silver.doctors (
	doctor_sk INT IDENTITY (1,1) PRIMARY KEY,
	doctor_id NVARCHAR(50) NOT NULL UNIQUE,
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	specialization NVARCHAR(50),
	phone_number NVARCHAR(25),
	years_experience INT,
	hospital_branch NVARCHAR(50),
	email NVARCHAR(100),
	created_at DATETIME DEFAULT GETDATE(),
	updated_at DATETIME
);


-- Patients
IF OBJECT_ID  ('silver.patients', 'U') IS NOT NULL
	DROP TABLE silver.patients;
CREATE TABLE silver.patients (
	patient_sk INT IDENTITY(1,1) PRIMARY KEY,
	patient_id NVARCHAR(50) NOT NULL UNIQUE,
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
	created_at DATETIME DEFAULT GETDATE(),
	updated_at DATETIME
);



-- Appointments
IF OBJECT_ID ('silver.appointments', 'U') IS NOT NULL
	DROP TABLE silver.appointments;
CREATE TABLE silver.appointments (
	appointment_sk INT IDENTITY(1,1) PRIMARY KEY,
	appointment_id NVARCHAR(50) NOT NULL UNIQUE,
	patient_id NVARCHAR(50),
	doctor_id NVARCHAR(50),
	appointment_date DATE,
	appointment_time TIME,
	reason_for_visit NVARCHAR(255),
	status NVARCHAR(50),
	created_at DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (patient_id) REFERENCES silver.patients(patient_id),
	FOREIGN KEY (doctor_id) REFERENCES silver.doctors(doctor_id)
);


-- Billing
IF OBJECT_ID ('silver.billing', 'U') IS NOT NULL
	DROP TABLE silver.billing;
CREATE TABLE silver.billing (
	bill_sk INT IDENTITY(1,1) PRIMARY KEY,
	bill_id NVARCHAR(50) NOT NULL UNIQUE,
	patient_id NVARCHAR(50),
	treatment_id NVARCHAR(50),
	bill_date DATE,
	amount DECIMAL(10,2),
	payment_method NVARCHAR(50),
	payment_status NVARCHAR(50),
	created_at DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (patient_id) REFERENCES silver.patients(patient_id)
);


-- Treatments
IF OBJECT_ID ('silver.treatments', 'U') IS NOT NULL
	DROP TABLE silver.treatments;
CREATE TABLE silver.treatments (
	treatment_sk INT IDENTITY(1,1) PRIMARY KEY,
	treatment_id NVARCHAR(50) NOT NULL UNIQUE,
	appointment_id NVARCHAR(50),
	treatment_type NVARCHAR(100),
	description NVARCHAR(255),
	cost DECIMAL(10,2),
	treatment_date DATE,
	created_at DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (appointment_id) REFERENCES silver.appointments(appointment_id)
);
