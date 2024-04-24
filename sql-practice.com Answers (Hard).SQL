-- Show all of the patients grouped into weight groups. Show the total amount of patients in each weight group. Order the list by the weight group decending.*/
SELECT COUNT(patient_id) AS patients_in_group, FLOOR(weight/10) * 10 AS weight_group
FROM patients
GROUP BY weight_group
ORDER BY weight_group desc;

-- Show patient_id, weight, height, isObese from the patients table. Display isObese as a boolean 0 or 1.
SELECT patient_id, weight, height,
CASE
WHEN (weight/power((height/100.0), 2)) >= 30 THEN 1 
ELSE 0 
END AS isObese
FROM patients;

-- Show patient_id, first_name, last_name, and attending physician's specialty. Show only the patients who has a primary_diagnosis as 'Dementia' and the physician's first name is 'Lisa'.
SELECT a.patient_id, p.first_name AS patient_first_name, p.last_name AS patient_last_name, ph.specialty as attending_physician_specialty
FROM admissions a
JOIN patients p USING(patient_id)
JOIN physicians ph ON a.attending_physician_id = ph.physician_id
WHERE a.primary_diagnosis = 'Dementia' AND ph.first_name = 'Lisa';

/* All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
The password must be the following, in order:
1. patient_id
2. the numerical length of patient's last_name
3. year of patient's birth_date */
SELECT DISTINCT(a.patient_id), CONCAT(DISTINCT(p.patient_id), LEN(p.last_name), YEAR(p.birth_date)) AS temp_password
FROM patients p
JOIN admissions a USING(patient_id);

-- Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance. Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
SELECT CASE
WHEN patient_id % 2 = 0 THEN 'Yes' 
ELSE 'No' 
END AS has_insurance,
CASE
WHEN patient_id % 2 = 0 THEN COUNT(patient_id) * 10 
ELSE COUNT(patient_id) * 50 
END AS cost_after_insurance
FROM admissions
GROUP BY has_insurance;

-- Show the provinces that has more patients identified as 'M' than 'F'.
SELECT province_name 
FROM provinces 
JOIN patients USING(province_id)
GROUP BY province_name
HAVING COUNT(CASE
WHEN gender = 'M' THEN 1 
END)/COUNT(CASE WHEN gender = 'F' THEN 1 END);

/* We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
- First_name contains an 'r' after the first two letters
- Identifies their gender as 'F'
- Born in February, May, or December
- Their weight would be between 60kg and 80kg
- Their patient_id is an odd number
- They are from the city 'Halifax' */
SELECT * 
FROM patients
WHERE first_name LIKE '__r%' AND gender='F' AND MONTH(birth_date) IN (2,5,12) AND weight BETWEEN 60 AND 80 AAND patient_id % 2 <> 0 AND city = 'Halifax';

-- Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.
SELECT CONCAT(ROUND((SELECT COUNT(*) FROM patients WHERE gender = 'M')/CAST(COUNT(*) AS FLOAT), 4) * 100, %) AS percent_of_male_patients
FROM patients;

-- Show the patient_id and total_spent for patients who spent over 150 in medication_cost. Sort by most total_spent to least total_spent.
SELECT u.patient_id, SUM(m.medication_cost)
FROM unit_dose_orders u
JOIN medications m ON m.medication_id = u.medication_id
GROUP BY patient_id
HAVING SUM(m.medication_cost) > 150
ORDER BY SUM(medication_cost) DESC;

-- Provide the description of each item, along with the total cost of the quantity on hand (rounded to the nearest whole dollar), and the associated primary vendor.
SELECT item_description, ROUND(quantity_on_hand * item_cost, 0), v.vendor_name
FROM items i
JOIN vendors v ON v.vendor_id = i.primary_vendor_id;

-- For each day display the total amount of admissions on that day. Display the amount changed from the previous date.
WITH admission_counts_table AS (
SELECT admission_date, COUNT(patient_id) AS admission_count
FROM admissions
GROUP BY admission_date
)
SELECT admission_date, admission_count, admission_count - LAG(admission_count) OVER(ORDER BY admission_date) AS admission_count_change 
FROM admission_counts_table;

-- For each province, display the total amount patients spent on medication. Order by the most to least spent.
SELECT pr.province_name, ROUND(SUM(m.medication_cost)) AS total_spent
FROM patients pa
JOIN unit_dose_orders u ON pa.patient_id = u.patient_id
JOIN medications m ON u.medication_id = m.medication_id
JOIN provinces pr ON pa.province_id = pr.province_id
GROUP BY province_name
ORDER BY total_spent DESC;
