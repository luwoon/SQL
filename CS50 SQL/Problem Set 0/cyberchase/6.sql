-- In 6.sql, list the titles of episodes from season 6 (2008) that were released early, in 2007.

SELECT
  title
FROM
  episodes
WHERE
  season = 6
  AND air_date BETWEEN "2007-01-01"
  AND "2007-31-12";