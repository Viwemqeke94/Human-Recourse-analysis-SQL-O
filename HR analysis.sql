-- Initial Data Quality Check
SELECT 
    COUNT(*) as total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) as attrition_rate
FROM employees;

-- Check for Null values
SELECT 
    COUNT(*) - COUNT(Department) as null_department,
    COUNT(*) - COUNT(JobRole) as null_jobrole,
    COUNT(*) - COUNT(MonthlyIncome) as null_income,
    COUNT(*) - COUNT(YearsAtCompany) as null_years,
    COUNT(DISTINCT Department) as unique_departments,
    COUNT(DISTINCT JobRole) as unique_jobroles,
    COUNT(DISTINCT EducationField) as unique_edufields
FROM employees;

-- Data Cleaning
SELECT 
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS null_department,
    SUM(CASE WHEN JobRole IS NULL THEN 1 ELSE 0 END) AS null_jobrole,
    SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END) AS null_income,
    SUM(CASE WHEN YearsAtCompany IS NULL THEN 1 ELSE 0 END) AS null_years,
    
    COUNT(DISTINCT Department) AS unique_departments,
    COUNT(DISTINCT JobRole) AS unique_jobroles,
    COUNT(DISTINCT EducationField) AS unique_edufields
FROM employees;

-- Create backup table
CREATE TABLE employees_backup AS SELECT * FROM
    employees;


 -- Attrition Analysis by Department
SELECT 
    Department,
    COUNT(*) as total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) as attrition_rate,
    ROUND(AVG(JobSatisfaction), 2) as avg_job_satisfaction,
    ROUND(AVG(MonthlyIncome), 2) as avg_monthly_income
FROM employees
GROUP BY Department
ORDER BY attrition_rate DESC;

-- Salary Analysis
SELECT 
    JobRole,
    Department,
    COUNT(*) as employee_count,
    ROUND(AVG(MonthlyIncome), 2) as avg_monthly_income,
    ROUND(MIN(MonthlyIncome), 2) as min_monthly_income,
    ROUND(MAX(MonthlyIncome), 2) as max_monthly_income,
    ROUND(AVG(PercentSalaryHike), 2) as avg_salary_hike
FROM employees
GROUP BY JobRole, Department
ORDER BY avg_monthly_income DESC;

-- Experience and Tenure Analysis
SELECT 
    JobRole,
    ROUND(AVG(TotalWorkingYears), 2) as avg_total_experience,
    ROUND(AVG(YearsAtCompany), 2) as avg_company_tenure,
    ROUND(AVG(YearsInCurrentRole), 2) as avg_role_tenure,
    ROUND(AVG(YearsSinceLastPromotion), 2) as avg_years_since_promotion,
    ROUND(AVG(YearsWithCurrManager), 2) as avg_years_with_manager
FROM employees
GROUP BY JobRole
ORDER BY avg_total_experience DESC;

-- Satisfaction Metrics Analysis
SELECT 
    Department,
    JobRole,
    ROUND(AVG(JobSatisfaction), 2) as avg_job_satisfaction,
    ROUND(AVG(EnvironmentSatisfaction), 2) as avg_env_satisfaction,
    ROUND(AVG(WorkLifeBalance), 2) as avg_work_life_balance,
    ROUND(AVG(RelationshipSatisfaction), 2) as avg_relationship_satisfaction
FROM employees
GROUP BY Department, JobRole
ORDER BY Department, avg_job_satisfaction DESC;

--  Attrition Risk Factors Analysis
WITH AttritionFactors AS (
    SELECT 
        CASE 
            WHEN YearsSinceLastPromotion >= 7 THEN 'High'
            WHEN YearsSinceLastPromotion >= 4 THEN 'Medium'
            ELSE 'Low'
        END as promotion_gap,
        CASE 
            WHEN JobSatisfaction <= 2 THEN 'Low'
            WHEN JobSatisfaction = 3 THEN 'Medium'
            ELSE 'High'
        END as satisfaction_level,
        CASE 
            WHEN MonthlyIncome < (SELECT AVG(MonthlyIncome) FROM employees) THEN 'Below Average'
            ELSE 'Above Average'
        END as salary_category,
        Attrition
    FROM employees
)
SELECT 
    promotion_gap,
    satisfaction_level,
    salary_category,
    COUNT(*) as total_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) as attrition_rate
FROM AttritionFactors
GROUP BY promotion_gap, satisfaction_level, salary_category
ORDER BY attrition_rate DESC;

-- Work-Life Balance Impact
SELECT 
    WorkLifeBalance,
    COUNT(*) as employee_count,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) as attrition_rate,
    ROUND(AVG(JobSatisfaction), 2) as avg_job_satisfaction,
    ROUND(AVG(MonthlyIncome), 2) as avg_monthly_income,
    ROUND(AVG(TotalWorkingYears), 2) as avg_working_years
FROM employees
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

-- Career Development Analysis
SELECT 
    Department,
    JobLevel,
    ROUND(AVG(TrainingTimesLastYear), 2) as avg_training_times,
    ROUND(AVG(YearsSinceLastPromotion), 2) as avg_years_since_promotion,
    COUNT(*) as employee_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count
FROM employees
GROUP BY Department, JobLevel
ORDER BY Department, JobLevel;

-- Create view for dashboard reporting
CREATE VIEW vw_employee_summary AS
SELECT 
    Department,
    JobRole,
    COUNT(*) as total_employees,
    ROUND(AVG(MonthlyIncome), 2) as avg_salary,
    ROUND(AVG(YearsAtCompany), 2) as avg_tenure,
    ROUND(AVG(JobSatisfaction), 2) as avg_satisfaction,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) as attrition_rate
FROM employees
GROUP BY Department, JobRole;

-- Export summary for visualization
SELECT 
    Department,
    JobRole,
    Gender,
    MaritalStatus,
    EducationField,
    AVG(MonthlyIncome) as avg_income,
    AVG(YearsAtCompany) as avg_tenure,
    AVG(JobSatisfaction) as avg_satisfaction,
    COUNT(*) as employee_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count
FROM employees
GROUP BY Department, JobRole, Gender, MaritalStatus, EducationField
ORDER BY Department, JobRole;

SELECT 
    Department,
    JobRole,
    Gender,
    MaritalStatus,
    EducationField,
    CAST(AVG(MonthlyIncome) AS DECIMAL(10,2)) as avg_income, 
    AVG(YearsAtCompany) as avg_tenure,
    AVG(JobSatisfaction) as avg_satisfaction,
    COUNT(*) as employee_count,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as attrition_count
FROM employees
GROUP BY Department, JobRole, Gender, MaritalStatus, EducationField
ORDER BY Department, JobRole;

