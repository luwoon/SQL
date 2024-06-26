CREATE VIEW frequently_reviewed AS
SELECT l.id, l.property_type, l.host_name, COUNT(r.id) 
FROM listings l
JOIN reviews r ON r.listing_id = l.id
GROUP BY l.id
ORDER BY 4 DESC, l.property_type, l.host_name
LIMIT 100;