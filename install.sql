-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;

SET
    @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS,
    FOREIGN_KEY_CHECKS = 0;

SET
    @OLD_SQL_MODE = @@SQL_MODE,
    SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Schema mydb
-- DROP SCHEMA IF EXISTS `mydb`;
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;

USE `mydb`;

-- Table `mydb`.`PERSONNEL`
DROP TABLE IF EXISTS `mydb`.`PERSONNEL`;

CREATE TABLE IF NOT EXISTS `mydb`.`PERSONNEL` (
    `AMKA` CHAR(11) NOT NULL,
    `name` VARCHAR(45) NOT NULL,
    `surname` VARCHAR(45) NOT NULL,
    `age` INT NOT NULL CHECK (age >= 18 AND age <= 100),
    `email` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `hire_date` DATE NOT NULL,
    `personnel_type` VARCHAR(30) NOT NULL CHECK (personnel_type IN ( 'Doctor', 'Nurse', 'Administrative_Staff' )),
    PRIMARY KEY (`AMKA`),
    UNIQUE INDEX `email_UNIQUE` (`email` ASC),
    CONSTRAINT `chk_personnel_amka_format` CHECK (AMKA REGEXP '^[0-9]{11}$'),
    CONSTRAINT `chk_pesonnel_phone_format` CHECK (phone REGEXP '^[0-9+][0-9 -]{9,}$'),
    CONSTRAINT `chk_personnel_email_format` CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
) ENGINE = InnoDB;

-- Table `mydb`.`DOCTOR`
DROP TABLE IF EXISTS `mydb`.`DOCTOR`;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR` (
    `license_number` VARCHAR(30) NOT NULL,
    `specialty` VARCHAR(50) NOT NULL,
    `Grade` VARCHAR(30) NOT NULL CHECK (Grade IN ( 'Intern', 'Supervisor B', 'Supervisor A', 'Director' )),
    `PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Supervisor_AMKA` CHAR(11) NULL,
    PRIMARY KEY (`PERSONNEL_AMKA`),
    INDEX `Supervisor_AMKA_idx` (`Supervisor_AMKA` ASC),
    UNIQUE INDEX `license_number_UNIQUE` (`license_number` ASC),
    CONSTRAINT `fk_DOCTOR_PERSONNEL` FOREIGN KEY (`PERSONNEL_AMKA`) REFERENCES `mydb`.`PERSONNEL` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `Supervisor_AMKA` FOREIGN KEY (`Supervisor_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_doctor_license_number_format` CHECK (license_number REGEXP '^[A-Za-z0-9]+$'),
    CONSTRAINT `chk_doctor_supervisor_self` CHECK (PERSONNEL_AMKA <> Supervisor_AMKA OR Supervisor_AMKA IS NULL),
    CONSTRAINT `chk_doctor_inter_supervisor` CHECK (Grade != 'Intern' OR Supervisor_AMKA IS NOT NULL),
    CONSTRAINT `chk_doctor_director_no_supervisor` CHECK (Grade != 'Director' OR Supervisor_AMKA IS NULL)
) ENGINE = InnoDB;

-- Table `mydb`.`Department`
DROP TABLE IF EXISTS `mydb`.`Department`;

CREATE TABLE IF NOT EXISTS `mydb`.`Department` (
    `num_of_beds` INT NOT NULL,
    `building` VARCHAR(45) NOT NULL,
    `level` VARCHAR(45) NOT NULL,
    `dept_id` VARCHAR(45) NOT NULL,
    `Director_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`dept_id`),
    INDEX `fk_Department_DOCTOR1_idx` (`Director_AMKA` ASC),
    UNIQUE INDEX `Director_AMKA_UNIQUE` (`Director_AMKA` ASC),
    CONSTRAINT `Director_AMKA` FOREIGN KEY (`Director_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_department_beds_available` CHECK (num_of_beds > 0),
    CONSTRAINT `chk_department_name_not_empty` CHECK (dept_id != '')
) ENGINE = InnoDB;

-- Table `mydb`.`Nurse`
DROP TABLE IF EXISTS `mydb`.`Nurse`;

