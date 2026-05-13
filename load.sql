--load.sql
--Data population script for the database Hospital_DB

--Database's Name 
USE mydb;

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

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
LINES TERMINATED BY '\r\n'
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

TRUNCATE DRUG;
LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/DRUG_utf8.txt'
INTO TABLE `mydb`.`DRUG`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
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

UPDATE DRUG SET product_name = TRIM(product_name) WHERE product_name LIKE ' %' OR product_name LIKE '% ';

-- ===========================================
-- Active_Substance (with pre-split file)
-- ===========================================

TRUNCATE TABLE Active_Substance;

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/Active_Substance_split.txt'
INTO TABLE `mydb`.`Active_Substance` 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
(substance_name);

-- Trim substance names
UPDATE Active_Substance SET substance_name = TRIM(substance_name);

-- ==========================================
-- DRUG_ACTIVE_SUBSTANCE
-- ==========================================

DROP TABLE IF EXISTS temp_drug_active;

CREATE TABLE temp_drug_active(
    product_name VARCHAR(255),
    active_substance VARCHAR(255),
    product_clean VARCHAR(250),
    substance_clean VARCHAR(250),
    INDEX idx_producy (product_name(250)),
    INDEX idx_substance (active_substance(250))
)ENGINE = MyISAM;

LOAD DATA LOCAL INFILE 'C:/Users/ntoko/Hospital_DB/csv/DRUG_ACTIVE_utf8.txt'
INTO TABLE temp_drug_active
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
(product_name, active_substance);

DELETE FROM temp_drug_active
WHERE product_name LIKE '?%' OR TRIM(product_name) = '';

-- Populate clean columns (once, to avoid functions in JOINs)
UPDATE temp_drug_active 
SET product_clean = TRIM(LOWER(product_name)),
    substance_clean = TRIM(LOWER(active_substance));

--Create a table of unique drug names (chose smallest drug_id per product)
DROP TABLE IF EXISTS unique_drug;

CREATE TABLE unique_drug ENGINE = MyISAM
AS
SELECT MIN(drug_id) AS drug_id, TRIM(LOWER(product_name)) AS product_clean
FROM DRUG
GROUP BY product_clean;
ALTER TABLE unique_drug ADD INDEX idx_clean (product_clean(250));
ALTER TABLE unique_drug ADD INDEX idx_drug_id (drug_id);

--Clean substance names in Active_Substance
DROP TABLE IF EXISTS active_clean;
CREATE TABLE active_clean ENGINE = MyISAM
AS
SELECT substance_id, TRIM(LOWER(substance_name)) AS substance_clean
FROM Active_Substance;
ALTER TABLE active_clean ADD INDEX idx_clean (substance_clean(250));
ALTER TABLE active_clean ADD INDEX idx_id (substance_id);

ALTER TABLE DRUG_has_Active_Substance DISABLE KEYS;

--Insert to the mapping table
INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id)
SELECT u.drug_id, a.substance_id
FROM temp_drug_active t
JOIN unique_drug u ON t.product_clean = u.product_clean
JOIN active_clean a ON t.substance_clean = a.substance_clean;

ALTER TABLE DRUG_has_Active_Substance ENABLE KEYS;

-- ===============================
--Finalize
-- ===============================

SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
COMMIT;