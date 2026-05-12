SELECT
    p.AMKA,
    p.name,
    p.surname,
    p.personnel_type
FROM PERSONNEL p   
WHERE 
    NOT EXISTS(
         SELECT 1
         FROM DOCTOR_has_Shift dhs
         WHERE dhs.DOCTOR_PERSONNEL_AMKA = p.AMKA
            AND dhs.Shift_date = '5/12/2026'
            AND dhs.Shift_Department_dept_id = 'UYEWTUY'    
    )
    AND 
        NOT EXISTS(
            SELECT 1
            FROM dhs.
        
        
        
        
        
        )