# Diabetes Readmission Analysis

## Business Problem

Hospital readmissions within 30 days are costly and often preventable. This project puts me in the role of a data analyst supporting an insurer's care-management team, who need to decide which discharged diabetic patients to prioritize for follow-up calls to prevent readmission.

The analysis is done in two stages: first an exploratory SQL analysis to find the key risk factors, then a predictive model in Python to test whether those factors can actually forecast risk and drive a real business decision.

## Dataset

UCI "Diabetes 130-US Hospitals (1999-2008)" dataset: 101,766 hospital stays across 71,518 unique patients. Key columns used: `age` (10-year bands), `number_inpatient` (past-year inpatient stays), `readmitted` ('NO' / '>30' / '<30'), `patient_nbr`, `encounter_id`.

## Part 1: SQL Analysis (MySQL)

| File | Question | Key Finding |
|---|---|---|
| 01_readmission_by_age.sql | Does age predict readmission? | Barely. Adult bands cluster between 9.7% and 12.1%. |
| 02_readmission_by_past_stays.sql | Do past inpatient stays predict readmission? | Strongly. Rate climbs from 8.44% (0 past stays) to 31.40% (5 past stays), roughly 4x. |
| 03_age_and_past_stays.sql | Does the past-stays effect hold across every age group? | Yes, in every age band, though it narrows with age. |
| 04_call_first_list.sql | Who should be called first, by rate? | [20-30) with past stays: 29.67%, but a small, low-confidence group (600 stays). |
| 05_biggest_opportunity.sql | Who should be called first, by raw count? | [70-80) with no past stays: 1,631 readmissions, but a low 9.56% rate. |
| 06_combined_ranking.sql | How do we balance rate and count? | Using window functions to rank by both: ages 60-80 with past stays are the best overall targets, 15-17% rate across 7,000-9,000 stays. |
| 07_missing_values.sql | Is the data trustworthy? | Yes, for the columns used. `age`, `number_inpatient`, `readmitted` have 0% missing. (`weight` is 96.9% missing and unusable.) |

**SQL techniques used:** aggregate functions, CASE/IF logic, GROUP BY with HAVING, CTEs, window functions (RANK() OVER).

## Part 2: Predictive Model (Python, Logistic Regression)

Extended the analysis by building a logistic regression model in Python (Google Colab) using the two predictors identified in the SQL analysis: past inpatient stays and age band.

**Methodology:**
- Split data into training (80%) and test (20%) sets, grouped by `patient_nbr` so no patient's stays appear in both sets (prevents data leakage).
- Trained a logistic regression model on the training set only.
- Evaluated on the held-out test set using accuracy and AUC.

**Results:**
- Accuracy: 89.3% — but misleading, since always guessing "no readmission" scores nearly identically (89.3%), because only ~11% of stays are actually readmitted.
- AUC: 0.616 — meaningfully better than random guessing (0.5), showing the model has real, if modest, predictive signal.
- **Business test:** calling only the top 20% highest-risk patients (as ranked by the model) would catch 34% of all actual readmissions, nearly double the 20% you'd catch by calling patients at random.
- **Feature impact:** each additional past inpatient stay increases a patient's odds of readmission by ~33%. Age band has almost no effect, consistent with the SQL findings.

## Why Rate-Alone and Count-Alone Both Fail

Ranking purely by readmission rate surfaces small, statistically fragile groups. Ranking purely by raw count surfaces large groups with unremarkable rates. Combining both, via ranked window functions in SQL, and via a model-based risk score in Python, gives a more defensible, balanced answer.

## Limitations

- Data covers 1999-2008; patterns may not reflect current clinical practice.
- All findings show association, not causation.
- Rows represent hospital stays, not unique patients (one patient may have multiple stays).
- `weight`, `payer_code`, and `medical_specialty` were too sparse to use reliably.
- The model uses only 2 predictors; a production model would include many more clinical and demographic features.

## Possible Next Steps

- Add more predictors (diagnoses, medications, lab results) to the model.
- Try additional modeling approaches to compare performance.
- Build a dashboard for the care-management team to use operationally.

## Reproduction

1. Load `diabetic_data.csv` into MySQL as table `diabetic_data`.
2. Run SQL files 01 through 07 in order.
3. Open `diabetes_readmission_model.ipynb` in Google Colab, upload the same CSV, and run all cells in order.
