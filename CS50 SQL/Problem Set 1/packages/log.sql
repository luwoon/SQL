-- *** The Lost Letter ***
SELECT
  *
FROM
  addresses
WHERE
  address = "900 Somerville Avenue";
-- Anneke's address ID is 432

SELECT
  *
FROM
  packages
WHERE
  from_address_id = 432
  AND contents = "Congratulatory letter";
-- Package ID is 384. "to_address_id" is 2 Finnigan Street.

SELECT
  *
FROM
  scans
WHERE
  package_id = 384;
-- Package was last dropped at "address_id" = 854

SELECT
  *
from
  addresses
where
  id = 854;
-- The package was dropped at 2 Finnigan Street


-- *** The Devious Delivery ***
SELECT
  *
FROM
  packages
WHERE
  from_address_id IS NULL;
-- Find package with no "From" address. Content of package is a duck debugger. Package ID is 5098. "to_address_id" is 50.

SELECT
  *
FROM
  scans
WHERE
  package_id = 5098;
-- Package was last dropped at "address_id" = 348

SELECT
  *
FROM
  addresses
WHERE
  id = 348;
-- Package was dropped at 7 Humboldt Place, Police Station


-- *** The Forgotten Gift ***
SELECT
  *
FROM
  addresses
WHERE
  address = "109 Tileston Street";
-- "from_address_id" is 9873

SELECT
  *
FROM
  packages
WHERE
  from_address_id = 9873;
-- Package contents are flowers. Package ID is 9523.

SELECT
  *
FROM
  scans
WHERE
  package_id = 9523;
-- Package was dropped and then picked up again by "driver_id" = 17

SELECT
  *
FROM
  drivers
WHERE
  id = 17;
-- Package is with Mikel