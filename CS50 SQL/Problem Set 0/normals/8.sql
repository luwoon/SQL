-- In 8.sql, write a SQL query to find the 10 locations with the lowest normal ocean surface temperature, sorted coldest to warmest. If two locations have the same normal ocean surface temperature, sort by latitude, smallest to largest. Include latitude, longitude, and surface temperature columns.

SELECT
  "latitude",
  "longitude",
  "0m"
FROM
  "normals"
ORDER BY
  "0m",
  "latitude"
LIMIT
  10;