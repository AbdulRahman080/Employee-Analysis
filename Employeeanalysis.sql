-- Query 1: Average Satisfaction Scores by Department using CTE and Window Functions
-- Calculates the average satisfaction score per employee and compares it to the average satisfaction score within their department.
WITH AvgSatisfaction AS (
    SELECT 
        g.Department,
        es.EmployeeID,
        (es.JobSatisfaction + es.EnvironmentSatisfaction + es.WorkLifeBalance) / 3.0 AS AvgSatisfactionScore
    FROM 
        general_data g
    JOIN 
        employee_survey_data es ON g.EmployeeID = es.EmployeeID
)
SELECT 
    Department,
    EmployeeID,
    AvgSatisfactionScore,
    AVG(AvgSatisfactionScore) OVER (PARTITION BY Department) AS DeptAvgSatisfactionScore
FROM 
    AvgSatisfaction
ORDER BY 
    Department, AvgSatisfactionScore DESC;

-- Query 2: Categorizing Employees Based on Years at Company using CASE Statement
-- Categorizes employees into different experience levels based on their years at the company.
SELECT 
    EmployeeID,
    Age,
    JobRole,
    YearsAtCompany,
    CASE
        WHEN YearsAtCompany < 2 THEN 'New'
        WHEN YearsAtCompany BETWEEN 2 AND 5 THEN 'Intermediate'
        ELSE 'Experienced'
    END AS ExperienceLevel
FROM 
    general_data
ORDER BY 
    YearsAtCompany;

-- Query 3: Identifying Top Performers in Each Department using Subquery
-- Identifies the top performers in each department by using a subquery to find the highest performance rating within each department.
SELECT 
    g.EmployeeID,
    g.Department,
    g.JobRole,
    ms.PerformanceRating
FROM 
    general_data g
JOIN 
    manager_survey_data ms ON g.EmployeeID = ms.EmployeeID
WHERE 
    ms.PerformanceRating = (
        SELECT 
            MAX(ms2.PerformanceRating)
        FROM 
            manager_survey_data ms2
        JOIN 
            general_data g2 ON ms2.EmployeeID = g2.EmployeeID
        WHERE 
            g2.Department = g.Department
    )
ORDER BY 
    g.Department, ms.PerformanceRating DESC;

-- Query 4: Ranking Employees by Attrition Risk using CTE and Window Function
-- Ranks employees within each department based on their risk of attrition, using a combination of satisfaction scores.
WITH AttritionRisk AS (
    SELECT 
        g.EmployeeID,
        g.Department,
        g.JobRole,
        es.JobSatisfaction,
        es.EnvironmentSatisfaction,
        es.WorkLifeBalance,
        CASE
            WHEN es.JobSatisfaction <= 2 THEN 1 ELSE 0 END +
        CASE
            WHEN es.EnvironmentSatisfaction <= 2 THEN 1 ELSE 0 END +
        CASE
            WHEN es.WorkLifeBalance <= 2 THEN 1 ELSE 0 END AS RiskScore
    FROM 
        general_data g
    JOIN 
        employee_survey_data es ON g.EmployeeID = es.EmployeeID
)
SELECT 
    EmployeeID,
    Department,
    JobRole,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    RiskScore,
    RANK() OVER (PARTITION BY Department ORDER BY RiskScore DESC) AS AttritionRiskRank
FROM 
    AttritionRisk
ORDER BY 
    Department, AttritionRiskRank;

-- Query 5: Average Training Times by Department and Tenure using CTE and Aggregation
-- Calculates the average number of training sessions attended by employees in different tenure categories within each department.
WITH AvgTraining AS (
    SELECT 
        Department,
        CASE
            WHEN YearsAtCompany < 2 THEN '0-2 Years'
            WHEN YearsAtCompany BETWEEN 2 AND 5 THEN '2-5 Years'
            ELSE '5+ Years'
        END AS Tenure,
        AVG(TrainingTimesLastYear) AS AvgTrainingTimes
    FROM 
        general_data
    GROUP BY 
        Department, Tenure
)
SELECT 
    Department,
    Tenure,
    AvgTrainingTimes
FROM 
    AvgTraining
ORDER BY 
    Department, Tenure;

-- Query 6: Employees with High Job Involvement and Performance Ratings using Subquery
-- Identifies employees with the highest levels of job involvement and performance ratings.
SELECT 
    g.EmployeeID,
    g.JobRole,
    g.Department,
    g.Age,
    ms.JobInvolvement,
    ms.PerformanceRating
FROM 
    general_data g
JOIN 
    manager_survey_data ms ON g.EmployeeID = ms.EmployeeID
WHERE 
    ms.JobInvolvement = 4 AND ms.PerformanceRating = 4
ORDER BY 
    g.Department, g.JobRole;

-- Query 7: Average Age of Employees by Gender and Department
-- Calculates the average age of employees by gender and department.
SELECT 
    Department,
    Gender,
    AVG(Age) AS AvgAge
FROM 
    general_data
GROUP BY 
    Department, Gender
ORDER BY 
    Department, Gender;

-- Query 8: Average Distance from Home by Business Travel Frequency using CTE
-- Finds the average distance from home for employees based on their business travel frequency.
WITH AvgDistance AS (
    SELECT 
        BusinessTravel,
        AVG(DistanceFromHome) AS AvgDistanceFromHome
    FROM 
        general_data
    GROUP BY 
        BusinessTravel
)
SELECT 
    BusinessTravel,
    AvgDistanceFromHome
FROM 
    AvgDistance
ORDER BY 
    AvgDistanceFromHome DESC;
