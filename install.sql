-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`PERSONNEL`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`PERSONNEL` ;

CREATE TABLE IF NOT EXISTS `mydb`.`PERSONNEL` (
  `AMKA` CHAR(11) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `surname` VARCHAR(45) NOT NULL,
  `age` INT NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `hire_date` DATE NOT NULL,
  `personnel_type` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`AMKA`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DOCTOR`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DOCTOR` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR` (
  `license_number` VARCHAR(30) NOT NULL,
  `specialty` VARCHAR(50) NOT NULL,
  `Grade` VARCHAR(30) NOT NULL,
  `PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Supervisor_AMKA` CHAR(11) NOT NULL,
  PRIMARY KEY (`PERSONNEL_AMKA`),
  INDEX `Supervisor_AMKA_idx` (`Supervisor_AMKA` ASC),
  UNIQUE INDEX `license_number_UNIQUE` (`license_number` ASC),
  CONSTRAINT `fk_DOCTOR_PERSONNEL`
    FOREIGN KEY (`PERSONNEL_AMKA`)
    REFERENCES `mydb`.`PERSONNEL` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Supervisor_AMKA`
    FOREIGN KEY (`Supervisor_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Department`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Department` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Department` (
  `description` TINYTEXT NOT NULL,
  `num_of_beds` INT NOT NULL,
  `building` VARCHAR(45) NOT NULL,
  `level` VARCHAR(45) NOT NULL,
  `dept_id` VARCHAR(45) NOT NULL,
  `Director_AMKA` CHAR(11) NOT NULL,
  PRIMARY KEY (`dept_id`),
  INDEX `fk_Department_DOCTOR1_idx` (`Director_AMKA` ASC),
  UNIQUE INDEX `Director_AMKA_UNIQUE` (`Director_AMKA` ASC),
  CONSTRAINT `Director_AMKA`
    FOREIGN KEY (`Director_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Nurse`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Nurse` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Nurse` (
  `Grade` VARCHAR(30) NOT NULL,
  `PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`PERSONNEL_AMKA`),
  INDEX `fk_Nurse_Department1_idx` (`Department_dept_id` ASC),
  CONSTRAINT `fk_Nurse_PERSONNEL1`
    FOREIGN KEY (`PERSONNEL_AMKA`)
    REFERENCES `mydb`.`PERSONNEL` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Nurse_Department1`
    FOREIGN KEY (`Department_dept_id`)
    REFERENCES `mydb`.`Department` (`dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Administrative_Staff`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Administrative_Staff` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Administrative_Staff` (
  `duties` VARCHAR(30) NOT NULL,
  `PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`PERSONNEL_AMKA`),
  INDEX `fk_Administrative_Staff_Department1_idx` (`Department_dept_id` ASC),
  CONSTRAINT `fk_Administrative_Staff_PERSONNEL1`
    FOREIGN KEY (`PERSONNEL_AMKA`)
    REFERENCES `mydb`.`PERSONNEL` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Administrative_Staff_Department1`
    FOREIGN KEY (`Department_dept_id`)
    REFERENCES `mydb`.`Department` (`dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DOCTOR_has_Department`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DOCTOR_has_Department` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR_has_Department` (
  `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DOCTOR_PERSONNEL_AMKA`, `Department_dept_id`),
  INDEX `fk_DOCTOR_has_Department_Department1_idx` (`Department_dept_id` ASC),
  INDEX `fk_DOCTOR_has_Department_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_DOCTOR_has_Department_DOCTOR1`
    FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DOCTOR_has_Department_Department1`
    FOREIGN KEY (`Department_dept_id`)
    REFERENCES `mydb`.`Department` (`dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`BEDS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`BEDS` ;

CREATE TABLE IF NOT EXISTS `mydb`.`BEDS` (
  `bed_id` INT NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(45) NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`bed_id`, `Department_dept_id`),
  INDEX `fk_BEDS_Department1_idx` (`Department_dept_id` ASC),
  CONSTRAINT `fk_BEDS_Department1`
    FOREIGN KEY (`Department_dept_id`)
    REFERENCES `mydb`.`Department` (`dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Patient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Patient` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Patient` (
  `AMKA` CHAR(11) NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `father_name` VARCHAR(45) NOT NULL,
  `age` INT NOT NULL,
  `gender` VARCHAR(45) NOT NULL,
  `weight` DECIMAL(5,2) NULL,
  `height` DECIMAL(3,2) NULL,
  `address` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NULL,
  `profession` VARCHAR(45) NOT NULL,
  `nationality` VARCHAR(45) NOT NULL,
  `insurance_type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`AMKA`),
  UNIQUE INDEX `AMKA_UNIQUE` (`AMKA` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Emergency_Contact`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Emergency_Contact` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Emergency_Contact` (
  `contact_id` INT NOT NULL AUTO_INCREMENT,
  `firts_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  `relationship` VARCHAR(45) NOT NULL,
  `Patient_AMKA` CHAR(11) NOT NULL,
  PRIMARY KEY (`contact_id`, `Patient_AMKA`),
  INDEX `fk_Emergency_Contact_Patient1_idx` (`Patient_AMKA` ASC),
  CONSTRAINT `fk_Emergency_Contact_Patient1`
    FOREIGN KEY (`Patient_AMKA`)
    REFERENCES `mydb`.`Patient` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Shift`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Shift` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Shift` (
  `shift_type` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  `Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`shift_type`, `date`, `Department_dept_id`),
  UNIQUE INDEX `unique_shift` (`date` ASC, `shift_type` ASC),
  INDEX `fk_Shift_Department1_idx` (`Department_dept_id` ASC),
  CONSTRAINT `fk_Shift_Department1`
    FOREIGN KEY (`Department_dept_id`)
    REFERENCES `mydb`.`Department` (`dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`ICD-10`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`ICD-10` ;

CREATE TABLE IF NOT EXISTS `mydb`.`ICD-10` (
  `ICD-10` VARCHAR(10) NOT NULL,
  `Description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ICD-10`),
  UNIQUE INDEX `ICD-10_UNIQUE` (`ICD-10` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`KEN`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`KEN` ;

CREATE TABLE IF NOT EXISTS `mydb`.`KEN` (
  `ken_code` VARCHAR(10) NOT NULL,
  `base_cost` DECIMAL(10,2) NOT NULL,
  `avg_stay_days` INT NOT NULL,
  `extra_day_rate` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ken_code`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Hospitalization`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Hospitalization` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Hospitalization` (
  `hosp_id` INT NOT NULL,
  `entry_date` DATETIME NOT NULL,
  `exit_date` DATETIME NOT NULL,
  `total_cost` DECIMAL(10,2) NULL,
  `BEDS_bed_id` INT NOT NULL,
  `BEDS_Department_dept_id` VARCHAR(45) NOT NULL,
  `Patient_AMKA` CHAR(11) NOT NULL,
  `ICD-10_in` VARCHAR(10) NOT NULL,
  `ICD-10_out` VARCHAR(10) NOT NULL,
  `KEN_ken_code` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`hosp_id`),
  INDEX `fk_Hospitalization_BEDS1_idx` (`BEDS_bed_id` ASC, `BEDS_Department_dept_id` ASC),
  INDEX `fk_Hospitalization_Patient1_idx` (`Patient_AMKA` ASC),
  INDEX `fk_Hospitalization_ICD-101_idx` (`ICD-10_in` ASC),
  INDEX `fk_Hospitalization_ICD-102_idx` (`ICD-10_out` ASC),
  INDEX `fk_Hospitalization_KEN1_idx` (`KEN_ken_code` ASC),
  CONSTRAINT `fk_Hospitalization_BEDS1`
    FOREIGN KEY (`BEDS_bed_id` , `BEDS_Department_dept_id`)
    REFERENCES `mydb`.`BEDS` (`bed_id` , `Department_dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Hospitalization_Patient1`
    FOREIGN KEY (`Patient_AMKA`)
    REFERENCES `mydb`.`Patient` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Hospitalization_ICD-101`
    FOREIGN KEY (`ICD-10_in`)
    REFERENCES `mydb`.`ICD-10` (`ICD-10`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Hospitalization_ICD-102`
    FOREIGN KEY (`ICD-10_out`)
    REFERENCES `mydb`.`ICD-10` (`ICD-10`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Hospitalization_KEN1`
    FOREIGN KEY (`KEN_ken_code`)
    REFERENCES `mydb`.`KEN` (`ken_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Triage`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Triage` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Triage` (
  `triage_id` INT NOT NULL,
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
  CONSTRAINT `fk_Triage_Nurse1`
    FOREIGN KEY (`Nurse_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`Nurse` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Triage_Hospitalization1`
    FOREIGN KEY (`Hospitalization_hosp_id`)
    REFERENCES `mydb`.`Hospitalization` (`hosp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Triage_Patient1`
    FOREIGN KEY (`Patient_AMKA`)
    REFERENCES `mydb`.`Patient` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`LAB_EXAMS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`LAB_EXAMS` ;

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
  CONSTRAINT `fk_LAB_EXAMS_Hospitalization1`
    FOREIGN KEY (`Hospitalization_hosp_id`)
    REFERENCES `mydb`.`Hospitalization` (`hosp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_LAB_EXAMS_DOCTOR1`
    FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`ROOM`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`ROOM` ;

CREATE TABLE IF NOT EXISTS `mydb`.`ROOM` (
  `room_id` INT NOT NULL,
  `room_name` VARCHAR(45) NOT NULL,
  `room_type` VARCHAR(45) NOT NULL,
  `capacity` INT NOT NULL,
  PRIMARY KEY (`room_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Medical_Procedures`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Medical_Procedures` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Medical_Procedures` (
  `procedure_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `category` VARCHAR(45) NOT NULL,
  `duration` INT NOT NULL,
  `cost` DECIMAL(10,2) NOT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `ROOM_room_id` INT NOT NULL,
  `DocInCharge_id` CHAR(11) NOT NULL,
  `Hospitalization_hosp_id` INT NOT NULL,
  PRIMARY KEY (`procedure_id`),
  INDEX `fk_Medical_Procedures_ROOM1_idx` (`ROOM_room_id` ASC),
  INDEX `fk_Medical_Procedures_DOCTOR1_idx` (`DocInCharge_id` ASC),
  INDEX `fk_Medical_Procedures_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
  CONSTRAINT `fk_Medical_Procedures_ROOM1`
    FOREIGN KEY (`ROOM_room_id`)
    REFERENCES `mydb`.`ROOM` (`room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Medical_Procedures_DOCTOR1`
    FOREIGN KEY (`DocInCharge_id`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Medical_Procedures_Hospitalization1`
    FOREIGN KEY (`Hospitalization_hosp_id`)
    REFERENCES `mydb`.`Hospitalization` (`hosp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Procedure_Team`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Procedure_Team` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Procedure_Team` (
  `role` VARCHAR(45) NOT NULL,
  `Medical_Procedures_procedure_id` INT NOT NULL,
  `PERSONNEL_AMKA` CHAR(11) NOT NULL,
  PRIMARY KEY (`Medical_Procedures_procedure_id`, `PERSONNEL_AMKA`),
  INDEX `fk_Procedure_Team_PERSONNEL1_idx` (`PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_Procedure_Team_Medical_Procedures1`
    FOREIGN KEY (`Medical_Procedures_procedure_id`)
    REFERENCES `mydb`.`Medical_Procedures` (`procedure_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Procedure_Team_PERSONNEL1`
    FOREIGN KEY (`PERSONNEL_AMKA`)
    REFERENCES `mydb`.`PERSONNEL` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DRUG`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DRUG` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DRUG` (
  `drug_id` INT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(255) NOT NULL,
  `route_of_admin` VARCHAR(100) NOT NULL,
  `auth_country` VARCHAR(100) NOT NULL,
  `auth_holder` VARCHAR(255) NOT NULL,
  `master_file_loc` VARCHAR(255) NOT NULL,
  `phv_email` VARCHAR(100) NOT NULL,
  `phv_phone` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`drug_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Active_Substance`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Active_Substance` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Active_Substance` (
  `substance_id` INT NOT NULL,
  `substance_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`substance_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DRUG_has_Active_Substance`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DRUG_has_Active_Substance` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DRUG_has_Active_Substance` (
  `DRUG_drug_id` INT NOT NULL,
  `Active_Substance_substance_id` INT NOT NULL,
  PRIMARY KEY (`DRUG_drug_id`, `Active_Substance_substance_id`),
  INDEX `fk_DRUG_has_Active_Substance_Active_Substance1_idx` (`Active_Substance_substance_id` ASC),
  INDEX `fk_DRUG_has_Active_Substance_DRUG1_idx` (`DRUG_drug_id` ASC),
  CONSTRAINT `fk_DRUG_has_Active_Substance_DRUG1`
    FOREIGN KEY (`DRUG_drug_id`)
    REFERENCES `mydb`.`DRUG` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DRUG_has_Active_Substance_Active_Substance1`
    FOREIGN KEY (`Active_Substance_substance_id`)
    REFERENCES `mydb`.`Active_Substance` (`substance_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Patient_Allergy`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Patient_Allergy` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Patient_Allergy` (
  `Patient_AMKA` CHAR(11) NOT NULL,
  `Active_Substance_substance_id` INT NOT NULL,
  PRIMARY KEY (`Patient_AMKA`, `Active_Substance_substance_id`),
  INDEX `fk_Patient_Allergy_Active_Substance1_idx` (`Active_Substance_substance_id` ASC),
  CONSTRAINT `fk_Patient_Allergy_Patient1`
    FOREIGN KEY (`Patient_AMKA`)
    REFERENCES `mydb`.`Patient` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Patient_Allergy_Active_Substance1`
    FOREIGN KEY (`Active_Substance_substance_id`)
    REFERENCES `mydb`.`Active_Substance` (`substance_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Perscription`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Perscription` ;

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
  CONSTRAINT `fk_Perscription_PERSONNEL1`
    FOREIGN KEY (`PERSONNEL_AMKA`)
    REFERENCES `mydb`.`PERSONNEL` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Perscription_Patient1`
    FOREIGN KEY (`Patient_AMKA`)
    REFERENCES `mydb`.`Patient` (`AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Perscription_DRUG1`
    FOREIGN KEY (`DRUG_drug_id`)
    REFERENCES `mydb`.`DRUG` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Perscription_Hospitalization1`
    FOREIGN KEY (`Hospitalization_hosp_id`)
    REFERENCES `mydb`.`Hospitalization` (`hosp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DOCTOR_has_Shift`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DOCTOR_has_Shift` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DOCTOR_has_Shift` (
  `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Shift_shift_type` VARCHAR(45) NOT NULL,
  `Shift_date` DATE NOT NULL,
  `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DOCTOR_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
  INDEX `fk_DOCTOR_has_Shift_Shift1_idx` (`Shift_shift_type` ASC, `Shift_date` ASC, `Shift_Department_dept_id` ASC),
  INDEX `fk_DOCTOR_has_Shift_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_DOCTOR_has_Shift_DOCTOR1`
    FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DOCTOR_has_Shift_Shift1`
    FOREIGN KEY (`Shift_shift_type` , `Shift_date` , `Shift_Department_dept_id`)
    REFERENCES `mydb`.`Shift` (`shift_type` , `date` , `Department_dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Administrative_Staff_has_Shift`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Administrative_Staff_has_Shift` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Administrative_Staff_has_Shift` (
  `Administrative_Staff_PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Shift_shift_type` VARCHAR(45) NOT NULL,
  `Shift_date` DATE NOT NULL,
  `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Administrative_Staff_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
  INDEX `fk_Administrative_Staff_has_Shift_Shift1_idx` (`Shift_shift_type` ASC, `Shift_date` ASC, `Shift_Department_dept_id` ASC),
  INDEX `fk_Administrative_Staff_has_Shift_Administrative_Staff1_idx` (`Administrative_Staff_PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_Administrative_Staff_has_Shift_Administrative_Staff1`
    FOREIGN KEY (`Administrative_Staff_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`Administrative_Staff` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Administrative_Staff_has_Shift_Shift1`
    FOREIGN KEY (`Shift_shift_type` , `Shift_date` , `Shift_Department_dept_id`)
    REFERENCES `mydb`.`Shift` (`shift_type` , `date` , `Department_dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Nurse_has_Shift`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Nurse_has_Shift` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Nurse_has_Shift` (
  `Nurse_PERSONNEL_AMKA` CHAR(11) NOT NULL,
  `Shift_shift_type` VARCHAR(45) NOT NULL,
  `Shift_date` DATE NOT NULL,
  `Shift_Department_dept_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Nurse_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`),
  INDEX `fk_Nurse_has_Shift_Shift1_idx` (`Shift_shift_type` ASC, `Shift_date` ASC, `Shift_Department_dept_id` ASC),
  INDEX `fk_Nurse_has_Shift_Nurse1_idx` (`Nurse_PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_Nurse_has_Shift_Nurse1`
    FOREIGN KEY (`Nurse_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`Nurse` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Nurse_has_Shift_Shift1`
    FOREIGN KEY (`Shift_shift_type` , `Shift_date` , `Shift_Department_dept_id`)
    REFERENCES `mydb`.`Shift` (`shift_type` , `date` , `Department_dept_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Evaluation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Evaluation` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Evaluation` (
  `eval_id` INT NOT NULL,
  `nursing_care` INT NOT NULL,
  `Clean` INT NOT NULL,
  `Food` INT NOT NULL,
  `TotalExperience` INT NOT NULL,
  `Hospitalization_hosp_id` INT NOT NULL,
  PRIMARY KEY (`eval_id`),
  INDEX `fk_Evaluation_Hospitalization1_idx` (`Hospitalization_hosp_id` ASC),
  UNIQUE INDEX `Hospitalization_hosp_id_UNIQUE` (`Hospitalization_hosp_id` ASC),
  CONSTRAINT `fk_Evaluation_Hospitalization1`
    FOREIGN KEY (`Hospitalization_hosp_id`)
    REFERENCES `mydb`.`Hospitalization` (`hosp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DoctorEvaluation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`DoctorEvaluation` ;

CREATE TABLE IF NOT EXISTS `mydb`.`DoctorEvaluation` (
  `MedCareQuality` INT NOT NULL,
  `eval_id` INT NOT NULL,
  `DOCTOR_PERSONNEL_AMKA` CHAR(11) NOT NULL,
  PRIMARY KEY (`eval_id`, `DOCTOR_PERSONNEL_AMKA`),
  INDEX `fk_DoctorEvaluation_DOCTOR1_idx` (`DOCTOR_PERSONNEL_AMKA` ASC),
  CONSTRAINT `fk_DoctorEvaluation_Evaluation1`
    FOREIGN KEY (`eval_id`)
    REFERENCES `mydb`.`Evaluation` (`eval_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DoctorEvaluation_DOCTOR1`
    FOREIGN KEY (`DOCTOR_PERSONNEL_AMKA`)
    REFERENCES `mydb`.`DOCTOR` (`PERSONNEL_AMKA`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
