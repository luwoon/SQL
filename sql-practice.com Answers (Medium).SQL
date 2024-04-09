-- Show unique birth years from patients and order them by ascending.
SELECT DISTINCT year(birth_date)
FROM patients
ORDER BY YEAR(birth_date);

-- Show unique first names from the patients table which only occurs once in the list.
SELECT first_name
FROM patients
GROUP BY first_name
HAVING COUNT(*) = 1;

-- Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
SELECT patient_id, first_name
FROM patients
WHERE first_name LIKE 'S____%s';

-- Show patient_id, first_name, last_name from patients whos primary_diagnosis is 'Dementia'.
SELECT patient_id, first_name, last_name
FROM patients 
JOIN admissions USING(patient_id) 
WHERE primary_diagnosis = 'Dementia';

-- Display every patient's first_name. Order the list by the length of each name and then by alphbetically.
SELECT first_name
FROM patients
ORDER BY LENGTH(first_name), first_name;

-- Show the total amount of male patients and the total amount of female patients in the patients table. Display the two results in the same row.
SELECT COUNT(CASE
WHEN gender = 'M' THEN 1)
END AS male_count,
COUNT(CASE
WHEN gender = 'F' THEN 1 
END) AS female_count
FROM patients;

-- Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.
SELECT first_name, last_name, allergies
FROM patients
WHERE allergies IN ('Penicillin','Morphine')
ORDER BY  allergies, first_name, last_name;

-- Show patient_id, primary_diagnosis from admissions. Find patients admitted multiple times for the same primary_diagnosis.
SELECT patient_id, primary_diagnosis
FROM admissions
GROUP BY patient_id, primary_diagnosis
HAVING COUNT(*) > 1;

-- Show the city and the total number of patients in the city in the order from most to least patients.
SELECT city, COUNT(DISTINCT patient_id)
FROM patients
GROUP BY city
ORDER BY COUNT(patient_id) DESC;

-- Show first name, last name and role of every person that is either patient or physician.
SELECT first_name, last_name,
CASE
WHEN patient_id IS NOT NULL THEN 'Patient'
END AS role
FROM patients
UNION
SELECT first_name, last_name,
CASE
WHEN physician_id IS NOT NULL THEN 'Physician'
END AS role
FROM physicians;

-- Show all allergies ordered by popularity. Remove 'NKA' and NULL values from query.
SELECT allergies, COUNT(allergies)
FROM patients
WHERE allergies IS NOT NULL AND allergies <> 'NKA'
GROUP BY allergies
ORDER BY COUNT(allergies) DESC;

-- Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
SELECT first_name, last_name, birth_date
FROM patients
WHERE birth_date BETWEEN '1970-01-01' AND '1979-12-31'
ORDER BY birth_date;

-- We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order.
SELECT CONCAT(UPPER(last_name), ',', LOWER(first_name)) AS full_name
FROM patients
ORDER BY first_name DESC;

-- Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
SELECT province_id, SUM(height)
FROM patients
GROUP BY province_id
HAVING SUM(height) > 6999;

-- Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'.
SELECT MAX(weight) - MIN(weight)
FROM patients
WHERE last_name = 'Maroni';

-- Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
SELECT DAY(admission_date), COUNT(admission_date)
FROM admissions
GROUP BY DAY(admission_date)
ORDER BY COUNT(admission_date) DESC;

-- Show the patient_id, nursing_unit_id, room, and bed for patient_id 542's most recent admission_date.
SELECT patient_id, nursing_unit_id, room, bed
FROM admissions
WHERE patient_id = 542
ORDER BY admission_date DESC
LIMIT 1;

-- Show the nursing_unit_id and count of admissions for each nursing_unit_id. Exclude the following nursing_unit_ids: 'CCU', 'OR', 'ICU', 'ER'.
SELECT nursing_unit_id, COUNT(patient_id)
FROM admissions
WHERE nursing_unit_id NOT IN ('CCU','OR','ICU','ER')
GROUP BY nursing_unit_id;

/* Show patient_id, attending_physician_id, and primary_diagnosis for admissions that match one of the two criteria:
1. patient_id is an odd number and attending_physician_id is either 1, 5, or 19.
2. attending_physician_id contains a 2 and the length of patient_id is 3 characters. */
SELECT patient_id, attending_physician_id, primary_diagnosis
FROM admissions
WHERE (patient_id % 2 <> 0 AND attending_physician_id IN (1,5,19)) OR (attending_physician_id LIKE '%2%' AND LENGTH(patient_id) = 3);

-- Show first_name, last_name, and the total amount of admissions attended for each physician.
SELECT first_name, last_name, COUNT(patient_id) AS total_amount_of_admissions_attended
FROM physicians p
JOIN admissions a ON p.physician_id = a.attending_physician_id
GROUP BY physician_id;

-- For each physician, display their id, full name, and the first and last admission date they attended.
SELECT physician_id, CONCAT(first_name,' ',last_name) AS full_name, MAX(a.admission_date), MIN(a.admission_date)
FROM physicians p
JOIN admissions a ON p.physician_id = a.attending_physician_id
GROUP BY physician_id;
