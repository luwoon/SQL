CREATE VIEW message AS
WITH cte AS (
SELECT * FROM sentences
WHERE id in (14, 114, 618, 630, 932, 2230, 2346, 3041))
SELECT substr("sentence", (CASE
WHEN id = 14 THEN 98
WHEN id = 114 THEN 3
WHEN id = 618 THEN 72
WHEN id = 630 THEN 7
WHEN id = 932 THEN 12
WHEN id = 2230 THEN 50
WHEN id = 2346 THEN 44
WHEN id = 3041 THEN 14
END), (CASE
WHEN id = 14 THEN 4
WHEN id = 114 THEN 5
WHEN id = 618 THEN 9
WHEN id = 630 THEN 3
WHEN id = 932 THEN 5
WHEN id = 2230 THEN 7
WHEN id = 2346 THEN 10
WHEN id = 3041 THEN 5
END)) AS phrase
FROM cte;