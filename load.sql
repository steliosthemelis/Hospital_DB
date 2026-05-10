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


SET FOREIGN_KEY_CHECKS = 1;


-- KEN
-- Insurance providers 
-- Medicines 
-- Active substances
-- DRUG
-- DRUG_has_Active_Substance