CREATE TABLE IF NOT EXISTS `mydb`.`Nurse` (
    `Grade` VARCHAR(30) NOT NULL,
    `PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`PERSONNEL_AMKA`),
    INDEX `fk_Nurse_Department1_idx` (`Department_dept_id` ASC),
    CONSTRAINT `fk_Nurse_PERSONNEL1` FOREIGN KEY (`PERSONNEL_AMKA`) REFERENCES `mydb`.`PERSONNEL` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Nurse_Department1` FOREIGN KEY (`Department_dept_id`) REFERENCES `mydb`.`Department` (`dept_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_nurse_grade` CHECK (Grade IN ( 'Nurse Assistant', 'Nurse', 'Supervisor Nurse' ))
) ENGINE = InnoDB;

-- Table `mydb`.`Administrative_Staff`
DROP TABLE IF EXISTS `mydb`.`Administrative_Staff`;

CREATE TABLE IF NOT EXISTS `mydb`.`Administrative_Staff` (
    `duties` VARCHAR(30) NOT NULL,
    `PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`PERSONNEL_AMKA`),
    INDEX `fk_Administrative_Staff_Department1_idx` (`Department_dept_id` ASC),
    CONSTRAINT `fk_Administrative_Staff_PERSONNEL1` FOREIGN KEY (`PERSONNEL_AMKA`) REFERENCES `mydb`.`PERSONNEL` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Administrative_Staff_Department1` FOREIGN KEY (`Department_dept_id`) REFERENCES `mydb`.`Department` (`dept_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`DOCTOR_has_Department`
DROP TABLE IF EXISTS `mydb`.`DOCTOR_has_Department`;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR_has_Department` (
    `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`DOCTOR_PERSONNEL_AMKA`, `Department_dept_id`),
    INDEX `fk_DOCTOR_has_Department_Department1_idx` (`Department_dept_id` ASC),
    INDEX `fk_DOCTOR_has_Department_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_DOCTOR_has_Department_DOCTOR1` FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_DOCTOR_has_Department_Department1` FOREIGN KEY (`Department_dept_id`) REFERENCES `mydb`.`Department` (`dept_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`BEDS`
DROP TABLE IF EXISTS `mydb`.`BEDS`;

CREATE TABLE IF NOT EXISTS `mydb`.`BEDS` (
    `bed_id` INT NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(45) NOT NULL,
    `status` VARCHAR(45) NOT NULL,
    `Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`bed_id`, `Department_dept_id`),
    INDEX `fk_BEDS_Department1_idx` (`Department_dept_id` ASC),
    CONSTRAINT `fk_BEDS_Department1` FOREIGN KEY (`Department_dept_id`) REFERENCES `mydb`.`Department` (`dept_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_bed_status` CHECK (status IN ( 'Available', 'Occupied', 'Maintenance' ))
) ENGINE = InnoDB;

-- Table `mydb`.`Patient`
DROP TABLE IF EXISTS `mydb`.`Patient`;

CREATE TABLE IF NOT EXISTS `mydb`.`Patient` (
    `AMKA` CHAR(11) NOT NULL,
    `first_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    `father_name` VARCHAR(45) NOT NULL,
    `age` INT NOT NULL,
    `gender` VARCHAR(45) NOT NULL,
    `weight` DECIMAL(5, 2) NULL,
    `height` DECIMAL(3, 2) NULL,
    `address` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(45) NOT NULL,
    `email` VARCHAR(100) NULL,
    `profession` VARCHAR(45) NOT NULL,
    `nationality` VARCHAR(45) NOT NULL,
    `insurance_type` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`AMKA`),
    UNIQUE INDEX `AMKA_UNIQUE` (`AMKA` ASC),
    CONSTRAINT `chk_patient_age` CHECK (age >= 0 AND age <= 180),
    CONSTRAINT `chk_patient_gender` CHECK (gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT `chk_patient_weight` CHECK (weight IS NULL OR weight > 0),
    CONSTRAINT `chk_patient_height` CHECK (height IS NULL OR height > 0),
    CONSTRAINT `chk_patient_phone_format` CHECK (phone REGEXP '^[0-9+][0-9 -]{9,}$'),
    CONSTRAINT `chk_patient_email_format` CHECK (
        email IS NULL
        OR email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT `chk_patient_amka_format` CHECK (AMKA REGEXP '^[0-9]{11}$'),
    CONSTRAINT `chk_patient_insurance_type` CHECK (insurance_type IN ('EFKA', 'Private', 'None'))
) ENGINE = InnoDB;

-- Table `mydb`.`Emergency_Contact`
DROP TABLE IF EXISTS `mydb`.`Emergency_Contact`;

CREATE TABLE IF NOT EXISTS `mydb`.`Emergency_Contact` (
    `contact_id` INT NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    `phone` VARCHAR(45) NOT NULL,
    `relationship` VARCHAR(45) NOT NULL,
    `Patient_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`contact_id`, `Patient_AMKA`),
    INDEX `fk_Emergency_Contact_Patient1_idx` (`Patient_AMKA` ASC),
    CONSTRAINT `fk_Emergency_Contact_Patient1` FOREIGN KEY (`Patient_AMKA`) REFERENCES `mydb`.`Patient` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_emergency_contact_phone_format` CHECK (phone REGEXP '^[0-9+][0-9 -]{9,}$')
) ENGINE = InnoDB;

-- Table `mydb`.`Shift`
DROP TABLE IF EXISTS `mydb`.`Shift`;

CREATE TABLE IF NOT EXISTS `mydb`.`Shift` (
    `shift_type` VARCHAR(45) NOT NULL,
    `date` DATE NOT NULL,
    `Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`shift_type`, `date`, `Department_dept_id`),
    INDEX `fk_Shift_Department1_idx` (`Department_dept_id` ASC),
    CONSTRAINT `fk_Shift_Department1` FOREIGN KEY (`Department_dept_id`) REFERENCES `mydb`.`Department` (`dept_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_shift_type` CHECK (shift_type IN ( 'Morning', 'Afternoon', 'Night' ))
) ENGINE = InnoDB;

-- Table `mydb`.`ICD-10`
DROP TABLE IF EXISTS `mydb`.`ICD-10`;

CREATE TABLE IF NOT EXISTS `mydb`.`ICD-10` (
    `ICD-10` VARCHAR(10) NOT NULL,
    `Description` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`ICD-10`),
    UNIQUE INDEX `ICD-10_UNIQUE` (`ICD-10` ASC)
) ENGINE = InnoDB;

-- Table `mydb`.`KEN`
DROP TABLE IF EXISTS `mydb`.`KEN`;

CREATE TABLE IF NOT EXISTS `mydb`.`KEN` (
    `ken_code` VARCHAR(10) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `base_cost` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(10) NOT NULL,
    `avg_stay_days` INT NOT NULL,
    `extra_day_rate` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`ken_code`),
    CONSTRAINT `chk_ken_base_cost` CHECK (base_cost >= 0),
    CONSTRAINT `chk_ken_avg_stay_days` CHECK (avg_stay_days > 0),
    CONSTRAINT `chk_ken_extra_day_rate` CHECK (extra_day_rate >= 0)
) ENGINE = InnoDB;

-- Table `mydb`.`Hospitalization`
DROP TABLE IF EXISTS `mydb`.`Hospitalization`;

CREATE TABLE IF NOT EXISTS `mydb`.`Hospitalization` (
    `hosp_id` INT NOT NULL AUTO_INCREMENT,
    `entry_date` DATETIME NOT NULL,
    `exit_date` DATETIME NULL,
    `total_cost` DECIMAL(10, 2) NULL,
    `BEDS_bed_id` INT NOT NULL,
    `BEDS_Department_dept_id` VARCHAR(45) NOT NULL,
    `Patient_AMKA` CHAR(11) NOT NULL,
    `ICD-10_in` VARCHAR(10) NOT NULL,
    `ICD-10_out` VARCHAR(10) NULL,
    `KEN_ken_code` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`hosp_id`),
    INDEX `fk_Hospitalization_BEDS1_idx` (`BEDS_bed_id` ASC, `BEDS_Department_dept_id` ASC),
    INDEX `fk_Hospitalization_Patient1_idx` (`Patient_AMKA` ASC),
    INDEX `fk_Hospitalization_ICD-101_idx` (`ICD-10_in` ASC),
    INDEX `fk_Hospitalization_ICD-102_idx` (`ICD-10_out` ASC),
    INDEX `fk_Hospitalization_KEN1_idx` (`KEN_ken_code` ASC),
    CONSTRAINT `fk_Hospitalization_BEDS1` FOREIGN KEY (
        `BEDS_bed_id`,
        `BEDS_Department_dept_id`
    ) REFERENCES `mydb`.`BEDS` (
        `bed_id`,
        `Department_dept_id`
    ) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Hospitalization_Patient1` FOREIGN KEY (`Patient_AMKA`) REFERENCES `mydb`.`Patient` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Hospitalization_ICD-101` FOREIGN KEY (`ICD-10_in`) REFERENCES `mydb`.`ICD-10` (`ICD-10`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Hospitalization_ICD-102` FOREIGN KEY (`ICD-10_out`) REFERENCES `mydb`.`ICD-10` (`ICD-10`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Hospitalization_KEN1` FOREIGN KEY (`KEN_ken_code`) REFERENCES `mydb`.`KEN` (`ken_code`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_hospitalization_dates` CHECK (exit_date > entry_date),
    CONSTRAINT `chk_hospitalization_total_cost` CHECK (total_cost >= 0 OR total_cost IS NULL)
) ENGINE = InnoDB;

-- Table `mydb`.`Triage`
DROP TABLE IF EXISTS `mydb`.`Triage`;

CREATE TABLE IF NOT EXISTS `mydb`.`Triage` (
    `triage_id` INT NOT NULL AUTO_INCREMENT,
    `arrival_time` DATETIME NOT NULL,
    `symptoms` VARCHAR(45) NOT NULL,
    `urgency_level` INT NOT NULL,
    `Nurse_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Hospitalization_hosp_id` INT NULL,
    `Patient_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`triage_id`),
    INDEX `fk_Triage_Nurse1_idx` (`Nurse_PERSONNEL_AMKA` ASC),
    INDEX `fk_Triage_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
    INDEX `fk_Triage_Patient1_idx` (`Patient_AMKA` ASC),
    CONSTRAINT `fk_Triage_Nurse1` FOREIGN KEY (`Nurse_PERSONNEL_AMKA`) REFERENCES `mydb`.`Nurse` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Triage_Hospitalization1` FOREIGN KEY (`Hospitalization_hosp_id`) REFERENCES `mydb`.`Hospitalization` (`hosp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Triage_Patient1` FOREIGN KEY (`Patient_AMKA`) REFERENCES `mydb`.`Patient` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_triage_urgency_level` CHECK (urgency_level >= 1 AND urgency_level <= 5)
) ENGINE = InnoDB;

-- Table `mydb`.`LAB_EXAMS`
DROP TABLE IF EXISTS `mydb`.`LAB_EXAMS`;

CREATE TABLE IF NOT EXISTS `mydb`.`LAB_EXAMS` (
    `exam_id` INT NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(45) NOT NULL,
    `date` DATE NOT NULL,
    `result` VARCHAR(45) NOT NULL,
    `unit` VARCHAR(45) NOT NULL,
    `cost` INT NOT NULL,
    `Hospitalization_hosp_id` INT NOT NULL,
    `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`exam_id`),
    INDEX `fk_LAB_EXAMS_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
    INDEX `fk_LAB_EXAMS_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_LAB_EXAMS_Hospitalization1` FOREIGN KEY (`Hospitalization_hosp_id`) REFERENCES `mydb`.`Hospitalization` (`hosp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_LAB_EXAMS_DOCTOR1` FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_lab_exams_cost` CHECK (cost >= 0)
) ENGINE = InnoDB;

-- Table `mydb`.`ROOM`
DROP TABLE IF EXISTS `mydb`.`ROOM`;

CREATE TABLE IF NOT EXISTS `mydb`.`ROOM` (
    `room_id` INT NOT NULL AUTO_INCREMENT,
    `room_type` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`room_id`)
) ENGINE = InnoDB;

