-- A parent asks you for advice on finding the best public school districts in Massachusetts. In 12.sql, write a SQL query to find public school districts with above-average per-pupil expenditures and an above-average percentage of teachers rated “exemplary”. Your query should return the districts’ names, along with their per-pupil expenditures and percentage of teachers rated exemplary. Sort the results first by the percentage of teachers rated exemplary (high to low), then by the per-pupil expenditure (high to low).

SELECT
  d.name,
  e.per_pupil_expenditure,
  s.exemplary
FROM
  districts d
  JOIN expenditures e ON d.id = e.district_id
  JOIN staff_evaluations s on d.id = s.district_id
WHERE
  d.type = "Public School District"
  AND e.per_pupil_expenditure > (
    SELECT
      AVG(per_pupil_expenditure)
    FROM
      expenditures
  )
  AND s.exemplary > (
    SELECT
      AVG(exemplary)
    FROM
      staff_evaluations
  )
ORDER BY
  3 DESC,
  2 DESC;