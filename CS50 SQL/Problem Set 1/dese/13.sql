-- In 13.sql, write a SQL query to answer a question you have about the data! The query should: Involve at least one JOIN or subquery.

SELECT
  d.name,
  e.per_pupil_expenditure,
  s.unsatisfactory
FROM
  districts d
  JOIN expenditures e ON d.id = e.district_id
  JOIN staff_evaluations s on d.id = s.district_id
ORDER BY
  s.unsatisfactory DESC
LIMIT
  10;