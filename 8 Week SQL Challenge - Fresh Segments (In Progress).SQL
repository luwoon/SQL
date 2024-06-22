-- Schema SQL at https://8weeksqlchallenge.com/case-study-8/

-- DATA EXPLORATION AND CLEANING
-- Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month.
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE VARCHAR(20);
UPDATE fresh_segments.interest_metrics 
SET month_year =
CASE
WHEN month_year IS NULL THEN NULL
ELSE TO_DATE(CONCAT('01-', month_year), 'DD-MM-YYYY')
END;
SELECT * from fresh_segments.interest_metrics;

-- What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year,
CASE 
WHEN month_year IS NOT NULL THEN COUNT(month_year) 
WHEN month_year IS NULL THEN COUNT(ranking)
END AS count_month_year
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST;

-- What do you think we should do with these null values in the fresh_segments.interest_metrics?
-- Remove these records.
DELETE FROM fresh_segments.interest_metrics
WHERE month_year IS NULL;

-- How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
WITH cte1 AS (
SELECT e.interest_id, a.id
FROM fresh_segments.interest_metrics e
LEFT JOIN fresh_segments.interest_map a ON e.interest_id::INTEGER = a.id
)
SELECT count(distinct interest_id) 
FROM cte1 
WHERE id IS NULL;
WITH cte2 AS (
SELECT e.interest_id, a.id
FROM fresh_segments.interest_map a
LEFT JOIN fresh_segments.interest_metrics e ON e.interest_id::integer = a.id
)
SELECT count(distinct id) 
FROM cte2 
WHERE interest_id IS NULL;
-- All interest_id values exist in the interest_map table but 7 id values do not exist in the interest_metrics table.

-- Summarise the id values in the fresh_segments.interest_map by its total record count in this table.
SELECT id, COUNT(id)
FROM fresh_segments.interest_map
GROUP BY id;

-- What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
-- Left join with interest_metrics as the left table and interest_map as the right table. id in interest_map is unique while interest_id in interest_metric is not unique.
SELECT * FROM fresh_segments.interest_metrics e
LEFT JOIN fresh_segments.interest_map a ON e.interest_id::integer = a.id;

-- INTEREST ANALYSIS
-- Which interests have been present in all month_year dates in our dataset?
SELECT COUNT(DISTINCT month_year)
FROM fresh_segments.interest_metrics;
SELECT interest_id
FROM fresh_segments.interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) = 14;

-- Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH total_months_cte AS (
SELECT interest_id, COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY interest_id
),
count_cte AS (
SELECT total_months, COUNT(DISTINCT interest_id) AS interest_count
FROM total_months_cte
GROUP BY total_months
)
SELECT total_months, interest_count,
SUM(interest_count) OVER (ORDER BY total_months DESC) AS cumulative_sum,
100 * SUM(interest_count) OVER (ORDER BY total_months DESC)/SUM(interest_count) OVER () AS cumulative_percentage
FROM count_cte;

-- If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
-- Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
-- After removing these interests, how many unique interests are there for each month?

-- SEGMENT ANALYSIS
-- Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
WITH filtered_cte AS (
SELECT interest_id, COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) > 5
)
SELECT f.interest_id, i.month_year, i.composition
FROM filtered_cte f
JOIN fresh_segments.interest_metrics i ON f.interest_id = i.interest_id
ORDER BY i.composition DESC
LIMIT 10;

WITH filtered_cte AS (
SELECT interest_id, COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) > 5
)
SELECT f.interest_id, i.month_year, i.composition
FROM filtered_cte f
JOIN fresh_segments.interest_metrics i ON f.interest_id = i.interest_id
ORDER BY i.composition
LIMIT 10;

-- Which 5 interests had the lowest average ranking value?
SELECT interest_id, ROUND(AVG(ranking), 2)
FROM fresh_segments.interest_metrics
GROUP BY interest_id
ORDER BY AVG(ranking)
LIMIT 5;

-- Which 5 interests had the largest standard deviation in their percentile_ranking value?
SELECT interest_id, ROUND(CAST(STDDEV(percentile_ranking) AS NUMERIC), 2) as std_percentile
FROM fresh_segments.interest_metrics
GROUP BY interest_id
HAVING ROUND(CAST(STDDEV(percentile_ranking) AS NUMERIC), 2) IS NOT NULL
ORDER BY ROUND(CAST(STDDEV(percentile_ranking) AS NUMERIC), 2) DESC
LIMIT 5;
