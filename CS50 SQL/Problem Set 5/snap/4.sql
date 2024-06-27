SELECT u.username
FROM users u
JOIN messages m ON m.to_user_id = u.id
GROUP BY u.username
ORDER BY COUNT(m.id) DESC
LIMIT 1;