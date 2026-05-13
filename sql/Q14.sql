WITH yearly_entries AS (
    SELECT 
    [ICD-10_in] AS icd_in_code,
        YEAR(entry_date) AS year,
        COUNT(*) AS admissions
    FROM Hospitalization 
    GROUP BY [ICD-10_in], YEAR(entry_date)
    HAVING COUNT(*) >= 5
    )
SELECT
    a.icd_code,
    a.year AS year1,
    b.year AS year2,
    a.admissions AS COUNT
FROM yearly_entries a
INNER JOIN yearly_counts b
    ON a.icd_in_code = b.icd_in_code
    AND b.year = a.year + 1
    AND b.admissions = a.admissions
ORDER BY a.icd_code, a.year;