-- Table `mydb`.`Medical_Procedures`
DROP TABLE IF EXISTS `mydb`.`Medical_Procedures`;

CREATE TABLE IF NOT EXISTS `mydb`.`Medical_Procedures` (
    `procedure_id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `category` VARCHAR(45) NOT NULL,
    `duration` INT NOT NULL,
    `cost` DECIMAL(10, 2) NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NOT NULL,
    `ROOM_room_id` INT NOT NULL,
    `DocInCharge_id` CHAR(11) NOT NULL,
    `Hospitalization_hosp_id` INT NOT NULL,
    PRIMARY KEY (`procedure_id`),
    INDEX `fk_Medical_Procedures_ROOM1_idx` (`ROOM_room_id` ASC),
    INDEX `fk_Medical_Procedures_DOCTOR1_idx` (`DocInCharge_id` ASC),
    INDEX `fk_Medical_Procedures_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
    CONSTRAINT `fk_Medical_Procedures_ROOM1` FOREIGN KEY (`ROOM_room_id`) REFERENCES `mydb`.`ROOM` (`room_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Medical_Procedures_DOCTOR1` FOREIGN KEY (`DocInCharge_id`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Medical_Procedures_Hospitalization1` FOREIGN KEY (`Hospitalization_hosp_id`) REFERENCES `mydb`.`Hospitalization` (`hosp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_medical_procedures_duration` CHECK (duration > 0),
    CONSTRAINT `chk_medical_procedures_cost` CHECK (cost >= 0),
    CONSTRAINT `chk_medical_procedures_time` CHECK (end_time > start_time),
    CONSTRAINT `chk_medical_procedures_category` CHECK (category IN ( 'Surgery', 'Therapy', 'Diagnostic' ))
) ENGINE = InnoDB;

-- Table `mydb`.`Procedure_Team`
DROP TABLE IF EXISTS `mydb`.`Procedure_Team`;

CREATE TABLE IF NOT EXISTS `mydb`.`Procedure_Team` (
    `Medical_Procedures_procedure_id` INT NOT NULL,
    `PERSONNEL_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`Medical_Procedures_procedure_id`, `PERSONNEL_AMKA`),
    INDEX `fk_Procedure_Team_PERSONNEL1_idx` (`PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_Procedure_Team_Medical_Procedures1` FOREIGN KEY (
        `Medical_Procedures_procedure_id`
    ) REFERENCES `mydb`.`Medical_Procedures` (`procedure_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Procedure_Team_PERSONNEL1` FOREIGN KEY (`PERSONNEL_AMKA`) REFERENCES `mydb`.`PERSONNEL` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`DRUG`
DROP TABLE IF EXISTS `mydb`.`DRUG`;

CREATE TABLE IF NOT EXISTS `mydb`.`DRUG` (
    `drug_id` INT NOT NULL AUTO_INCREMENT,
    `product_name` VARCHAR(255) NOT NULL,
    `route_of_admin` VARCHAR(100) NOT NULL,
    `auth_country` VARCHAR(100) NOT NULL,
    `auth_holder` VARCHAR(255) NOT NULL,
    `master_file_loc` VARCHAR(255) NOT NULL,
    `phv_email` VARCHAR(100) NOT NULL,
    `phv_phone` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`drug_id`),
    CONSTRAINT `chk_drug_phv_email_format` CHECK (phv_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT `chk_drug_phv_phone_format` CHECK (phv_phone REGEXP '^[0-9+][0-9 -]{9,}$')
) ENGINE = InnoDB;

-- Table `mydb`.`Active_Substance`
DROP TABLE IF EXISTS `mydb`.`Active_Substance`;

CREATE TABLE IF NOT EXISTS `mydb`.`Active_Substance` (
    `substance_id` INT NOT NULL AUTO_INCREMENT,
    `substance_name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`substance_id`)
) ENGINE = InnoDB;

-- Table `mydb`.`DRUG_has_Active_Substance`
DROP TABLE IF EXISTS `mydb`.`DRUG_has_Active_Substance`;

CREATE TABLE IF NOT EXISTS `mydb`.`DRUG_has_Active_Substance` (
    `DRUG_drug_id` INT NOT NULL,
    `Active_Substance_substance_id` INT NOT NULL,
    PRIMARY KEY (`DRUG_drug_id`, `Active_Substance_substance_id`),
    INDEX `fk_DRUG_has_Active_Substance_Active_Substance1_idx` (`Active_Substance_substance_id` ASC),
    INDEX `fk_DRUG_has_Active_Substance_DRUG1_idx` (`DRUG_drug_id` ASC),
    CONSTRAINT `fk_DRUG_has_Active_Substance_DRUG1` FOREIGN KEY (`DRUG_drug_id`) REFERENCES `mydb`.`DRUG` (`drug_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_DRUG_has_Active_Substance_Active_Substance1` FOREIGN KEY (
        `Active_Substance_substance_id`
    ) REFERENCES `mydb`.`Active_Substance` (`substance_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`Patient_Allergy`
DROP TABLE IF EXISTS `mydb`.`Patient_Allergy`;

CREATE TABLE IF NOT EXISTS `mydb`.`Patient_Allergy` (
    `Patient_AMKA` CHAR(11) NOT NULL,
    `Active_Substance_substance_id` INT NOT NULL,
    PRIMARY KEY (`Patient_AMKA`, `Active_Substance_substance_id`),
    INDEX `fk_Patient_Allergy_Active_Substance1_idx` (`Active_Substance_substance_id` ASC),
    CONSTRAINT `fk_Patient_Allergy_Patient1` FOREIGN KEY (`Patient_AMKA`) REFERENCES `mydb`.`Patient` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Patient_Allergy_Active_Substance1` FOREIGN KEY (
        `Active_Substance_substance_id`
    ) REFERENCES `mydb`.`Active_Substance` (`substance_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`Perscription`
DROP TABLE IF EXISTS `mydb`.`Perscription`;

CREATE TABLE IF NOT EXISTS `mydb`.`Perscription` (
    `PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Patient_AMKA` CHAR(11) NOT NULL,
    `DRUG_drug_id` INT NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `dosage` VARCHAR(45) NOT NULL,
    `frequency` VARCHAR(45) NOT NULL,
    `Hospitalization_hosp_id` INT NOT NULL,
    PRIMARY KEY (`PERSONNEL_AMKA`, `Patient_AMKA`, `DRUG_drug_id`, `start_date`),
    INDEX `fk_Perscription_Patient1_idx` (`Patient_AMKA` ASC),
    INDEX `fk_Perscription_DRUG1_idx` (`DRUG_drug_id` ASC),
    INDEX `fk_Perscription_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
    CONSTRAINT `fk_Perscription_PERSONNEL1` FOREIGN KEY (`PERSONNEL_AMKA`) REFERENCES `mydb`.`PERSONNEL` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Perscription_Patient1` FOREIGN KEY (`Patient_AMKA`) REFERENCES `mydb`.`Patient` (`AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Perscription_DRUG1` FOREIGN KEY (`DRUG_drug_id`) REFERENCES `mydb`.`DRUG` (`drug_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Perscription_Hospitalization1` FOREIGN KEY (`Hospitalization_hosp_id`) REFERENCES `mydb`.`Hospitalization` (`hosp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_perscription_dates` CHECK (end_date >= start_date)
) ENGINE = InnoDB;

-- Table `mydb`.`DOCTOR_has_Shift`
DROP TABLE IF EXISTS `mydb`.`DOCTOR_has_Shift`;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR_has_Shift` (
    `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Shift_shift_type` VARCHAR(45) NOT NULL,
    `Shift_date` DATE NOT NULL,
    `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`DOCTOR_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
    INDEX `fk_DOCTOR_has_Shift_Shift1_idx` (`Shift_shift_type` ASC, `Shift_date` ASC, `Shift_Department_dept_id` ASC),
    INDEX `fk_DOCTOR_has_Shift_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_DOCTOR_has_Shift_DOCTOR1` FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_DOCTOR_has_Shift_Shift1` FOREIGN KEY (
        `Shift_shift_type`,
        `Shift_date`,
        `Shift_Department_dept_id`
    ) REFERENCES `mydb`.`Shift` (
        `shift_type`,
        `date`,
        `Department_dept_id`
    ) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`Administrative_Staff_has_Shift`
DROP TABLE IF EXISTS `mydb`.`Administrative_Staff_has_Shift`;

CREATE TABLE IF NOT EXISTS `mydb`.`Administrative_Staff_has_Shift` (
    `Administrative_Staff_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Shift_shift_type` VARCHAR(45) NOT NULL,
    `Shift_date` DATE NOT NULL,
    `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`Administrative_Staff_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
    INDEX `fk_Administrative_Staff_has_Shift_Shift1_idx` (
        `Shift_shift_type` ASC,
        `Shift_date` ASC,
        `Shift_Department_dept_id` ASC
    ),
    INDEX `fk_Administrative_Staff_has_Shift_Administrative_Staff1_idx` (`Administrative_Staff_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_Administrative_Staff_has_Shift_Administrative_Staff1` FOREIGN KEY (
        `Administrative_Staff_PERSONNEL_AMKA`
    ) REFERENCES `mydb`.`Administrative_Staff` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Administrative_Staff_has_Shift_Shift1` FOREIGN KEY (
        `Shift_shift_type`,
        `Shift_date`,
        `Shift_Department_dept_id`
    ) REFERENCES `mydb`.`Shift` (
        `shift_type`,
        `date`,
        `Department_dept_id`
    ) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`Nurse_has_Shift`
DROP TABLE IF EXISTS `mydb`.`Nurse_has_Shift`;

CREATE TABLE IF NOT EXISTS `mydb`.`Nurse_has_Shift` (
    `Nurse_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    `Shift_shift_type` VARCHAR(45) NOT NULL,
    `Shift_date` DATE NOT NULL,
    `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`Nurse_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
    INDEX `fk_Nurse_has_Shift_Shift1_idx` (`Shift_shift_type` ASC, `Shift_date` ASC, `Shift_Department_dept_id` ASC),
    INDEX `fk_Nurse_has_Shift_Nurse1_idx` (`Nurse_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_Nurse_has_Shift_Nurse1` FOREIGN KEY (`Nurse_PERSONNEL_AMKA`) REFERENCES `mydb`.`Nurse` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_Nurse_has_Shift_Shift1` FOREIGN KEY (
        `Shift_shift_type`,
        `Shift_date`,
        `Shift_Department_dept_id`
    ) REFERENCES `mydb`.`Shift` (
        `shift_type`,
        `date`,
        `Department_dept_id`
    ) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- Table `mydb`.`Evaluation`
DROP TABLE IF EXISTS `mydb`.`Evaluation`;

CREATE TABLE IF NOT EXISTS `mydb`.`Evaluation` (
    `eval_id` INT NOT NULL AUTO_INCREMENT,
    `nursing_care` INT NOT NULL CHECK (nursing_care BETWEEN 1 AND 5),
    `Clean` INT NOT NULL CHECK (Clean BETWEEN 1 AND 5),
    `Food` INT NOT NULL CHECK (Food BETWEEN 1 AND 5),
    `TotalExperience` INT NOT NULL CHECK (TotalExperience BETWEEN 1 AND 5),
    `Hospitalization_hosp_id` INT NOT NULL,
    PRIMARY KEY (`eval_id`),
    INDEX `fk_Evaluation_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
    UNIQUE INDEX `Hospitalization_hosp_id_UNIQUE` (`Hospitalization_hosp_id` ASC),
    CONSTRAINT `fk_Evaluation_Hospitalization1` FOREIGN KEY (`Hospitalization_hosp_id`) REFERENCES `mydb`.`Hospitalization` (`hosp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_evaluation_nursing_care` CHECK (nursing_care >= 1 AND nursing_care <= 5),
    CONSTRAINT `chk_evaluation_clean` CHECK (Clean >= 1 AND Clean <= 5),
    CONSTRAINT `chk_evaluation_food` CHECK (Food >= 1 AND Food <= 5),
    CONSTRAINT `chk_evaluation_total_experience` CHECK (TotalExperience >= 1 AND TotalExperience <= 5)
) ENGINE = InnoDB;

-- Table `mydb`.`DoctorEvaluation`
DROP TABLE IF EXISTS `mydb`.`DoctorEvaluation`;

CREATE TABLE IF NOT EXISTS `mydb`.`DoctorEvaluation` (
    `MedCareQuality` INT NOT NULL,
    `eval_id` INT NOT NULL,
    `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`eval_id`, `DOCTOR_PERSONNEL_AMKA`),
    INDEX `fk_DoctorEvaluation_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
    CONSTRAINT `fk_DoctorEvaluation_Evaluation1` FOREIGN KEY (`eval_id`) REFERENCES `mydb`.`Evaluation` (`eval_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_DoctorEvaluation_DOCTOR1` FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`) REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `chk_doctor_evaluation_med_care_quality` CHECK (MedCareQuality >= 1 AND MedCareQuality <= 5)
) ENGINE = InnoDB;

SET SQL_MODE = @OLD_SQL_MODE;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;

SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;

DELIMITER //

DELIMITER ;

DROP TRIGGER IF EXISTS `patient_is_allergic`;

DELIMITER //

CREATE Trigger `patient_is_allergic` BEFORE INSERT ON `Perscription` FOR EACH ROW
BEGIN
  DECLARE is_allergic INT;

  SELECT Count(*) INTO is_allergic
  FROM `Patient_Allergy` pa
  JOIN `DRUG_has_Active_Substance` DAS ON pa.Active_Substance_substance_id = DAS.Active_Substance_substance_id
  WHERE pa.Patient_AMKA = NEW.Patient_AMKA
  AND DAS.DRUG_drug_id = NEW.DRUG_drug_id;

  IF is_allergic > 0 
  THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Patient is allergic to this medication';
  END IF;
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `supervisor_invalid`;

DELIMITER //

CREATE Trigger `supervisor_invalid` BEFORE INSERT ON `DOCTOR` FOR EACH ROW
BEGIN
  DECLARE is_invalid INT;

  SELECT Count(*) INTO is_invalid
  FROM `DOCTOR` d1 
  WHERE d1.PERSONNEL_AMKA = NEW.Supervisor_AMKA
  AND d1.Supervisor_AMKA = NEW.PERSONNEL_AMKA;

  IF is_invalid > 0 
  THEN
   SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Doctor supervisor is invalid';
  END IF; 
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `shift_not_enough_doc`;

DELIMITER //

CREATE Trigger `shift_not_enough_doc` BEFORE DELETE ON `DOCTOR_has_Shift` FOR EACH ROW
BEGIN
  DECLARE number_of_doc INT;

  SELECT Count(*) INTO number_of_doc
  FROM `DOCTOR_has_Shift` shift
  WHERE shift.Shift_shift_type = OLD.Shift_shift_type
  AND shift.Shift_date = OLD.Shift_date
  AND shift.Shift_Department_dept_id = OLD.Shift_Department_dept_id;

  IF number_of_doc  <= 3
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Shift will not have enough doctors';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `shift_not_enough_nurse`;

DELIMITER //

CREATE Trigger `shift_not_enough_nurse` BEFORE DELETE ON `Nurse_has_Shift` FOR EACH ROW
BEGIN
  DECLARE number_of_nurse INT;

  SELECT Count(*) INTO number_of_nurse
  FROM `Nurse_has_Shift` shift
  WHERE shift.Shift_shift_type = OLD.Shift_shift_type
  AND shift.Shift_date = OLD.Shift_date
  AND shift.Shift_Department_dept_id = OLD.Shift_Department_dept_id;

  IF number_of_nurse  <= 6
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Shift will not have enough nurses';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `shift_not_enough_adm`;

DELIMITER //

CREATE Trigger `shift_not_enough_adm` BEFORE DELETE ON `Administrative_Staff_has_Shift` FOR EACH ROW
BEGIN
  DECLARE number_of_adm INT;

  SELECT Count(*) INTO number_of_adm
  FROM `Administrative_Staff_has_Shift` shift
  WHERE shift.Shift_shift_type = OLD.Shift_shift_type
  AND shift.Shift_date = OLD.Shift_date
  AND shift.Shift_Department_dept_id = OLD.Shift_Department_dept_id;

  IF number_of_adm  <= 2
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Shift will not have enough administrative staff';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `intern_shift`;

DELIMITER //

CREATE Trigger `intern_shift` BEFORE INSERT ON `DOCTOR_has_Shift` FOR EACH ROW
BEGIN
  DECLARE high_rank_doc INT DEFAULT 0;
  DECLARE is_intern INT DEFAULT 0;

  SELECT Count(*) INTO is_intern
  FROM DOCTOR 
  WHERE DOCTOR.PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
  AND Grade = 'Intern';

  IF is_intern > 0
  THEN
    SELECT Count(*) INTO high_rank_doc
    FROM `DOCTOR_has_Shift` shift 
    JOIN `DOCTOR` doc ON shift.DOCTOR_PERSONNEL_AMKA = doc.PERSONNEL_AMKA
    WHERE shift.Shift_shift_type = NEW.Shift_shift_type
    AND shift.Shift_date = NEW.Shift_date
    AND shift.Shift_Department_dept_id = NEW.Shift_Department_dept_id
    AND(doc.Grade = 'Supervisor A' OR doc.Grade = 'Director');
  
    IF high_rank_doc = 0
    THEN
       SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are no high rank doctors in this shift for an intern to attend';
    END IF;
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `superseded_shifts_doc`;

DELIMITER //

CREATE Trigger `superseded_shifts_doc` BEFORE INSERT ON `DOCTOR_has_Shift` FOR EACH ROW
BEGIN 
  DECLARE number_of_shifts INT;
  DECLARE eight_hour_break INT DEFAULT 0;
  DECLARE night1, night2, night3, night4 INT DEFAULT 0;

  IF NEW.Shift_shift_type = 'Morning'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `DOCTOR_has_Shift` 
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date = DATE_SUB(NEW.Shift_date, INTERVAL 1 day);

  ELSEIF NEW.Shift_shift_type = 'Evening'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `DOCTOR_has_Shift` 
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Morning'
    AND Shift_date = NEW.Shift_date;
  
  ELSEIF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `DOCTOR_has_Shift` 
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Evening'
    AND Shift_date = NEW.Shift_date;
  END IF;
  
  IF eight_hour_break > 0
  THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Doctor needs an eight hour rest';
  END IF;

  IF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO night1
    FROM `DOCTOR_has_Shift`
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY), 
      DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 3 DAY));
  
    SELECT Count(*) INTO night2
    FROM `DOCTOR_has_Shift`
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
    DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
    DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY),
    DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY));

    SELECT Count(*) INTO night3
    FROM `DOCTOR_has_Shift`
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY));

    SELECT Count(*) INTO night4
    FROM `DOCTOR_has_Shift`
    WHERE DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 3 DAY));
    
    IF (night1 = 3 OR night2 = 3 OR night3 = 3 OR night4 = 3)
    THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor connot work for 4 consecutive nights';
    END IF;
  END IF;
   
  SELECT Count(*) INTO number_of_shifts
  FROM `DOCTOR_has_Shift` shift  
  WHERE shift.DOCTOR_PERSONNEL_AMKA = NEW.DOCTOR_PERSONNEL_AMKA
  AND MONTH(shift.Shift_date) = MONTH(NEW.Shift_date)
  AND YEAR(shift.Shift_date) = YEAR(NEW.Shift_date);

  IF number_of_shifts = 15
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Doctor has exceeded his maximum shifts for this month';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `superseded_shifts_nurse`;

DELIMITER //

CREATE Trigger `superseded_shifts_nurse` BEFORE INSERT ON `Nurse_has_Shift` FOR EACH ROW
BEGIN 
  DECLARE number_of_shifts INT;
  DECLARE eight_hour_break INT DEFAULT 0;
  DECLARE night1, night2, night3, night4 INT DEFAULT 0;

  IF NEW.Shift_shift_type = 'Morning'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Nurse_has_Shift` 
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date = DATE_SUB(NEW.Shift_date, INTERVAL 1 day);

  ELSEIF NEW.Shift_shift_type = 'Evening'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Nurse_has_Shift` 
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Morning'
    AND Shift_date = NEW.Shift_date;
  
  ELSEIF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Nurse_has_Shift` 
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Evening'
    AND Shift_date = NEW.Shift_date;
  END IF;
  
  IF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO night1
    FROM `Nurse_has_Shift`
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY), 
      DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 3 DAY));
  
    SELECT Count(*) INTO night2
    FROM `Nurse_has_Shift`
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY));

    SELECT Count(*) INTO night3
    FROM `Nurse_has_Shift`
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY));

    SELECT Count(*) INTO night4
    FROM `Nurse_has_Shift`
    WHERE Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 3 DAY));
    
    IF (night1 = 3 OR night2 = 3 OR night3 = 3 OR night4 = 3)
    THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nurse connot work for 4 consecutive nights';
    END IF;
  END IF;
   

  IF eight_hour_break > 0
  THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Nurse needs an eight hour rest';
  END IF;

  SELECT Count(*) INTO number_of_shifts
  FROM `Nurse_has_Shift` shift  
  WHERE shift.Nurse_PERSONNEL_AMKA = NEW.Nurse_PERSONNEL_AMKA
  AND MONTH(shift.Shift_date) = MONTH(NEW.Shift_date)
  AND YEAR(shift.Shift_date) = YEAR(NEW.Shift_date);

  IF number_of_shifts = 20
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Nurse has exceeded his maximum shifts for this month';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `superseded_shifts_adm`;

DELIMITER //

CREATE Trigger `superseded_shifts_adm` BEFORE INSERT ON `Administrative_Staff_has_Shift` FOR EACH ROW
BEGIN 
  DECLARE number_of_shifts INT;
  DECLARE eight_hour_break INT DEFAULT 0;
  DECLARE night1, night2, night3, night4 INT DEFAULT 0;

  IF NEW.Shift_shift_type = 'Morning'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Administrative_Staff_has_Shift` 
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date = DATE_SUB(NEW.Shift_date, INTERVAL 1 day);

  ELSEIF NEW.Shift_shift_type = 'Evening'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Administrative_Staff_has_Shift` 
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Morning'
    AND Shift_date = NEW.Shift_date;
  
  ELSEIF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO eight_hour_break
    FROM `Administrative_Staff_has_Shift` 
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Evening'
    AND Shift_date = NEW.Shift_date;
  END IF;
  
  IF NEW.Shift_shift_type = 'Night'
  THEN
    SELECT Count(*) INTO night1
    FROM `Administrative_Staff_has_Shift`
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY), 
      DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 3 DAY));
  
    SELECT Count(*) INTO night2
    FROM `Administrative_Staff_has_Shift`
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 2 DAY));

    SELECT Count(*) INTO night3
    FROM `Administrative_Staff_has_Shift`
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_SUB(NEW.Shift_date, INTERVAL 1 DAY));

    SELECT Count(*) INTO night4
    FROM `Administrative_Staff_has_Shift`
    WHERE Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
    AND Shift_shift_type = 'Night'
    AND Shift_date in (
      DATE_ADD(NEW.Shift_date, INTERVAL 1 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 2 DAY),
      DATE_ADD(NEW.Shift_date, INTERVAL 3 DAY));

    IF (night1 = 3 OR night2 = 3 OR night3 = 3 OR night4 = 3)
    THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrative employee connot work for 4 consecutive nights';
    END IF;
  END IF;
   
  IF eight_hour_break > 0
  THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Administrative employee needs an eight hour rest';
  END IF;

  SELECT Count(*) INTO number_of_shifts
  FROM `Administrative_Staff_has_Shift` shift  
  WHERE shift.Administrative_Staff_PERSONNEL_AMKA = NEW.Administrative_Staff_PERSONNEL_AMKA
  AND MONTH(shift.Shift_date) = MONTH(NEW.Shift_date)
  AND YEAR(shift.Shift_date) = YEAR(NEW.Shift_date);

  IF number_of_shifts = 25
  THEN
     SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Administrative employee has exceeded his maximum shifts for this month';
  END IF;  
