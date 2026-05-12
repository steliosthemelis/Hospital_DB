SELECT
    p.AMKA,
    p.name,
    p.surname,
    p.personnel_type
FROM PERSONNEL p   
WHERE 
    NOT EXISTS (
         SELECT 1
         FROM DOCTOR_has_Shift dhs
         WHERE dhs.DOCTOR_PERSONNEL_AMKA = p.AMKA
            AND dhs.Shift_date = '2026-05-12'
            AND dhs.Shift_Department_dept_id = 'UYEWTUY'    
    )
    AND 
        NOT EXISTS (
            SELECT 1
            FROM Nurse_has_Shift nhs
            WHERE nhs.Nurse_PERSONNEL_AMKA = p.AMKA
                AND nhs.Shift_date = '2026-05-12'
                AND nhs.Shift_Department_dept_id = 'skdjfkjsf'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM Administrative_Staff_has_Shift ahs
            WHERE ahs.Administrative_Staff_PERSONNEL_AMKA = p.AMKA
                AND ahs.Shift_date = '2026-05-12'
                AND ahs.Shift_Department_dept_id = 'akjsfhksjdf'
        );
        