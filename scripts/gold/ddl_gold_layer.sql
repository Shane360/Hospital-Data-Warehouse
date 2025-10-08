-- ---------------------------------------------
-- DDL for the Gold Layer
-- ---------------------------------------------

IF OBJECT_ID('gold.dim_patients', 'U') IS NOT NULL
	DROP TABLE gold.dim_patients;
CREATE TABLE gold.dim_patients (
	patient_sk INT IDENTITY (1, 1) PRIMARY KEY,
	patient_id NVARCHAR(50) NOT NULL UNIQUE,
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	gender NVARCHAR(10),
	date_of_birth DATE,
	contact_number NVARCHAR(25),
	address NVARCHAR(50),
	registration_date DATE,
	insurance_provider NVARCHAR(50),
	insurance_number NVARCHAR(50),
	email NVARCHAR(100),
	created_at DATETIME2 DEFAULT SYSDATETIME(),
	updated_at DATETIME2 DEFAULT SYSDATETIME()
);


IF OBJECT_ID('gold.dim_doctors', 'U') IS NOT NULL
	DROP TABLE gold.dim_doctors;
CREATE TABLE gold.dim_doctors (
	doctor_sk INT IDENTITY(1,1) PRIMARY KEY,
	doctor_id NVARCHAR(50) NOT NULL UNIQUE,
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	specialization NVARCHAR(50),
	phone_number NVARCHAR(50),
	years_of_experience INT,
	hospital_branch NVARCHAR(50),
	email NVARCHAR(100),
	created_at DATETIME2 DEFAULT SYSDATETIME(),
	updated_at DATETIME2 DEFAULT SYSDATETIME()
);


IF OBJECT_ID('gold.fact_appointments', 'U') IS NOT NULL
	DROP TABLE gold.fact_appointments;
CREATE TABLE gold.fact_appointments (
	appointment_sk INT IDENTITY(1,1) PRIMARY KEY,
	appointment_id NVARCHAR(50) NOT NULL UNIQUE,
	patient_id NVARCHAR(50),
	doctor_id NVARCHAR(50), 
	appointment_date DATE,
	appointment_time TIME(0),
	reason_for_visit NVARCHAR(50),
	status NVARCHAR(50),
	created_at DATETIME2 DEFAULT SYSDATETIME(),
	updated_at DATETIME2 DEFAULT SYSDATETIME(),
	FOREIGN KEY (patient_id) REFERENCES gold.dim_patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (doctor_id) REFERENCES gold.dim_doctors(doctor_id)
);

IF OBJECT_ID('gold.fact_treatments', 'U') IS NOT NULL
	DROP TABLE gold.fact_treatments;
CREATE TABLE gold.fact_treatments (
	treatment_sk INT IDENTITY(1,1) PRIMARY KEY,
	treatment_id NVARCHAR(50) NOT NULL UNIQUE,
	appointment_id NVARCHAR(50),
	treatment_type NVARCHAR(100),
	description NVARCHAR(255),
	cost DECIMAL(10,2),
	treatment_date DATE,
	created_at DATETIME2 DEFAULT SYSDATETIME(),
	updated_at DATETIME2 DEFAULT SYSDATETIME(),
	FOREIGN KEY (appointment_id) REFERENCES gold.fact_appointments(appointment_id)
);

IF OBJECT_ID('gold.fact_billing', 'U') IS NOT NULL
	DROP TABLE gold.fact_billing;
CREATE TABLE gold.fact_billing (
	bill_sk INT IDENTITY(1,1) PRIMARY KEY,
	bill_id NVARCHAR(50) NOT NULL UNIQUE,
	patient_id NVARCHAR(50),
	treatment_id NVARCHAR(50),
	bill_date DATE,
	amount DECIMAL(10,2),
	payment_method NVARCHAR(50),
	payment_status NVARCHAR(50),
	created_at DATETIME2 DEFAULT SYSDATETIME(),
	updated_at DATETIME2 DEFAULT SYSDATETIME(),
	FOREIGN KEY (patient_id) REFERENCES gold.dim_patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (treatment_id) REFERENCES gold.fact_treatments(treatment_id)
);
