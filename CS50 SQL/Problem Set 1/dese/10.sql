-- In Massachusetts, school district expenditures are in part determined by local taxes on property (e.g., home) values. In 10.sql, write a SQL query to find the 10 public school districts with the highest per-pupil expenditures. Your query should return the names of the districts and the per-pupil expenditure for each.

SELECT
  d.name,
  e.per_pupil_expenditure
FROM
  expenditures e
  JOIN districts d ON d.id = e.district_id
WHERE
  d.type = "Public School District";