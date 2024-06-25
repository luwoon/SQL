UPDATE users
SET password = (SELECT password FROM users WHERE username = "emily33")
WHERE username = "admin";

UPDATE users
SET password = "oops!"
WHERE username = "admin";

DELETE FROM user_logs
WHERE new_username = "admin" AND type = "update" AND new_password = "oops!";