END
/
/

DELIMITER ;

DROP TRIGGER IF EXISTS `room_availability`;

DELIMITER //

CREATE Trigger `room_availability` BEFORE INSERT ON `Medical_Procedures` FOR EACH ROW
BEGIN
  DECLARE is_available INT DEFAULT 0;
  DECLARE doc_is_available INT DEFAULT 0;

  SELECT Count(*) INTO is_available
  FROM `Medical_Procedures`
  WHERE ROOM_room_id = NEW.ROOM_room_id
  AND start_time < NEW.end_time 
  AND end_time > NEW.start_time;

  SELECT Count(*) INTO doc_is_available
  FROM `Medical_Procedures`
  WHERE DocInCharge_id = NEW.DocInCharge_id
  AND start_time < NEW.end_time 
  AND end_time > NEW.start_time;

  IF doc_is_available > 0
    THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor is unavailable for this procedure';
  END IF; 

  IF is_available > 0
  THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is unavailable for this procedure';
  END IF;  
END
/
/

-- Trigger: We calculate the base cost when we know entry and exit date
DELIMITER ;

DROP TRIGGER IF EXISTS `calculate_hospitalization_cost`;

DELIMITER //

CREATE TRIGGER `calculate_hospitalization_cost` 
BEFORE INSERT ON `Hospitalization`
FOR EACH ROW
BEGIN
    DECLARE base_cost_val DECIMAL(10, 2);
    DECLARE avg_stay INT;
    DECLARE extra_rate DECIMAL(10, 2);
    DECLARE actual_stay INT;
    DECLARE final_cost DECIMAL(10, 2);

    IF NEW.exit_date IS NULL THEN 
        SET NEW.total_cost = NULL;
    ELSE
        SELECT base_cost, avg_stay_days, extra_day_rate
        INTO base_cost_val, avg_stay, extra_rate
        FROM `KEN` WHERE ken_code = NEW.KEN_ken_code;

        SET actual_stay = DATEDIFF(NEW.exit_date, NEW.entry_date);
        SET final_cost = base_cost_val;

        IF actual_stay > avg_stay THEN
            SET final_cost = final_cost + (actual_stay - avg_stay) * extra_rate;
        END IF;

        SET NEW.total_cost = final_cost;
    END IF;
