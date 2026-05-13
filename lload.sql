-- =====================================================
-- lload.sql – Φόρτωση βασικών πινάκων μόνο
-- Χρησιμοποιείται μαζί με populate_mapping.py
-- =====================================================
USE mydb;

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- 1. ICD-10
LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/icd10_utf8.txt'
INTO TABLE `ICD-10`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`ICD-10`, `Description`);

-- 2. KEN
LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/KEN_utf8.txt'
INTO TABLE `KEN`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(ken_code, description, @base_cost, @avg_stay_days)
SET
base_cost = @base_cost,
currency = 'EUR',
avg_stay_days = @avg_stay_days,
extra_day_rate = @base_cost / @avg_stay_days;

-- 3. DRUG (col0 = pharmaceutical code stored as product_name)
TRUNCATE TABLE DRUG;
LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/DRUG_utf8.txt'
INTO TABLE DRUG
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(product_name, @active_substance, route_of_admin, auth_country, auth_holder, master_file_loc, phv_email, phv_phone);

UPDATE DRUG SET product_name = TRIM(product_name);

-- 4. Active_Substance (από το pre-split αρχείο)
TRUNCATE TABLE Active_Substance;
LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/Active_Substance_split.txt'
INTO TABLE Active_Substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(substance_name);

UPDATE Active_Substance SET substance_name = TRIM(substance_name);

UPDATE KEN SET ken_code = REPLACE(ken_code, CHAR(65279 USING utf8mb4), '');

-- 5. Τέλος (DRUG_has_Active_Substance → τρέξε populate_mapping.py)
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
COMMIT;
