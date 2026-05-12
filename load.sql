--  load.sql
--  Data population script for the database Hospital_DB

--  Database's Name 
USE mydb;

SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
-- 1.Reference tables
-- ========================================



LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/icd10_utf8.txt'
INTO TABLE `mydb`.`ICD-10`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`ICD-10`, `Description`);



LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/KEN_utf8.txt'
INTO TABLE `mydb`.`KEN`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(ken_code, description, @base_cost, @avg_stay_days)
SET 
`base_cost` = @base_cost,
`currency` = 'EUR',
`avg_stay_days` = @avg_stay_days,
`extra_day_rate` = @base_cost / @avg_stay_days;



LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/DRUG_utf8.txt'
INTO TABLE `mydb`.`DRUG`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
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



LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/ACTIVE_SUBSTANCE_utf8.txt'
INTO TABLE `mydb`.`Active_Substance`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(substance_name);



-- Temp table: drug_code -> drug_id mapping (same row order as DRUG_utf8.txt)
DROP TABLE IF EXISTS temp_drug_codes;
CREATE TABLE temp_drug_codes (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    drug_code VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/DRUG_utf8.txt'
INTO TABLE temp_drug_codes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(drug_code, @skip, @skip, @skip, @skip, @skip, @skip, @skip);

-- Temp table: drug_code -> active_substance (tab-separated, no header)
DROP TABLE IF EXISTS temp_drug_active;
CREATE TABLE temp_drug_active (
    drug_code VARCHAR(255),
    active_substance VARCHAR(1000)
);

LOAD DATA LOCAL INFILE '/Users/steliosthemelis/Hospital_DB/csv/DRUG_ACTIVE_utf8.txt'
INTO TABLE temp_drug_active
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(drug_code, active_substance);

DELETE FROM temp_drug_active WHERE drug_code LIKE '?%';

-- Join: drug_code -> drug_id, substance_name -> substance_id
INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id)
SELECT d.drug_id, a.substance_id
FROM temp_drug_active t
JOIN temp_drug_codes tc ON TRIM(LOWER(tc.drug_code)) = TRIM(LOWER(t.drug_code))
JOIN DRUG d ON d.drug_id = tc.id
JOIN Active_Substance a ON TRIM(LOWER(a.substance_name)) = TRIM(LOWER(t.active_substance));

DROP TABLE IF EXISTS temp_drug_codes;
DROP TABLE IF EXISTS temp_drug_active;

SET FOREIGN_KEY_CHECKS = 1;

