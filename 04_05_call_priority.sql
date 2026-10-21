-- File 4**
-- Business question: Among age + past-stays groups with at least 100
-- stays, which 5 have the highest 30-day readmission RATE?

-- Finding: Top group is [20-30) 'some' at 29.67%, followed by [30-40)
-- 'some' at 21.31%. All top 5 are 'some' groups. But the top group is
-- small (600 stays), so high rate alone doesn't mean high impact.

USE sai_practice;
SELECT age,
       IF(number_inpatient = 0, 'none', 'some') AS past_stays,
       COUNT(*) AS total_stays,
       ROUND(100 * AVG(readmitted = '<30'), 2) AS readmit_rate
FROM diabetic_data
GROUP BY age, past_stays
HAVING COUNT(*) >= 100
ORDER BY readmit_rate DESC
LIMIT 5;

-- File 5**
-- Business question: Among the same groups, which 5 have the highest
-- raw NUMBER of 30-day readmissions?
--
-- Finding: Top group is [70-80) 'none' with 1,631 readmissions, purely because it's a huge group (17,065 stays) despite a low 9.56% rate.
-- Raw count alone favors big, low-risk groups over genuinely risky ones.

SELECT age,
       IF(number_inpatient = 0, 'none', 'some') AS past_stays,
       COUNT(*) AS total_stays,
       SUM(readmitted = '<30') AS readmissions,
       ROUND(100 * AVG(readmitted = '<30'), 2) AS readmit_rate
FROM diabetic_data
GROUP BY age, past_stays
HAVING COUNT(*) >= 100
ORDER BY readmissions DESC
LIMIT 5;