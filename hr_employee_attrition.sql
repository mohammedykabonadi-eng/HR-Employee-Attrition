-- HR Employee Attrition Analysis: SQL queries
-- 1. Overall attrition
select count(*)                               as employees,
       sum(Attrition = 'Yes')                 as leavers,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr;

-- 2. By department
select Department,
       count(*)                               as employees,
       sum(Attrition = 'Yes')                 as leavers,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by Department
order by attrition_pct desc;

-- 3. By job role
select JobRole,
       count(*)                               as employees,
       sum(Attrition = 'Yes')                 as leavers,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by JobRole
order by attrition_pct desc;

-- 4. Overtime effect
select OverTime,
       count(*)                               as employees,
       sum(Attrition = 'Yes')                 as leavers,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by OverTime
order by attrition_pct desc;

-- 5. Income quartiles
with banded as (select *, ntile(4) over (order by MonthlyIncome) as income_quartile
                from hr)
select income_quartile,
       min(MonthlyIncome)                     as min_income,
       max(MonthlyIncome)                     as max_income,
       count(*)                               as employees,
       sum(Attrition = 'Yes')                 as leavers,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from banded
group by income_quartile
order by income_quartile;

-- 6. Tenure groups
select case
           when YearsAtCompany <= 1 then '0-1'
           when YearsAtCompany <= 3 then '2-3'
           when YearsAtCompany <= 5 then '4-5'
           when YearsAtCompany <= 10 then '6-10'
           else '10+' end                     as tenure_group,
       count(*)                               as employees,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by tenure_group
order by min(YearsAtCompany);

-- 7. Age groups
select case
           when Age <= 25 then '<=25'
           when Age <= 35 then '26-35'
           when Age <= 45 then '36-45'
           when Age <= 55 then '46-55'
           else '56+' end                     as age_group,
       count(*)                               as employees,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by age_group
order by min(Age);

-- 8. Satisfaction and work-life balance (1 = low, 4 = very high)
select 'JobSatisfaction' as metirc ,JobSatisfaction as score ,
       count(*) as employees,
       round(100 * avg(Attrition = 'Yes'),1) as attrition_pct
from hr
group by JobSatisfaction
union all
select 'WorkLifeBalance' , WorkLifeBalance ,
       count(*),
       round(100 * avg(Attrition = 'Yes'),1)
from hr
group by WorkLifeBalance
union all
select 'EnvironmentSatisfaction',EnvironmentSatisfaction,count(*),
        round(100 * avg(Attrition = 'Yes'),1)
from hr
group by EnvironmentSatisfaction
order by metirc,score;


-- 8. Satisfaction and work-life balance (1 = low, 4 = very high)
SELECT 'JobSatisfaction' AS metric, JobSatisfaction AS score, COUNT(*) AS employees,
       ROUND(100 * AVG(Attrition = 'Yes'), 1) AS attrition_pct
FROM hr GROUP BY JobSatisfaction
UNION ALL
SELECT 'WorkLifeBalance', WorkLifeBalance, COUNT(*),
       ROUND(100 * AVG(Attrition = 'Yes'), 1)
FROM hr GROUP BY WorkLifeBalance
UNION ALL
SELECT 'EnvironmentSatisfaction', EnvironmentSatisfaction, COUNT(*),
       ROUND(100 * AVG(Attrition = 'Yes'), 1)
FROM hr GROUP BY EnvironmentSatisfaction
ORDER BY metric, score;


-- 9. Years since last promotion
select case
           when YearsSinceLastPromotion = 0 then 'this year'
           when YearsSinceLastPromotion <= 2 then '1-2 year'
           when YearsSinceLastPromotion <= 5 then '3-5 year'
           else '5+ year' end           as promotion_gap,
       count(*)                         as employees,
       round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by promotion_gap
order by min(YearsSinceLastPromotion);

-- 10. Job role rate vs company average
select JobRole,
       count(*)                                                                   as employees,
       round(100 * avg(Attrition = 'Yes'), 1)                                     as attrition_pct,
       round(avg(Attrition = 'Yes') / (select avg(Attrition = 'Yes') from hr), 2) as time_company_avg

from hr
group by JobRole
order by time_company_avg desc ;

-- 11. Highest-risk combinations: role x overtime (min 20 employees)

select JobRole
     , OverTime
     , count(*)                               as employees
     , sum(Attrition = 'Yes')                 as leavers
     , round(100 * avg(Attrition = 'Yes'), 1) as attrition_pct
from hr
group by JobRole, OverTime
having count(*) >= 20
order by attrition_pct desc
limit 10;

-- 12. Average profile: leavers vs stayers
select Attrition,
       round(avg(Age), 1)              as avg_age,
       round(avg(MonthlyIncome), 1)    as avg_income,
       round(avg(DistanceFromHome), 1) as avg_distance,
       round(avg(YearsAtCompany), 1)   as avg_tenure,
       round(avg(JobSatisfaction), 2)  as avg_job_sat,
       round(avg(WorkLifeBalance), 2)  as avg_wlb

from hr
group by Attrition;

-- 13. Estimated cost of attrition by department
-- Assumption: replacement cost = 50% of annual salary

select Department,
       sum(Attrition = 'Yes')                                                              as leavers,
       round(sum(case when Attrition = 'Yes' then MonthlyIncome * 12 * 0.5 else 0 end), 0) as est_replacment_cost

from hr
group by Department
order by est_replacment_cost desc ;

-- 14. View for Power BI (one clean, enriched table)
DROP VIEW IF EXISTS hr_powerbi;
select hr.*,
       case when Attrition = 'Yes' then 1 else 0 end as Left_Flag,
       case
           when Age <= 25 then '<=25'
           when Age <= 35 then '26-35'
           when Age <= 45 then '36-45'
           when Age <= 55 then '46-55'
           else '56+' end                            as AgeGroup,
       case
           when YearsAtCompany <= 1 then '0-1'
           when YearsAtCompany <= 3 then '2-3'
           when YearsAtCompany <= 5 then '4-5'
           when YearsAtCompany <= 10 then '6-10'
           else '10+' end                            as TenureGroup,
       case
           when YearsSinceLastPromotion = 0 then 'this year'
           when YearsSinceLastPromotion <= 2 then '1-2 year'
           when YearsSinceLastPromotion <= 5 then '3-5 year'
           else '5+ year' end                        as PromotionGap
from hr;