-- Business question: How much of the data is missing, and does it
-- affect the columns we've used so far (age, number_inpatient, readmitted)?

USE sai_practice;

SELECT COUNT(*) AS total_rows,
       ROUND(100 * AVG(weight = '?'), 1) AS weight_missing_pct,
       ROUND(100 * AVG(payer_code = '?'), 1) AS payer_code_missing_pct,
       ROUND(100 * AVG(medical_specialty = '?'), 1) AS specialty_missing_pct,
       ROUND(100 * AVG(race = '?'), 1) AS race_missing_pct
FROM diabetic_data;

-- Confirm the columns we actually used have no missing values.
SELECT
    SUM(age = '?') AS age_missing,
    SUM(number_inpatient IS NULL) AS past_stays_missing,
    SUM(readmitted = '?') AS readmitted_missing
FROM diabetic_data;