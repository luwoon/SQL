-- Schema SQL at https://8weeksqlchallenge.com/case-study-5/

-- DATA CLEANING
/* In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
- Convert the week_date to a DATE format
- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a month_number with the calendar month for each week_date value as the 3rd column
- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
- Add a new demographic column using the following mapping for the first letter in the segment values
- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record */
CREATE TABLE clean_weekly_sales AS (
SELECT TO_DATE(week_date,'DD-MM-YY') AS week_date,
EXTRACT(WEEK FROM TO_DATE(week_date,'DD-MM-YY')) AS week_number,
EXTRACT(MONTH FROM TO_DATE(week_date,'DD-MM-YY')) AS month_number,
EXTRACT(YEAR FROM TO_DATE(week_date,'DD-MM-YY')) AS calendar_year,
region,
platform,
CASE
WHEN segment = 'null' THEN 'unknown'
ELSE segment
END AS segment,
CASE
WHEN segment LIKE '_1' THEN 'Young Adults'
WHEN segment LIKE '_2' THEN 'Middle Aged'
WHEN segment LIKE '_3' OR segment LIKE '_4' THEN 'Retirees'
ELSE 'unknown'
END AS age_band,
CASE
WHEN segment LIKE 'C_' THEN 'Couples'
WHEN segment LIKE 'F_' THEN 'Families'
ELSE 'unknown'
END AS demographic,
customer_type,
transactions,
sales,
ROUND(sales::NUMERIC/transactions::NUMERIC, 2) AS avg_transaction
FROM data_mart.weekly_sales);

-- DATA EXPLORATION
-- What day of the week is used for each week_date value?
SELECT TO_CHAR(week_date, 'DAY') FROM clean_weekly_sales;
-- Monday

-- What range of week numbers are missing from the dataset?
SELECT week_number FROM clean_weekly_sales;
-- Before 13 and after 36

-- How many total transactions were there for each year in the dataset?
SELECT calendar_year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year;

-- What is the total sales for each region for each month?
SELECT region, month_number, SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- What is the total count of transactions for each platform?
SELECT platform, COUNT(transactions) AS transaction_count
FROM clean_weekly_sales
GROUP BY platform;

-- What is the percentage of sales for Retail vs Shopify for each month?
SELECT month_number,
SUM(CASE
WHEN platform = 'Retail' THEN sales::NUMERIC
ELSE 0
END) as retail_sales,
SUM(CASE
WHEN platform = 'Shopify' THEN sales::NUMERIC
ELSE 0
END) AS shopify_sales,
ROUND((SUM(CASE
WHEN platform = 'Retail' THEN sales::NUMERIC
ELSE 0
END)/SUM(sales::NUMERIC) * 100), 2) AS retail_sales_percentage
,ROUND((SUM(CASE
WHEN platform = 'Shopify' THEN sales::NUMERIC
ELSE 0
END)/SUM(sales::NUMERIC)), 2) AS shopify_sales_percentage
FROM clean_weekly_sales
GROUP BY month_number;

-- What is the percentage of sales by demographic for each year in the dataset?
SELECT calendar_year, 
SUM(CASE
WHEN demographic = 'Couples' THEN sales::NUMERIC
ELSE 0
END) AS couples_sales,
SUM(CASE
WHEN demographic = 'Families' THEN sales::NUMERIC
ELSE 0
END) AS families_sales,
ROUND((SUM(CASE
WHEN demographic = 'Couples' THEN sales::NUMERIC
ELSE 0
END)/SUM(sales::NUMERIC)*100), 2) AS couples_sales_percentage,
ROUND((SUM(CASE
WHEN demographic = 'Families' THEN sales::NUMERIC
ELSE 0
END)/SUM(sales::NUMERIC)), 2) AS families_sales_percentage
FROM clean_weekly_sales
GROUP BY calendar_year;

-- Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band, demographic, SUM(sales)
FROM clean_weekly_sales
GROUP BY age_band, demographic
ORDER BY SUM(sales)DESC;
-- Retirees and families

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calendar_year, 
ANG(CASE
WHEN platform = 'Retail' THEN transactions::NUMERIC
ELSE 0
END) AS avg_retail_transactions,
ANG(CASE
WHEN platform = 'Shopify' THEN transactions::NUMERIC
ELSE 0
END) AS avg_shopify_transactions
FROM clean_weekly_sales
GROUP BY calendar_year;

-- BEFORE AND AFTER ANALYSIS
-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
SELECT distinct week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15' AND calendar_year = 2020;

WITH cte AS (
SELECT week_date, week_number,
SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 21 AND 28 AND calendar_year = 2020
GROUP BY week_date, week_number
),
before_after AS (
SELECT
SUM(CASE
WHEN week_number BETWEEN 21 AND 24 THEN total_sales
END) AS sales_before,
SUM(CASE
WHEN week_number BETWEEN 25 AND 28 THEN total_sales
END) AS sales_after
FROM cte
)
SELECT sales_after-sales_before AS growth,
ROUND(((sales_after-sales_before)/sales_before * 100), 2) AS percentage
FROM before_after;
-- The sales decreased by $26884188, or 1.15%.

-- What about the entire 12 weeks before and after?
WITH cte AS (
SELECT week_date, week_number, 
SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 13 AND 37 AND calendar_year = 2020
GROUP BY week_date, week_number
),
before_after AS (
SELECT SUM(CASE
WHEN week_number BETWEEN 13 AND 24 THEN total_sales
END) AS sales_before,
SUM(CASE
WHEN week_number BETWEEN 25 AND 37 THEN total_sales
END) AS sales_after
FROM cte
)
SELECT sales_after-sales_before AS growth,
ROUND(((sales_after-sales_before)/sales_before * 100), 2) AS percentage
FROM before_after;
-- The sales decreased by $152325394, or 2.14%.

-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH cte AS (
SELECT calendar_year, week_number, SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 21 AND 28
GROUP BY calendar_year, week_number
),
before_after AS (
SELECT calendar_year,
SUM(CASE
WHEN week_number BETWEEN 21 AND 24 THEN total_sales
END) AS sales_before,
SUM(CASE
WHEN week_number BETWEEN 25 and 28 THEN total_sales
END) AS sales_after
FROM cte
GROUP BY calendar_year
)
SELECT calendar_year, sales_after-sales_before AS growth, ROUND(((sales_after-sales_before)/sales_before * 100), 2) AS percentage
FROM before_after;

WITH cte AS (
SELECT calendar_year, week_number, SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 13 AND 37
GROUP BY calendar_year, week_number
),
before_after AS (
SELECT calendar_year,
SUM(CASE
WHEN week_number BETWEEN 13 AND 24 THEN total_sales
END) AS sales_before,
SUM(CASE
WHEN week_number BETWEEN 25 AND 37 THEN total_sales
END) AS sales_after
FROM cte
GROUP BY calendar_year
)
SELECT calendar_year, sales_after-sales_before AS growth, ROUND(((sales_after-sales_before)/sales_before * 100), 2) AS percentage
FROM before_after;
