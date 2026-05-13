--Dynamic set of week based on today 
DECLARE @given_date DATE;
DECLARE @week_start DATE;
DECLARE @week_end DATE;
SET @given_date = GETDATE();
SET @week_start = DATEADD(DAY, - (DATEPART(WEEKDAY, @given_date) - 2), @given_date);
SET @week_end = DATEADD(DAY, 6, @week_start);
SET @week_range = CONCAT(@week_start, ' to ', @week_end);

--Doctors per speciality

SELECT 
    d.dept_id AS department,
    s.shift_type,
    @week_range AS week_range,
    'Doctor' AS personnel_type,
    doc.specialty AS subcatecory,
    COUNT(DISTINCT dhs.DOCTOR_PERSONNEL_AMKA) AS desired_number
FROM Department d
CROSS JOIN (SELECT DISTINCT shift_type FROM Shift) s
LEFT JOIN Doctor_has_Shift dhs
    ON dhs.Shift_Department_dept_id = d.dept_id
    AND dhs.Shift_shift_type = s.shift_type
    AND dhs.Shift_date BETWEEN @week_start AND @week_end
LEFT JOIN DOCTOR doc ON dhs.DOCTOR_PERSONNEL_AMKA = doc.PERSONNEL_AMKA
GROUP BY d.dept_id, s.shift_type, doc.speciality

UNION ALL

SELECT 
    d.dept_id,
    s.shift_type,
    @week_range,
    'Nurse',
    nur.Grade,
    COUNT(DISTINCT nhs.Nurse_PERSONNEL_AMKA)
FROM Department d
CROSS JOIN (SELECT DISTINCT shift_type FROM Shift) s
LEFT JOIN Nurse_has_Shift dhs
    ON nhs.Shift_Department_dept_id = d.dept_id
    AND nhs.Shift_shift_type = s.shift_type
    AND nhs.Shift_date BETWEEN @week_start AND @week_end
LEFT JOIN Nurse nur ON nhs.Nurse_PERSONNEL_AMKA = nur.PERSONNEL_AMKA
GROUP BY d.dept_id, s.shift_type, nur.Grade

UNION ALL

SELECT 
    d.dept_id AS department,
    s.shift_type,
    @week_range,
    'Administrative_Staff',
    adm.duties,
    COUNT(DISTINCT ahs.Administrative_Staff_PERSONNEL_AMKA)
FROM Department d
CROSS JOIN (SELECT DISTINCT shift_type FROM Shift) s
LEFT JOIN Administrative_Staff_has_Shift ahs
    ON ahs.Shift_Department_dept_id = d.dept_id
    AND ahs.Shift_shift_type = s.shift_type
    AND ahs.Shift_date BETWEEN @week_start AND @week_end
LEFT JOIN Administrative_Staff adm ON ahs.Nurse_PERSONNEL_AMKA = adm.PERSONNEL_AMKA
GROUP BY d.dept_id, s.shift_type, nur.Grade

ORDER BY department, shift_type, personnel_type, subcategory;

