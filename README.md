
# Reducing 30-Day Readmissions in Diabetic Patients

**A SQL analysis (MySQL) to help an insurer's care-management team decide which discharged diabetic patients to call first.**

---

## The Business Problem

After a diabetic patient is discharged from hospital, some are readmitted within 30 days. This is bad for the patient and expensive for the insurer who pays the bills.

The insurer's care-management team can only call a limited number of discharged patients. So the question is:

> **Which patient groups have the highest risk of 30-day readmission, so the team knows who to prioritize?**

In this project I play a Data Analyst supporting that team. The output is a **rule** the team can apply to future discharges, not a list of named patients.

## Dataset

[UCI "Diabetes 130-US Hospitals (1999-2008)"](https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008)

- 101,766 hospital stays, 71,518 unique patients, 50 columns
- Baseline: about 11.2% of stays were readmitted within 30 days (11,357 of 101,766)
- The raw CSV is not included in this repo. Download it from the link above.

## Key Finding

**Patients aged 60-80 who had at least one hospital stay in the previous year are the best group to prioritize.**

They combine a high readmission rate (about 16%, versus 11.2% overall) with large group sizes (7,000-9,000 stays each). That means calling them can prevent the most readmissions, not just reach a few high-risk people.

| Age band | Past-year stays | Total stays | Readmissions (<30 days) | Rate | Rate rank | Count rank | Combined score |
|---|---|---|---|---|---|---|---|
| [70-80) | some | 9,003 | 1,438 | 15.97% | 5 | 2 | **7** |
| [60-70) | some | 7,426 | 1,228 | 16.54% | 4 | 4 | **8** |
| [40-50) | some | 3,153 | 569 | 18.05% | 3 | 9 | 12 |
| [70-80) | none | 17,065 | 1,631 | 9.56% | 12 | 1 | 13 |
| [80-90) | some | 6,160 | 959 | 15.57% | 7 | 6 | 13 |

Lower combined score is better.

## How I Got There

Each SQL file answers one question and builds on the last.

| # | File | Question | Result |
|---|---|---|---|
| 1 | `01_readmission_by_age.sql` | Does age alone predict readmission? | Barely. Adult bands sit between 9.7% and 12.1%. |
| 2 | `02_readmission_by_past_stays.sql` | Do past-year hospital stays predict it? | Strongly. The rate rises from 8.44% (0 past stays) to 31.40% (5 past stays), about 4x. |
| 3 | `03_age_and_past_stays.sql` | Does that hold within each age band? | Yes, in every band. The gap is biggest in young adults ([20-30): 5.49% vs 29.67%) and smaller in older ones ([70-80): 9.56% vs 15.97%). |
| 4 | `04_call_first_list.sql` | Which groups have the highest **rate**? | [20-30) with past stays tops the list at 29.67%, but it has only 600 stays. |
| 5 | `05_biggest_opportunity.sql` | Which groups have the most **readmissions**? | [70-80) with no past stays tops the list at 1,631, but only because the group is huge (17,065 stays) and its rate is a low 9.56%. |
| 6 | `06_combined_ranking.sql` | Which groups are strong on **both**? | [70-80) and [60-70) with past stays (see the table above). |
| 7 | `07_missing_values.sql` | Is missing data affecting the results? | No. `age`, `number_inpatient` and `readmitted` have zero missing values. |

### Why rate alone or count alone is not enough

- Ranking by **rate** favors small groups. A 30% rate in a group of 600 reaches few people.
- Ranking by **count** favors big groups that are mostly low-risk. Most calls to them would be wasted.
- Per 1,000 calls, the [70-80) "some" group reaches about 160 patients who would be readmitted, against about 96 for the [70-80) "none" group.
- The combined ranking in file 6 balances both.

## SQL Techniques Used

- Filtering and aggregation: `WHERE`, `GROUP BY`, `COUNT`, `SUM`, `AVG`
- Conditional logic: `CASE WHEN`, `IF`
- Group-level filtering with `HAVING COUNT(*) >= 100`, so tiny groups with unreliable rates are excluded
- CTE (`WITH`) and window function (`RANK() OVER`) for the combined ranking
- Data quality checks for missing values

## How to Reproduce

1. Download `diabetic_data.csv` from the UCI link above.
2. Run `01` to `07` in order. Window functions need MySQL 8.0 or newer.

## Limitations

- **The data is old (1999-2008).** Patterns may not hold for today's patients or treatments.
- **This shows association, not causation.** Patients with past stays are more likely to be readmitted, but this analysis does not show why.
- **Rows are stays, not patients.** 71,518 unique patients account for 101,766 rows, so one patient can appear several times, and rates are per stay.
- **The combined score is a simple heuristic.** It adds the rate rank and the count rank with equal weight. A different weighting could reorder the groups.
- **Age bands are broad (10 years) and past stays are grouped as "none" or "some".** Finer groups could separate risk more sharply.
- **Some columns were not used.** `weight` (96.9% missing), `medical_specialty` (49.1%) and `payer_code` (39.6%) are too incomplete to rely on.
- **No claim about penalties or cost savings.** The data has no cost information, so the analysis does not estimate financial impact.

## Possible Next Steps

- Join the admission and discharge lookup tables from `IDS_mapping.csv` to test whether admission type adds signal.
- Add more risk factors, such as number of diagnoses, medications or emergency visits.
- Build a predictive model (for example logistic regression) and compare it with this rule-based approach.

---

**Author:** Sai Kumar, BSc Data Science and Data Analytics Engineering, Loyola Academy