END
/
/

-- Trigger: Calculate the cost when exit date takes a value(NOT NULL anymore)
DELIMITER ;

DROP TRIGGER IF EXISTS `calculate_hosp_cost_update`;

DELIMITER //

CREATE TRIGGER `calculate_hosp_cost_update`
BEFORE UPDATE ON `Hospitalization`
FOR EACH ROW
BEGIN
    DECLARE base_cost_val DECIMAL(10, 2);
    DECLARE avg_stay INT;
    DECLARE extra_rate DECIMAL(10, 2);
    DECLARE actual_stay INT;
    DECLARE final_cost DECIMAL(10, 2);

    IF OLD.exit_date IS NULL AND NEW.exit_date IS NOT NULL THEN
        SELECT base_cost, avg_stay_days, extra_day_rate
        INTO base_cost_val, avg_stay, extra_rate
        FROM `KEN` WHERE ken_code = NEW.KEN_ken_code;

        SET actual_stay = DATEDIFF(NEW.exit_date, NEW.entry_date);
        SET final_cost = base_cost_val;

        IF actual_stay > avg_stay THEN
            SET final_cost = final_cost + (actual_stay - avg_stay) * extra_rate;
        END IF;

        SET NEW.total_cost = final_cost;
    END IF;
END
/
/

