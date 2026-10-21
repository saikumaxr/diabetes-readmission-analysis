-- Q2: Does the number of past hospital stays change the 30-day readmission rate?
-- Business question: Does the number of past hospital stays
-- (number_inpatient) change the 30-day readmission rate?
--
-- Finding: Yes, strongly. The rate climbs steadily from 8.44% (0 past stays) to 31.40% (5 past stays), roughly a 4x increase. This is a far stronger signal than age.
use sai_practice;

SELECT number_inpatient,
          COUNT(*) AS total_stays,
          ROUND(100.0 * SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmit_rate
FROM diabetic_data
GROUP BY  number_inpatient
ORDER BY number_inpatient;
-- Q3: Among past-stay groups with at least 100 stays, which have the highest 30-day readmission rate?
USE sai_practice;

SELECT number_inpatient,
       COUNT(*) AS total_stays,
       ROUND(100.0 * SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmit_rate
FROM diabetic_data
GROUP BY number_inpatient
HAVING COUNT(*) >= 100
ORDER BY number_inpatient;


