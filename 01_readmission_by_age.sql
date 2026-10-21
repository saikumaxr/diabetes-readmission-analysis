-- Business question: Does the 30-day readmission rate differ by age
-- band, and which band is highest?
-- Finding: Barely. All adult age bands cluster tightly between 9.7% and 12.1%. [20-30) is highest at 14.24%, but that group is small
-- (1,657 stays), so it's low-confidence. Age alone doesn't separate
-- high-risk from low-risk patients.

-- Question 1 : Does the 30-day readmission rate differ by age band, and which band is highest?
SELECT COUNT(*)
FROM diabetic_data;

-- 2. Check for duplicate rows. Both numbers should match. 
SELECT COUNT(*), COUNT(DISTINCT encounter_id)
FROM diabetic_data;

-- 3. Count unique patients (fewer than rows, since some patients have several stays).
SELECT COUNT(DISTINCT patient_nbr)
FROM diabetic_data;

-- 4. Look at the first 5 rows
SELECT *
FROM diabetic_data
LIMIT 5;

-- 5. Count stays for each readmitted value.
SELECT readmitted, COUNT(*)
FROM diabetic_data
GROUP BY readmitted;


-- PART 2: FILTER WITH WHERE

-- 6. Stays that came back within 30 days. 
SELECT COUNT(*)
FROM diabetic_data
WHERE readmitted = '<30';

-- 7. Stays in the 70 to 80 age band.
SELECT COUNT(*)
FROM diabetic_data
WHERE age = '[70-80)';

-- 8. Stays longer than 7 days (number column, no quotes). 
SELECT COUNT(*)
FROM diabetic_data
WHERE time_in_hospital > 7;

-- 9. Age band 70 to 80 AND readmitted within 30 days (AND joins different columns).
SELECT COUNT(*)
FROM diabetic_data
WHERE age = '[70-80)' AND readmitted = '<30';


-- PART 3: GROUP BY (one result row per group)

-- 10. Total stays in each age band.
SELECT age, COUNT(*)
FROM diabetic_data
GROUP BY age;

-- 11. Readmissions within 30 days in each age band.
SELECT age, COUNT(*)
FROM diabetic_data
WHERE readmitted = '<30'
GROUP BY age;


-- PART 4: SUM(CASE ...) counts matching rows and keeps all rows
-- Template: SUM(CASE WHEN <condition> THEN 1 ELSE 0 END) AS <name>

-- 12. Readmissions and total stays side by side. 
SELECT age,
       SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_30,
       COUNT(*) AS total_stays
FROM diabetic_data
GROUP BY age;

-- 13. Practice: long stays (over 7 days) per age band.
SELECT age,
       SUM(CASE WHEN time_in_hospital > 7 THEN 1 ELSE 0 END) AS long_stays
FROM diabetic_data
GROUP BY age;


-- PART 5: THE RESULT. Rate = readmissions / total stays x 100

-- 14. 30-day readmission rate (%) for each age band.
SELECT age,
       ROUND(100.0 * SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmit_rate
FROM diabetic_data
GROUP BY age;