SELECT 
    p.AMKA,
    p.first_name,
    p.last_name,
    YEAR(h.entry_data) AS year,
    DATEDIFF(h.exit_date, h.entry_date) AS stay_days,
    COUNT(*) AS number_of_stays,
    SUM(DATEDIFF(h.exit_date, h.entry_date)) AS total_duration
FROM Hospitalization h
JOIN Patient p ON h.Patient_AMKA = p.AMKA
WHERE h.exit_date IS NOT NULL 
GROUP BY p.AMKA, YEAR(h.entry_date), stay_days
HAVING total_duration > 15;