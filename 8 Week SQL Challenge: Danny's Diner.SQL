-- Schema SQL at https://8weeksqlchallenge.com/case-study-1/

-- What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount_spent
FROM dannys_diner.sales 
JOIN dannys_diner.menu USING(product_id)
GROUP BY customer_id
ORDER BY customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS n_days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;

-- What was the first item from the menu purchased by each customer?
WITH first_item_cte AS (
SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS item_n
FROM dannys_diner.sales
)
SELECT customer_id, order_date, product_name AS first_item_purchased
FROM first_item_cte
LEFT JOIN dannys_diner.menu USING(product_id)
WHERE item_n = 1
ORDER BY customer_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name AS most_purchased_item, COUNT(product_id) AS times_purchased
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu USING(product_id)
GROUP BY product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- Which item was the most popular for each customer?
WITH most_popular_cte AS (
SELECT customer_id, product_id, RANK() OVER(PARTITION BY customer_id ORDER BY count(product_id) DESC)
FROM dannys_diner.sales
GROUP BY customer_id, product_id
)
SELECT customer_id, product_name AS most_popular
FROM most_popular_cte
LEFT JOIN dannys_diner.menu USING(product_id)
WHERE rank = 1
ORDER BY customer_id;

-- Which item was purchased first by the customer after they became a member?
WITH after_member_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS purchased
FROM dannys_diner.sales
JOIN dannys_diner.members USING(customer_id)
WHERE order_date > join_date
)
SELECT customer_id, product_name
FROM after_member_cte
LEFT JOIN dannys_diner.menu USING(product_id)
WHERE purchased = 1
ORDER BY customer_id;

-- Which item was purchased just before the customer became a member?
WITH before_member_cte AS (
SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS purchased
FROM dannys_diner.sales
JOIN dannys_diner.members USING(customer_id)
WHERE order_date < join_date
)
SELECT customer_id, product_name
FROM before_member_cte
LEFT JOIN dannys_diner.menu USING(product_id)
WHERE purchased = 1
ORDER BY customer_id;

-- What is the total items and amount spent for each member before they became a member?
SELECT customer_id, COUNT(product_id) AS total_items, SUM(price) AS amount_spent
FROM dannys_diner.sales
JOIN dannys_diner.menu USING(product_id)
JOIN dannys_diner.members USING(customer_id)
WHERE order_date < join_date
GROUP BY customer_id;

-- If each $1 spent equates to 10 poinTs and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
SELECT customer_id, product_id, price, CASE 
WHEN product_id = 1 THEN 20 * price
WHEN product_id = 2 THEN 10 * price
WHEN product_id = 3 THEN 10 * price
END AS points
FROM dannys_diner.sales 
LEFT JOIN dannys_diner.menu  USING(product_id)
)
SELECT customer_id, SUM(points) AS points
FROM points_cte
GROUP BY customer_id
ORDER BY customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH first_week_cte AS (
SELECT customer_id, order_date, product_id, price, CASE
WHEN product_id = 1 THEN 20 * price
WHEN product_id = 2 AND order_date BETWEEN join_date AND join_date + 7 THEN 20 * price
WHEN product_id = 3 AND order_date BETWEEN join_date AND join_date + 7 THEN 20 * price
ELSE 10 * price
END AS points
FROM dannys_diner.sales 
LEFT JOIN dannys_diner.menu USING(product_id)
LEFT JOIN dannys_diner.members USING(customer_id)
)
SELECT customer_id, SUM(points) AS points
FROM first_week_cte
WHERE customer_id IN (SELECT customer_id FROM dannys_diner.members)

-- Bonus question: Join All The Things
SELECT s.customer_id, s.order_date, m.product_name, m.price, CASE
WHEN e.join_date IS NOT NULL AND e.join_date <= s.order_date THEN 'Y'
ELSE 'N'
END AS members
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m USING(product_id)
LEFT JOIN dannys_diner.members e USING(customer_id)
GROUP BY s.customer_id
ORDER BY s.customer_id, s.order_date;

-- Bonus question: Rank All The Things
WITH ranking_cte AS (
SELECT s.customer_id, s.order_date, m.product_name, m.price, CASE
WHEN e.join_date IS NOT NULL AND e.join_date <= s.order_date THEN 'Y'
ELSE 'N'
END AS members
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m USING(product_id)
LEFT JOIN dannys_diner.members e USING(customer_id)
ORDER BY s.customer_id, s.order_date
)
SELECT *, CASE
WHEN members = 'Y' THEN DENSE_RANK() OVER (PARTITION BY customer_id, members ORDER BY order_date)
ELSE NULL
END AS ranking
FROM ranking_cte;
