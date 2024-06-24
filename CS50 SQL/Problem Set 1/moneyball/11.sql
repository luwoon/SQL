-- You need a player that can get hits. Who might be the most underrated? In 11.sql, write a SQL query to find the 10 least expensive players per hit in 2001. 

SELECT
  p.first_name,
  p.last_name,
  s.salary / e.H AS "dollars per hit"
FROM
  performances e
  JOIN salaries s ON s.player_id = e.player_id
  AND s.year = e.year
  JOIN players p ON s.player_id = p.id
WHERE
  s.year = 2001
  AND e.yea r = 2001
  AND e.H <> 0
ORDER BY
  3,
  1,
  2;