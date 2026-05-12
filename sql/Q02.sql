SELECT 
    d.PERSONNEL_AMKA, 
    d.license_number, d.specialty, d.Grade,
    CASE WHEN EXISTS (
        SELECT 1
        FROM Doctor_has_Shift dhs
        WHERE dhs.DOCTOR_PERSONNEL_AMKA = d.PERSONNEL_AMKA
        AND dhs.Shift_date BETWEEN '2024-01-01' AND '2024-12-31'
    ) THEN 1 ELSE 0 END AS has_shift_in_2024,
    (
        SELECT COUNT(*)
        FROM Medical_Procedures mp
        WHERE mp.DocInCharge_id = d.PERSONNEL_AMKA
        ) AS num_surgeries_in_2024
FROM Doctor d
WHERE d.specialty = 'Cardiology';