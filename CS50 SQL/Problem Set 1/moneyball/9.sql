-- What salaries are other teams paying? In 9.sql, write a SQL query to find the 5 lowest paying teams (by average salary) in 2001. Round the average salary column to two decimal places and call it “average salary”. Sort the teams by average salary, least to greatest. Your query should return a table with two columns, one for the teams’ names and one for their average salary.

SELECT
  t.name,
  ROUND(AVG(s.salary), 2) as "average salary"
FROM
  salaries s
  JOIN teams t ON t.id = s.team_id
WHERE
  s.year = 2001
GROUP BY
  t.id
ORDER BY
  2
LIMIT
  5;