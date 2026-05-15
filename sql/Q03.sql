SELECT 
    p.AMKA,
    p.first_name,
    p.last_name,
    h.BEDS_Department_dept_id AS department,
    COUNT(*) AS num_hospitalizations,
    SUM(h.total_cost) AS total_cost
FROM
    Hospitalization h
JOIN Patient p ON h.Patient_AMKA = p.AMKA
HAVING num_hospitalizations > 3 
GROUP BY
    p.AMKA, h.BEDS_Department_dept_id
ORDER BY
    total_cost DESC;