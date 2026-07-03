-- Create the database
CREATE DATABASE IF NOT EXISTS crime_statistics;
USE crime_statistics_2025;

-- Create the crime statistics table
CREATE TABLE IF NOT EXISTS crime_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year int(20) NOT NULL,
    month VARCHAR(20) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    dacoity INT DEFAULT 0,
    robbery INT DEFAULT 0,
    murder INT DEFAULT 0,
    speedy_trial INT DEFAULT 0,
    riot INT DEFAULT 0,
    woman_child_repression INT DEFAULT 0,
    kidnapping INT DEFAULT 0,
    police_assault INT DEFAULT 0,
    burglary INT DEFAULT 0,
    theft INT DEFAULT 0,
    other_cases INT DEFAULT 0,
    recovery_cases INT DEFAULT 0,
    total_cases INT DEFAULT 0
);



-- 1. TOtal Monthly Summary Report
SELECT 
    month,
    SUM(dacoity) as total_dacoity,
    SUM(robbery) as total_robbery,
    SUM(murder) as total_murder,
    SUM(speedy_trial) as total_speedy_trial,
    SUM(riot) as total_riot,
    SUM(woman_child_repression) as total_woman_child_repression,
    SUM(kidnapping) as total_kidnapping,
    SUM(police_assault) as total_police_assault,
    SUM(burglary) as total_burglary,
    SUM(theft) as total_theft,
    SUM(other_cases) as total_other_cases,
    SUM(recovery_cases) as total_recovery_cases,
    SUM(total_cases) as grand_total_cases
FROM crime_data
GROUP BY 1;

-- 2. Total Monthly Summary Report Range Police
SELECT 
    month,
    SUM(dacoity) as total_dacoity,
    SUM(robbery) as total_robbery,
    SUM(murder) as total_murder,
    SUM(speedy_trial) as total_speedy_trial,
    SUM(riot) as total_riot,
    SUM(woman_child_repression) as total_woman_child_repression,
    SUM(kidnapping) as total_kidnapping,
    SUM(police_assault) as total_police_assault,
    SUM(burglary) as total_burglary,
    SUM(theft) as total_theft,
    SUM(other_cases) as total_other_cases,
    SUM(recovery_cases) as total_recovery_cases,
    SUM(total_cases) as grand_total_cases
FROM crime_data
WHERE unit like '%Range'
GROUP BY 1
Order BY grand_total_cases DESC;

-- 3. Total Monthly Summary Report by metropolitan police
SELECT 
    month,
    SUM(dacoity) as total_dacoity,
    SUM(robbery) as total_robbery,
    SUM(murder) as total_murder,
    SUM(speedy_trial) as total_speedy_trial,
    SUM(riot) as total_riot,
    SUM(woman_child_repression) as total_woman_child_repression,
    SUM(kidnapping) as total_kidnapping,
    SUM(police_assault) as total_police_assault,
    SUM(burglary) as total_burglary,
    SUM(theft) as total_theft,
    SUM(other_cases) as total_other_cases,
    SUM(recovery_cases) as total_recovery_cases,
    SUM(total_cases) as grand_total_cases
FROM crime_data
WHERE unit like "%MP"
GROUP BY 1
Order BY grand_total_cases DESC;

-- 4. Total unit summary 
SELECT 
	unit,
    SUM(dacoity) as total_dacoity,
    SUM(robbery) as total_robbery,
    SUM(murder) as total_murder,
    SUM(speedy_trial) as total_speedy_trial,
    SUM(riot) as total_riot,
    SUM(woman_child_repression) as total_woman_child_repression,
    SUM(kidnapping) as total_kidnapping,
    SUM(police_assault) as total_police_assault,
    SUM(burglary) as total_burglary,
    SUM(theft) as total_theft,
    SUM(other_cases) as total_other_cases,
    SUM(recovery_cases) as total_recovery_cases,
    SUM(total_cases) as grand_total_cases
FROM crime_data
GROUP BY 1
ORDER BY grand_total_cases DESC;


-- 5. What types of crimes are most common?
SELECT 
    'Dacoity' as crime_type, SUM(dacoity) as total FROM crime_data
UNION ALL
SELECT 'Robbery', SUM(robbery) FROM crime_data
UNION ALL
SELECT 'Murder', SUM(murder) FROM crime_data
UNION ALL
SELECT 'Woman & Child Repression', SUM(woman_child_repression) FROM crime_data
UNION ALL
SELECT 'Kidnapping', SUM(kidnapping) FROM crime_data
UNION ALL
SELECT 'Burglary', SUM(burglary) FROM crime_data
UNION ALL
SELECT 'Theft', SUM(theft) FROM crime_data
ORDER BY total DESC;

