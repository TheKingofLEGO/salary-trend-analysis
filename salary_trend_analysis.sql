/*
PROJECT: Salary Trend Analysis by Job Category

GOAL:
Analyze how salaries change over time for each job category by:
1) Comparing each year's total salary to the category average
2) Comparing each year's total salary to the previous year

This analysis helps identify salary growth, decline, and stability trends
in a clear, business-friendly way.
*/

-- STEP 1:
-- Calculate the total salary for each job category per year.
-- This creates a clean dataset that can be reused for comparisons.
WITH yearly_salary_totals AS (
    SELECT
        work_year AS year,
        job_category AS job_category,
        SUM(salary_in_USD) AS total_salary
    FROM salary
    GROUP BY work_year, job_category
)

-- STEP 2:
-- Use window functions to compare each year’s salary
-- to the category average and the previous year.
SELECT
    year,
    job_category,
    total_salary,

    -- Average salary across all years for each job category
    AVG(total_salary) OVER (PARTITION BY job_category) AS avg_category_salary,

    -- Difference between current year salary and category average
    total_salary - AVG(total_salary) OVER (PARTITION BY job_category) AS diff_from_avg,

    -- Label whether the salary is above, below, or at the average
    CASE
        WHEN total_salary > AVG(total_salary) OVER (PARTITION BY job_category) THEN 'Above Average'
        WHEN total_salary < AVG(total_salary) OVER (PARTITION BY job_category) THEN 'Below Average'
        ELSE 'At Average'
    END AS avg_comparison,

    -- Salary from the previous year for the same job category
    LAG(total_salary) OVER (
        PARTITION BY job_category
        ORDER BY year
    ) AS previous_year_salary,

    -- Difference between current year and previous year
    total_salary - LAG(total_salary) OVER (
        PARTITION BY job_category
        ORDER BY year
    ) AS year_over_year_difference,

    -- Label whether salary increased, decreased, or stayed the same
    CASE
        WHEN total_salary > LAG(total_salary) OVER (PARTITION BY job_category ORDER BY year) THEN 'Increase'
        WHEN total_salary < LAG(total_salary) OVER (PARTITION BY job_category ORDER BY year) THEN 'Decrease'
        ELSE 'No Change'
    END AS year_over_year_trend

FROM yearly_salary_totals
ORDER BY job_category, year;
