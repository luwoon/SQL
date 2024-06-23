-- In 13.sql, write a SQL query to explore a question of your choice. This query should involve at least one condition, using WHERE with AND or OR.

SELECT
  title
FROM
  episodes
WHERE
  season > 4
  AND title LIKE "The%";