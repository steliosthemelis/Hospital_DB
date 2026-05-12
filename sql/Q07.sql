SELECT 
    a.substance_name,
    a.substance_id,
    COUNT(DISTINCT pa.Patient_AMKA) AS num_of_patients,
    COUNT(DISTINCT das.DRUG_drug_id) AS num_of_drugs
FROM 
    Active_Substance a
    LEFT JOIN Patient_Allergy pa ON a.substance_id = pa.Active_Substance_substance_id
    LEFT JOIN DRUG_has_Active_Substance dhas ON a.substance_id = dhas.Active_Substance_substance_id
GROUP BY
    a.substance_id, a.substance_name
ORDER BY
    num_of_patients DESC,
    num_of_drugs DESC;