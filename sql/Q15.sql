-- Q15: Κατανομή triage ανά επίπεδο επείγοντος (referrals σε ξεχωριστές γραμμές)
WITH triage_stats AS (
    SELECT 
        t.urgency_level,
        COUNT(*) AS total_cases,
        ROUND(AVG(CASE 
            WHEN t.Hospitalization_hosp_id IS NOT NULL 
            THEN TIMESTAMPDIFF(MINUTE, t.arrival_time, h.entry_date)
            ELSE NULL 
        END), 2) AS avg_wait_minutes,
        ROUND(SUM(CASE WHEN t.Hospitalization_hosp_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS hospitalization_percentage
    FROM Triage t
    LEFT JOIN Hospitalization h ON t.Hospitalization_hosp_id = h.hosp_id
    GROUP BY t.urgency_level
),
referrals AS (
    SELECT 
        t.urgency_level,
        h.BEDS_Department_dept_id AS department_id,
        COUNT(*) AS referrals_count
    FROM Triage t
    JOIN Hospitalization h ON t.Hospitalization_hosp_id = h.hosp_id
    GROUP BY t.urgency_level, h.BEDS_Department_dept_id
)
SELECT 
    ts.urgency_level,
    ts.total_cases,
    ts.avg_wait_minutes,
    ts.hospitalization_percentage,
    r.department_id,
    r.referrals_count
FROM triage_stats ts
LEFT JOIN referrals r ON ts.urgency_level = r.urgency_level
ORDER BY ts.urgency_level, r.referrals_count DESC;