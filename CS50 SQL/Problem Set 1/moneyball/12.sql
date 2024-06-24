-- Hits are great, but so are RBIs! In 12.sql, write a SQL query to find the players among the 10 least expensive players per hit and among the 10 least expensive players per RBI in 2001. 

SELECT
  first_name,
  last_name
FROM
  players
WHERE
  id IN (
    SELECT
      s.player_id
    FROM
      performances e
      JOIN salaries s USING(player_id)
    WHERE
      s.year = 2001
      AND e.year = 2001
      and e.H <> 0
    ORDER BY
      s.salary / e.H DESC
    LIMIT
      10
  )
  AND id IN (
    SELECT
      s.player_id
    FROM
      performances e
      JOIN salaries s USING(player_id)
    WHERE
      s.year = 2001
      AND e.year = 2001
      and e.RBI <> 0
    ORDER BY
      s.salary / e.RBI DESC
    LIMIT
      10
  );