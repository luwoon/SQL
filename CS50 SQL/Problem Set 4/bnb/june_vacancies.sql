CREATE VIEW june_vacancies AS
SELECT l.id, l.property_type, l.host_name, COUNT(a.id) as days_vacant
FROM listings l 
JOIN availabilities a ON a.listing_id = l.id 
WHERE a.available = "TRUE" AND a.date BETWEEN "2023-06-01" AND "2023-06-30"
GROUP BY l.id;