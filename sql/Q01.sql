BEGIN TRANSACTION;

INSERT INTO PERSONNEL (AMKA, name, surname, age, email, phone, hire_date, personnel_type)
VALUES ('99999999990', 'Temp', 'Doctor', 45, 'temp.doc@example.com', '6900000000', CURDATE(), 'Doctor');

INSERT INTO DOCTOR (license_number, specialty, Grade, PERSONNEL_AMKA, Supervisor_AMKA)VALUES ('TEMP999', 'Cardiology', 'Director', '99999999990', NULL);  -- Διευθυντής δεν έχει επόπτη

INSERT INTO Department (dept_id, num_of_beds, building, level, Director_AMKA)
VALUES ('TEST', 10, 'A', '1', '12345678901');   -- το Director_AMKA πρέπει να υπάρχει ήδη

INSERT INTO BEDS (bed_id, type, status, Department_dept_id)
VALUES (9999, 'μονόκλινο', 'διαθέσιμη', 'TEST');

INSERT INTO Patient (AMKA, first_name, last_name, father_name, age, gender, address, phone, profession, nationality, insurance_type)
VALUES ('99999999999', 'Test', 'User', 'T', 30, 'M', 'addr', '123', 'none', 'Greek', 'EFKA');

INSERT INTO Hospitalization (hosp_id, entry_date, exit_date, BEDS_bed_id, BEDS_Department_dept_id, Patient_AMKA, [ICD-10_in], [ICD-10_out], KEN_ken_code)
VALUES
(9991, '2024-01-01', '2024-01-05', 9999, 'TEST', '99999999999', 'A00.0', 'A01.0', 'S01A'),
(9992, '2024-02-01', '2024-02-08', 9999, 'TEST', '99999999999', 'A00.1', 'A01.1', 'S01M'),
(9993, '2024-03-01', '2024-03-10', 9999, 'TEST', '99999999999', 'A00.9', 'A01.2', 'S20A');

SELECT
    d.dept_id AS department,
    YEAR(h.entry_date) AS year,
    h.KEN_ken_code AS ken_code,
    p.insurance_type,
    COUNT(*) AS hospitalization_count,
    SUM (k.base_cost) AS total_base_cost,
    SUM(
        CASE 
            WHEN DATEDIFF(h.exit_date, h.entry_date) > k.avg_stay_days THEN 
                (DATEDIFF(h.exit_date, h.entry_date) - k.avg_stay_days) * k.extra_day_rate
            ELSE 0
        END
    ) AS total_extra_day_cost
FROM
    Hospitalization h
JOIN BEDS b ON h.BED_bed_id = b.bed_id AND h.BEDS_Department_dept_id = b.Department_dept_id
JOIN Department d ON b.Department_dept_id = d.dept_id
JOIN KEN k ON h.KEN_ken_code = k.ken_code
JOIN Patient p ON h.Patient_AMKA = p.AMKA
WHERE d.dept_id = 'TEST' --TRIAL
GROUP BY
    d.dept_id, YEAR(h.entry_date), h.KEN_ken_code, p.insurance_type
ORDER BY
    d.dept_id, YEAR(h.entry_date), h.KEN_ken_code, p.insurance_type;
    

ROLLBACK
