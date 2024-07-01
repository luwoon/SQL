-- Show first name, last name, and gender of patients whose gender is 'M'.
SELECT first_name, last_name, gender
FROM patients
WHERE gender = 'M';

-- Show first name and last name of patients who do does not have allergies (null).
SELECT first_name, last_name
FROM patients
WHERE allergies is null;

-- Show first name of patients that start with the letter 'C'.
SELECT first_name
FROM patients
WHERE first_name like 'C%';

-- Show first name and last name of patients that weigh within the range of 100 to 120 (inclusive).
SELECT first_name, last_name
FROM patients
WHERE weight BETWEEN 100 AND 120;

-- Update the patients table for the allergies column. If the patient's allergies is null, replace it with 'NKA'.
UPDATE patients
SET allergies = 'NKA'
WHERE allergies IS NULL;

-- Show first name and last name concatenated into one column to show their full name.
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM patients;

-- Show first name, last name, and the full province name of each patient.
SELECT a.first_name, a.last_name, r.province_name
FROM patients a
JOIN provinces r USING(province_id);

-- Show how many patients have a birth_date with 2010 as the birth year.
SELECT COUNT(DISTINCT patient_id)
FROM patients
where year(birth_date) = 2010;

-- Show the first_name, last_name, and height of the patient with the greatest height.
SELECT first_name, last_name, MAX(height)
FROM patients;

-- Show all columns for patients who have one of the following patient_ids: 1, 45, 534, 879, or 1000.
SELECT * FROM patients
WHERE patient_id IN (1, 45, 534, 879, 1000);

-- Show the total number of admissions.
SELECT COUNT(patient_id) FROM admissions;

-- Show all the columns from admissions where the patient was admitted and discharged on the same day.
SELECT * FROM admissions
WHERE admission_date = discharge_date;

-- Show the total number of admissions for patient_id 573.
SELECT patient_id, COUNT(patient_id)
FROM admissions
WHERE patient_id = 573;

-- Based on the cities that our patients live in, show unique cities that are in province_id 'NS'.
SELECT DISTINCT(city)
FROM patients
WHERE province_id = 'NS';

-- Write a query to find the first_name, las,t name and birth date of patients who have A height more than 160 and weight more than 70.
SELECT first_name, last_name, birth_date
FROM patients
WHERE height > 160 AND weight > 70;

-- Write a query to get a list of patients' first_name, last_name, and allergies from Hamilton where allergies are not NKA or null.
SELECT first_name, last_name, allergies
FROM patients
WHERE city = 'Hamilton' AND allergies <> 'NKA';