-- ------------------------------------------------
-- --Summary By Month  --------------------
-- - ----------------------------------------------
-- 6.MURDER - Unit with highest murders EACH MONTH
SELECT 
    month,
    SUM(murder) as total_murder,
    ROUND(Avg(murder), 2) as avg_monthly_murder,
    MAX(murder) as peak_monthly_murder
FROM crime_data
Group BY month
ORDER BY total_murder DESC
LIMIT 5;

-- 7. ROBBERY - Unit with highest robberies EACH MONTH
SELECT 
    month,
    SUM(robbery) as total_robberies,
    ROUND(AVG(robbery), 2) as avg_monthly_robberies,
    MAX(robbery) as peak_monthly_robberies
FROM crime_data
GROUP BY 1
ORDER BY total_robberies DESC
LIMIT 5;

-- 8.  DACOITY - Unit with highest dacoity EACH MONTH
SELECT 
    month,
    SUM(dacoity) as total_dacoity,
    ROUND(AVG(dacoity), 2) as avg_monthly_dacoity,
    MAX(dacoity) as peak_monthly_dacoity
FROM crime_data
GROUP BY 1
ORDER BY total_dacoity DESC
LIMIT 5;

-- 9. THEFT - Unit with highest theft EACH MONTH
SELECT 
    unit,
    SUM(theft) as total_theft,
    ROUND(AVG(theft), 2) as avg_monthly_theft,
    MAX(theft) as peak_monthly_theft
FROM crime_data
GROUP BY unit
ORDER BY total_theft DESC
LIMIT 5;

-- 10. BURGLARY - Unit with highest burglary EACH MONTH
SELECT 
    unit,
    SUM(burglary) as total_burglary,
    ROUND(AVG(burglary), 2) as avg_monthly_burglary,
    MAX(burglary) as peak_monthly_burglary
FROM crime_data
GROUP BY unit
ORDER BY total_burglary DESC
LIMIT 5;

-- 11. WOMAN & CHILD REPRESSION - Unit with highest cases EACH MONTH
SELECT 
    unit,
    SUM(woman_child_repression) as total_cases,
    ROUND(AVG(woman_child_repression), 2) as avg_monthly_cases,
    MAX(woman_child_repression) as peak_monthly_cases
FROM crime_data
GROUP BY unit
ORDER BY total_cases DESC
LIMIT 5;

-- 12. KIDNAPPING - Unit with highest kidnapping EACH MONTH
SELECT 
    unit,
    SUM(kidnapping) as total_kidnapping,
    ROUND(AVG(kidnapping), 2) as avg_monthly_kidnapping,
    MAX(kidnapping) as peak_monthly_kidnapping
FROM crime_data
GROUP BY unit
ORDER BY total_kidnapping DESC
LIMIT 5;

-- 13. POLICE ASSAULT - Unit with highest cases EACH MONTH
SELECT 
    unit,
    SUM(police_assault) as total_assaults,
    ROUND(AVG(police_assault), 2) as avg_monthly_assaults,
    MAX(police_assault) as peak_monthly_assaults
FROM crime_data
GROUP BY unit
ORDER BY total_assaults DESC
LIMIT 5;

-- 14. RIOT - Unit with highest riots EACH MONTH
SELECT 
    unit,
    SUM(riot) as total_riots,
    ROUND(AVG(riot), 2) as avg_monthly_riots,
    MAX(riot) as peak_monthly_riots
FROM crime_data
GROUP BY unit
ORDER BY total_riots DESC
LIMIT 5;

-- 15. SPEEDY TRIAL - Unit with highest cases EACH MONTH
SELECT 
    unit,
    SUM(speedy_trial) as total_speedy_trials,
    ROUND(AVG(speedy_trial), 2) as avg_monthly_speedy_trials,
    MAX(speedy_trial) as peak_monthly_speedy_trials
FROM crime_data
GROUP BY unit
ORDER BY total_speedy_trials DESC
LIMIT 5;



-- ------------------------------------------------
-- --Summary By Unit  --------------------
-- - ----------------------------------------------
-- 16. MURDER - Unit with highest total murders
SELECT 
    unit,
    SUM(murder) as total_murders,
    ROUND(AVG(murder), 2) as avg_monthly_murders,
    MAX(murder) as peak_monthly_murders
FROM crime_data
GROUP BY unit
ORDER BY total_murders DESC
LIMIT 5;

