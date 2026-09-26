[README (1).md](https://github.com/user-attachments/files/32681507/README.1.md)
# HR Employee Attrition Analysis

## Business question
Which factors drive employees to leave, and which groups should HR target first to reduce attrition?

## Data source
IBM HR Analytics Employee Attrition & Performance dataset (Kaggle) — 1,500 employees, 29 fields including department, job role, income, tenure, overtime status, and satisfaction scores.

*Note: for the version of this project built while learning, a synthetic dataset with the same structure and realistic, built-in relationships was used for practice. For a live portfolio submission, rerun this same process on the real Kaggle dataset and replace the numbers below with your own findings.*

## Method
1. **Excel** — initial pivot tables to explore attrition rate by department, job role, and overtime.
2. **SQL** (MySQL) — 14 queries covering department, job role, income quartiles, tenure groups, age groups, satisfaction scores, promotion gap, and estimated cost of attrition. A `hr_powerbi` view was created to feed the dashboard.
3. **Power BI** — a 3-page interactive dashboard:
   - **Overview & Trends** — company KPIs, overtime split, attrition by job role, and two trend lines (tenure stage, age group).
   - **Relationships** — a heatmap matrix of age band × income band, and a treemap of headcount by department and job role.
   - **Action** — a ranked table of the highest-risk job role × overtime combinations, cost-of-attrition cards by department, and recommendations.

## Key findings

1. **New, young, and overworked employees are the highest flight risk.**
   Attrition falls sharply with tenure (16.3% in year 0-1 down to 4.8% at 10+ years) and with age (18.5% for employees 25 and under down to 4.5% for ages 46-55). The risk is concentrated in the first two years of employment.

2. **Overtime is the single strongest driver.**
   Employees working overtime leave at 20.7%, more than 4x the 5.0% rate for those who don't. The worst combination in the dataset is **Sales Representatives working overtime, at 36.7% attrition** — over 4x the company average of 8.9%.

3. **Age and income compound each other.**
   The riskiest segment is employees under 26 in the lowest income quartile, at **33.3% attrition** — nearly 4x the company average. By age 36+, attrition drops below 8% almost regardless of income.

## Estimated cost of attrition
Using a 50%-of-annual-salary replacement cost assumption:
- Sales: ~$2.21M
- Research & Development: ~$4.14M
- Human Resources: ~$0.38M
- **Total: ~$6.72M**

## Recommendations
1. Cap or review overtime in Sales Representative and Laboratory Technician roles, where attrition is 3-4x the company average.
2. Review pay and onboarding for employees under 26 in the lowest income quartile — this group reaches 33.3% attrition.
3. Add a retention checkpoint at the one-year mark, since attrition peaks at 16.3% in year one before dropping sharply after year four.

## Dashboard
See screenshots in `/screenshots` (add your own exported images from Power BI: Overview & Trends, Relationships, Action).

## How to reproduce
1. Load `hr_employee_attrition.csv` (or the real Kaggle dataset) into MySQL using `hr_attrition_queries_mysql.sql`.
2. Run the 14 queries to reproduce each finding.
3. Connect Power BI to the `hr_powerbi` view (or the Excel workbook `HR_Attrition_Analysis.xlsx`).
4. Rebuild the measures: `Employees`, `Leavers`, `Attrition Rate`, `Est Replacement Cost`.
5. Recreate the 3 dashboard pages as described above.

## Tools
Excel, MySQL, Power BI
