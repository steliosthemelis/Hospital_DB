--load.sql
--Data population script for the database Hospital_DB

--Database's Name 
USE mydb;

SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
--1.Reference tables
-- ========================================

-- ========================================
-- ICD10 IMPORT
-- ========================================

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/icd10_utf8.txt'
INTO TABLE `mydb`.`ICD-10`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS
(`ICD-10`, `Description`);

-- ========================================
-- KEN IMPORT
-- ========================================

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/KEN_utf8.txt'
INTO TABLE `mydb`.`KEN`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS
(`ken_code`, `description`, `base_cost`, `avg_stay_days`, `extra_day_rate`);

--=========================================
-- DRUG
-- ==========================================

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/DRUG_utf8.txt'
INTO TABLE `mydb`.`DRUG`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS
(
product_name,
@active_substance,
route_of_admin,
auth_country,
auth_holder,
master_file_loc,
phv_email,
phv_phone
);

-- Medicines 
-- Active substances
-- DRUG
-- DRUG_has_Active_Substance

SET FOREIGN_KEY_CHECKS = 1;