-- Trigger: Before insert a Hospitalization check if the chosen bed is available
DELIMITER ;

DROP TRIGGER IF EXISTS `bed_availability_before_hospitalization`;

DELIMITER //

CREATE TRIGGER `bed_availability_before_hospitalization`
BEFORE INSERT ON `Hospitalization`
FOR EACH ROW
BEGIN
    DECLARE overlapping_days INT DEFAULT 0;
    SELECT Count(*) INTO overlapping_days 
    FROM `Hospitalization`
    WHERE bed_id = NEW.BEDS_bed_id 
    AND Department_dept_id = NEW.BEDS_Department_dept_id;
    AND entry_date <= IFNULL(NEW.exit_date, '2099-12-31')
    AND IFNULL(exit_date, '2099-12-31') >= NEW.entry_date;
    IF overlapping_days > 0 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Bed occupied or under maintenance';
    END IF;
END
/
/

-- Trigger: After I insert a Hospitalization I want the bed to become unavailable
DELIMITER ;

DROP TRIGGER IF EXISTS `bed_status_after_hospitalization`;

DELIMITER //

CREATE TRIGGER `bed_status_after_hospitalization`
AFTER INSERT ON `Hospitalization`
FOR EACH ROW 
BEGIN 
    UPDATE BEDS
    SET status = 'Occupied'
    WHERE bed_id = NEW.BEDS_bed_id
        AND Department_dept_id = NEW.BEDS_Department_dept_id;
