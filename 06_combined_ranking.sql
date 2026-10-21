-- Business question: Which age + past-stays groups should the care team
-- call first, considering BOTH readmission rate and number of readmissions?
--
-- Finding: [70-80) 'some' and [60-70) 'some' rank best overall, balancing a solid rate (~16%) with a large enough group size (7,000-9,000 stays)
-- to meaningfully reduce total readmissions. Ranking by rate alone favors tiny groups (file 4); ranking by count alone favors huge low-rate groups
-- (file 5). This combined ranking avoids both extremes.

USE sai_practice;

WITH risk_groups AS (
    SELECT age,
           IF(number_inpatient = 0, 'none', 'some') AS past_stays,
           COUNT(*) AS total_stays,
           SUM(readmitted = '<30') AS readmissions,
           ROUND(100 * AVG(readmitted = '<30'), 2) AS readmit_rate
    FROM diabetic_data
    GROUP BY age, past_stays
    HAVING COUNT(*) >= 100
)
SELECT age, past_stays, total_stays, readmissions, readmit_rate,
       RANK() OVER (ORDER BY readmit_rate DESC) AS rate_rank,
       RANK() OVER (ORDER BY readmissions DESC) AS count_rank,
       RANK() OVER (ORDER BY readmit_rate DESC)
         + RANK() OVER (ORDER BY readmissions DESC) AS combined_score
FROM risk_groups
ORDER BY combined_score ASC
LIMIT 5;