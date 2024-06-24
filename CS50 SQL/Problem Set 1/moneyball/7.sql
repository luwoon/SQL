-- You need to make a recommendation about which player (or players) to avoid recruiting. In 7.sql, write a SQL query to find the name of the player who's been paid the highest salary, of all time, in Major League Baseball. Your query should return a table with two columns, one for the player’ s first name and one for their last name.

SELECT
  first_name,
  last_name
FROM
  players
WHERE
  id = (
    SELECT
      player_id
    FROM
      salaries
    WHERE
      salary = (
        SELECT
          MAX(salary)
        FROM
          salaries
      )
  );