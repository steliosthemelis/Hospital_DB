WITH doc_surgeries AS (
    SELECT
        d.PERSONNEL_AMKA,
        p.name, 
        p.surname,
        COUNT(mp.procedures_id) AS num_surgeries
    FROM DOCTOR d
    JOIN PERSONNEL p ON d.PERSONNEL_AMKA = p.AMKA
    LEFT JOIN Medical_Procedures mp ON d.PERSONNEL_AMKA = mp.DocInCharge_id
        AND YEAR(mp.start_time) = YEAR(CURDATE())
    GROUP BY d.PERSONNEL_AMKA, p.name, p.surname
),
max_surgeries AS (
    SELECT MAX(num_surgeries) AS max_count
    FROM doc_surgeries
)
SELECT 
    ds.PERSONNEL_AMKA,
    ds.name,
    ds.surname,
    ds.num_surgeries
FROM doc_surgeries ds, max_surgeries ms
WHERE ds.num_surgeries <= ms.max_count - 5
ORDER BY ds.num_surgeries DESC;
