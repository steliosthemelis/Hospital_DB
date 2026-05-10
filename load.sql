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
(ken_code, description, @base_cost, @avg_stay_days)
SET 
`base_cost` = @base_cost,
`currency` = 'EUR',
`avg_stay_days` = @avg_stay_days,
`extra_day_rate` = @base_cost / @avg_stay_days;

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

-- ===========================================
-- Active Substance
-- ===========================================

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/ACTIVE_SUBSTANCE_utf8.txt'
INTO TABLE `mydb`.`ACTIVE_SUBSTANCE`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'
(substance_name);

-- ==========================================
-- DRUG_ACTIVE_SUBSTANCE
-- ==========================================

DROP TABLE IF EXISTS temp_drug_active;

CREATE TABLE temp_drug_active(
    product_name VARCHAR(255),
    active_substance VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/DRUG_ACTIVE_utf8.txt'
INTO TABLE temp_drug_active
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'
(product_name, active_substance);

DELETE FROM temp_drug_active
WHERE product_name LIKE '?%';

INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id)
SELECT d.drug_id, a.substance_id
FROM temp_drug_active t
JOIN DRUG d ON TRIM(LOWER(d.product_name)) = TRIM(LOWER(t.product_name))
JOIN ACTIVE_SUBSTANCE a ON TRIM(LOWER(a.substance_name)) = TRIM(LOWER(t.active_substance));





SET FOREIGN_KEY_CHECKS = 1;

