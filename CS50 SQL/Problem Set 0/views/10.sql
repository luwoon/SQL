-- In 10.sql, write a SQL query to answer a question of your choice about the prints.The query should: Make use of AS to rename a column Involve at least one condition, using WHERE, and Sort by at least one column, using ORDER BY.

SELECT
  "japanese_title" || " " || "english_title" AS "full title"
FROM
  "views"
WHERE
  "contrast" > 0.5
ORDER BY
  "brightness" DESC
LIMIT
  10;