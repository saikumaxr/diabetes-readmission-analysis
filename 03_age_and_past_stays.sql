-- Business question: Within each age band, do patients with past
-- stays return more often than patients with none?
--
-- Finding: Yes, in every age band. But the gap narrows with age, e.g.
-- age [20-30): 'none' 5.49% vs 'some' 29.67% (large gap); age [70-80):
-- 'none' 9.56% vs 'some' 15.97% (smaller gap). Past stays matter at
-- every age, most dramatically in younger patients.

USE sai_practice;

SELECT age,
       IF(number_inpatient = 0, 'none', 'some') AS past_stays,
       COUNT(*) AS total_stays,
       ROUND(100 * AVG(readmitted = '<30'), 2) AS readmit_rate
FROM diabetic_data
GROUP BY age, past_stays
ORDER BY age, past_stays;