-- Select first names and the total babies with that first_name
-- Group by first_name and filter for those names that appear in all 101 years
-- Order by the total number of babies with that first_name, descending
SELECT first_name, SUM(num) AS sum
FROM baby_names
GROUP BY first_name
HAVING COUNT(first_name) >= 101
ORDER BY sum DESC;

-- Classify first names as 'Classic', 'Semi-classic', 'Semi-trendy', or 'Trendy'
-- Alias this column as popularity_type
-- Select first_name, the sum of babies who have ever had that name, and popularity_type
-- Order the results alphabetically by first_name
SELECT first_name, SUM(num) AS sum, CASE
WHEN COUNT(first_name) > 80 THEN 'Classic'
WHEN COUNT(first_name) BETWEEN 50 AND 79 THEN 'Semi-classic'
WHEN COUNT(first_name) BETWEEN 20 AND 49 THEN 'Semi-trendy'
ELSE 'Trendy'
END AS popularity_type
FROM baby_names
GROUP BY first_name
ORDER BY first_name ASC;

-- RANK names by the sum of babies who have ever had that name (descending), aliasing as name_rank
-- Select name_rank, first_name, and the sum of babies who have ever had that name
-- Filter the data for results where sex equals 'F'
-- Limit to ten results
SELECT first_name, SUM(num), RANK() OVER(ORDER BY SUM(num) DESC) AS name_rank
FROM baby_names
WHERE sex = 'F'
GROUP BY first_name
LIMIT 10;

-- Select only the first_name column
-- Filter for results where sex is 'F', year is greater than 2015, and first_name ends in 'a'
-- Group by first_name and order by the total number of babies given that first_name
SELECT first_name
FROM baby_names
WHERE sex = 'F' AND year > 2015 AND first_name LIKE '%a'
GROUP BY first_name
ORDER BY SUM(num) DESC;

-- Select year, first_name, num of Olivias in that year, and cumulative_olivias
-- Sum the cumulative babies who have been named Olivia up to that year; alias as cumulative_olivias
-- Filter so that only data for the name Olivia is returned.
-- Order by year from the earliest year to most recent
SELECT year, first_name, num, SUM(num) OVER(ORDER BY year) AS cumulative_olivias
FROM baby_names
WHERE first_name = 'Olivia';

-- Select year and maximum number of babies given any one male name in that year, aliased as max_num
-- Filter the data to include only results where sex equals 'M'
SELECT year, MAX(num) AS max_num
FROM baby_names
WHERE sex = 'M'
GROUP BY year
ORDER BY year;

-- Select year, first_name given to the largest number of male babies, and num of babies given that name
-- Join baby_names to the code in the last task as a subquery
-- Order results by year descending
SELECT b.year, b.first_name, b.num
FROM baby_names b
INNER JOIN (SELECT year, MAX(num) AS max_num
FROM baby_names
WHERE sex = 'M'
GROUP BY year
ORDER BY year) a ON ((a.year = b.year) AND (a.max_num = b.num))
ORDER BY year DESC;

-- Select first_name and a count of years it was the top name in the last task; alias as count_top_name
-- Use the code from the previous task as a common table expression
-- Group by first_name and order by count_top_name descending
WITH cte AS (
SELECT b.year, b.first_name, b.num
FROM baby_names b
INNER JOIN (SELECT year, MAX(num) AS max_num
FROM baby_names
WHERE sex = 'M'
GROUP BY year
ORDER BY year) a ON ((a.year = b.year) AND (a.max_num = b.num))
ORDER BY year DESC
)
SELECT first_name, COUNT(year) AS count_top_name
FROM cte
GROUP BY first_name
ORDER BY COUNT(year) DESC;
