SELECT
    d.dept_id AS department,
    YEAR(h.entry_date) AS year,
    h.KEN_ken_code AS ken_code,
    p.insurance_type,
    COUNT(*) AS hospitalization_count,
    SUM(k.base_cost) AS total_base_cost,
    SUM(
        CASE
            WHEN DATEDIFF(h.exit_date, h.entry_date) > k.avg_stay_days THEN (
                DATEDIFF(h.exit_date, h.entry_date) - k.avg_stay_days
            ) * k.extra_day_rate
            ELSE 0
        END
    ) AS total_extra_day_cost,
    SUM(k.base_cost) + SUM(
        CASE
            WHEN DATEDIFF(h.exit_date, h.entry_date) > k.avg_stay_days THEN (
                DATEDIFF(h.exit_date, h.entry_date) - k.avg_stay_days
            ) * k.extra_day_rate
            ELSE 0
        END
    ) AS total_revenue
FROM
    Hospitalization h
    JOIN BEDS b ON h.BEDS_bed_id = b.bed_id
    AND h.BEDS_Department_dept_id = b.Department_dept_id
    JOIN Department d ON b.Department_dept_id = d.dept_id
    JOIN KEN k ON h.KEN_ken_code = k.ken_code
    JOIN Patient p ON h.Patient_AMKA = p.AMKA
GROUP BY
    d.dept_id,
    YEAR(h.entry_date),
    h.KEN_ken_code,
    p.insurance_type

