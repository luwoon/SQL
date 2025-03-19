-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS total_spent
FROM dannys_diner.sales
JOIN dannys_diner.menu USING(product_id)
GROUP BY 1
ORDER BY 1;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited 
FROM dannys_diner.sales
GROUP BY 1
ORDER BY 1;

-- 3. What was the first item from the menu purchased by each customer?

WITH ranked_orders AS (
  SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank
  FROM dannys_diner.sales
)
SELECT customer_id, order_date, product_name AS first_item
FROM ranked_orders
JOIN dannys_diner.menu USING(product_id)
WHERE rank = 1
ORDER BY 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name AS most_purchased_item, COUNT(product_id) AS times_purchased
FROM dannys_diner.sales
JOIN dannys_diner.menu USING(product_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH most_popular AS (
  SELECT customer_id, product_id, RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rank
  FROM dannys_diner.sales
  GROUP BY 1, 2
)
SELECT customer_id, product_name AS most_popular
FROM most_popular
JOIN dannys_diner.menu USING(product_id)
WHERE rank = 1
ORDER BY 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH rank_purchase AS (
  SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank
  FROM dannys_diner.sales
  JOIN dannys_diner.members USING(customer_id)
  WHERE order_date > join_date)
SELECT customer_id, product_name AS first_purchase_after_member
FROM rank_purchase
JOIN dannys_diner.menu USING(product_id)
WHERE rank = 1
ORDER BY 1;

-- 7. Which item was purchased just before the customer became a member?

WITH rank_purchase AS (
  SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rank
  FROM dannys_diner.sales
  JOIN dannys_diner.members USING(customer_id)
  WHERE order_date < join_date)
SELECT customer_id, product_name AS last_purchase_before_member
FROM rank_purchase
JOIN dannys_diner.menu USING(product_id)
WHERE rank = 1
ORDER BY 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) AS total_items_before_member, SUM(e.price) AS total_spent_before_member
FROM dannys_diner.sales s
JOIN dannys_diner.members m USING(customer_id)
JOIN dannys_diner.menu e USING(product_id)
WHERE order_date < join_date
GROUP BY 1
ORDER BY 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_cte AS (
  SELECT customer_id, product_name, CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END AS points
  FROM dannys_diner.sales
  JOIN dannys_diner.menu USING(product_id)
)
SELECT customer_id, SUM(points) AS points
FROM points_cte
GROUP BY 1
ORDER BY 1;
  
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH points_cte AS (
  SELECT sales.customer_id, order_date, product_name, CASE WHEN product_name = 'sushi' THEN price * 20 WHEN (product_name = 'curry' or product_name = 'ramen') AND order_date BETWEEN join_date AND join_date + 7 THEN price * 20 ELSE price * 10 END AS points
  FROM dannys_diner.sales
  JOIN dannys_diner.menu USING(product_id)
  JOIN dannys_diner.members USING(customer_id)
  WHERE order_date < '2021-02-01'
)
SELECT customer_id, SUM(points) AS total_points
FROM points_cte;

-- 11. Join all the things.

SELECT s.customer_id, order_date, product_name, price, CASE WHEN join_date <= order_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales s
JOIN dannys_diner.menu m USING(product_id)
LEFT JOIN dannys_diner.members e USING(customer_id)
ORDER BY 1, 2, 3;

-- 12.Rank all the things.

WITH join_cte AS (
  SELECT s.customer_id, order_date, product_name, price, CASE WHEN join_date <= order_date THEN 'Y' ELSE 'N' END AS member
  FROM dannys_diner.sales s
  JOIN dannys_diner.menu m USING(product_id)
  LEFT JOIN dannys_diner.members e USING(customer_id)
  ORDER BY 1, 2, 3)
SELECT *, CASE WHEN member = 'N' THEN null ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) END AS ranking
FROM join_cte;
GROUP BY 1
ORDER BY 1;