END
/
/

-- Trigger: After I update a hospitalization I need the room to become available again
DELIMITER ;

DROP TRIGGER IF EXISTS `bed_after_discharge`;

DELIMITER //

CREATE TRIGGER `bed_after_discharge`
AFTER UPDATE ON `Hospitalization`
FOR EACH ROW
BEGIN 
    IF OLD.exit_date IS NULL AND NEW.exit_date IS NOT NULL THEN
        UPDATE BEDS
        SET status = 'Available'
        WHERE bed_id = NEW.BEDS_bed_id 
            AND Department_dept_id = NEW.BEDS_Department_dept_id;
    END IF;
END
/
/

-- Trigger: We calculate the duration of medical_proc when start and end time are known
DELIMITER ;

DROP TRIGGER IF EXISTS `med_proc_duration`;

DELIMITER //

CREATE TRIGGER `med_proc_duration`
BEFORE INSERT ON `Medical_Procedures`
FOR EACH ROW 
BEGIN 
    IF NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN 
        SET NEW.duration = TIMESTAMPDIFF(MINUTE, NEW.start_time, NEW.end_time);
    ELSE
        SET NEW.duration = NULL;
    END IF;
END
/
/

-- Trigger: We calculate the duration when end_time takes a value
DELIMITER ;

DROP TRIGGER IF EXISTS `med_proc_duration_update`;

DELIMITER //

CREATE TRIGGER `med_proc_duration_update`
FOR EACH ROW
BEGIN
    IF NEW.end_time IS NOT NULL THEN 
        SET NEW.duration = TIMESTAMPDIFF(MINUTE, NEW.start_time, NEW.end_time);
    ELSE 
        SET NEW.duration = NULL;
    END IF;
END
/
/

DELIMITER ;