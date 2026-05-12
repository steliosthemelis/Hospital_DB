WITH young_surgeon AS (
    SELECT
        d.PERSONNEL_AMKA,
        p.name,
        p.surname,
        COUNT(mp.procedure_id) AS num_surgical
    FROM DOCTOR d
    JOIN PERSONNEL p ON d.PERSONNEL_AMKA = p.AMKA
    LEFT JOIN Medical_Procedures md
        ON d.PERSONNEL_AMKA = mp.DocInCharge_id
        AND mp.category = 'χειρουργική'
    WHERE p.age < 35
    GROUP BY d.PERSONNEL_AMKA, p.name, p.surname
),
max_surgical AS (
    SELECT MAX(num_surgical) AS max_surg FROM young_surgeon
)
SELECT
    ys.PERSONNEL_AMKA,
    ys.name,
    ys.surname,
    ys.num_surgical
FROM  young_surgeons ys
CROSS JOIN max_surgical ms
WHERE ys.num_surgical = ms.max_surg
ORDER BY ys.num_surgical DESC;