-- 17. ROBBERY - Unit with highest total robberies
SELECT 
    unit,
    SUM(robbery) as total_robberies,
    ROUND(AVG(robbery), 2) as avg_monthly_robberies,
    MAX(robbery) as peak_monthly_robberies
FROM crime_data
GROUP BY unit
ORDER BY total_robberies DESC
LIMIT 5;

-- 18. DACOITY - Unit with highest total dacoity
SELECT 
    unit,
    SUM(dacoity) as total_dacoity,
    ROUND(AVG(dacoity), 2) as avg_monthly_dacoity,
    MAX(dacoity) as peak_monthly_dacoity
FROM crime_data
GROUP BY unit
ORDER BY total_dacoity DESC
LIMIT 5;

-- 19. THEFT - Unit with highest total theft
SELECT 
    unit,
    SUM(theft) as total_theft,
    ROUND(AVG(theft), 2) as avg_monthly_theft,
    MAX(theft) as peak_monthly_theft
FROM crime_data
GROUP BY unit
ORDER BY total_theft DESC
LIMIT 5;

-- 20. BURGLARY - Unit with highest total burglary
SELECT 
    unit,
    SUM(burglary) as total_burglary,
    ROUND(AVG(burglary), 2) as avg_monthly_burglary,
    MAX(burglary) as peak_monthly_burglary
FROM crime_data
GROUP BY unit
ORDER BY total_burglary DESC
LIMIT 5;

-- 21. WOMAN & CHILD REPRESSION - Unit with highest cases
SELECT 
    unit,
    SUM(woman_child_repression) as total_cases,
    ROUND(AVG(woman_child_repression), 2) as avg_monthly_cases,
    MAX(woman_child_repression) as peak_monthly_cases
FROM crime_data
GROUP BY unit
ORDER BY total_cases DESC
LIMIT 5;

-- 22. KIDNAPPING - Unit with highest total kidnapping
SELECT 
    unit,
    SUM(kidnapping) as total_kidnapping,
    ROUND(AVG(kidnapping), 2) as avg_monthly_kidnapping,
    MAX(kidnapping) as peak_monthly_kidnapping
FROM crime_data
GROUP BY unit
ORDER BY total_kidnapping DESC
LIMIT 5;

-- 23. POLICE ASSAULT - Unit with highest cases
SELECT 
    unit,
    SUM(police_assault) as total_assaults,
    ROUND(AVG(police_assault), 2) as avg_monthly_assaults,
    MAX(police_assault) as peak_monthly_assaults
FROM crime_data
GROUP BY unit
ORDER BY total_assaults DESC
LIMIT 5;

-- 24. RIOT - Unit with highest total riots
SELECT 
    unit,
    SUM(riot) as total_riots,
    ROUND(AVG(riot), 2) as avg_monthly_riots,
    MAX(riot) as peak_monthly_riots
FROM crime_data
GROUP BY unit
ORDER BY total_riots DESC
LIMIT 5;

-- 25. SPEEDY TRIAL - Unit with highest cases
SELECT 
    unit,
    SUM(speedy_trial) as total_speedy_trials,
    ROUND(AVG(speedy_trial), 2) as avg_monthly_speedy_trials,
    MAX(speedy_trial) as peak_monthly_speedy_trials
FROM crime_data
GROUP BY unit
ORDER BY total_speedy_trials DESC
LIMIT 5;

 -- 26. Top 3 most dangeous murder by month
SELECT 
	month, 
	SUM(murder) as total_murder
FROM crime_data
GROUP BY month
ORDER BY total_murder DESC
LIMIT 3;
 
-- 27. Total murders across all units and months
SELECT 
	COUNT(DISTINCT month) as months,
    COUNT(DISTINCT unit) as units,
    SUM(murder) as total_murder_2025,
    round(sum(murder)/ count(Distinct month), 2) as avg_murder_per_month,
    round(sum(murder)/ 365, 2) as avg_murder_per_day
FROM crime_data;
    
-- 28. Top 3 Dangeroys unit overall
SELECT
	unit,
    SUM(total_cases) as total_cases
FROM crime_data
GROUP BY unit
ORDER BY total_cases DESC
LIMIT 3;

-- 29. Crime Growth Month Over Month
SELECT 
	month,
    SUM(total_cases) as total_cases,
    LAG(SUM(total_cases), 0) OVER() as previous_month,
    ROUND(
    (
        SUM(total_cases) 
        - LAG(SUM(total_cases)) OVER ()
    )
    /
    LAG(SUM(total_cases)) OVER ()
    * 100,
2) AS crime_rate
FROM crime_data
GROUP BY 1;


    