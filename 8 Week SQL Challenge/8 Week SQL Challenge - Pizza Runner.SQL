-- Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT COUNT(*) 
FROM pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS delivered
FROM pizza_runner.runner_orders
WHERE duration <> 'null'
GROUP BY 1
ORDER BY 1;

-- 4. How many of each type of pizza was delivered?

WITH pizza_type AS (
  SELECT c.order_id, pizza_name
  FROM pizza_runner.customer_orders c
  JOIN pizza_runner.runner_orders r USING(order_id)
  JOIN pizza_runner.pizza_names p USING(pizza_id)
  WHERE duration <> 'null'
  ORDER BY 1
)
SELECT pizza_name, COUNT(pizza_name) AS delivered
FROM pizza_type
GROUP BY 1
ORDER BY 1;
  
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_names, COUNT(pizza_names)
FROM pizza_runner.customer_orders
JOIN pizza_runner.pizza_names USING(pizza_id)
GROUP BY 1, 2
ORDER BY 1;

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH max_cte AS (
  SELECT order_id, COUNT(pizza_id) as count
  FROM pizza_runner.customer_orders
  JOIN pizza_runner.runner_orders USING (order_id)
  WHERE duration <> 'null'
  GROUP BY 1
  ORDER BY 1
)
SELECT MAX(count) AS max_pizzas
FROM max_cte;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id, SUM(CASE WHEN (exclusions = '' OR exclusions = 'null' OR exclusions IS NULL) AND (extras = '' OR extras = 'null' OR extras IS NULL) THEN 1 ELSE 0 END) AS no_change, SUM(CASE WHEN (exclusions = '' OR exclusions = 'null' OR exclusions IS NULL) AND (extras = '' OR extras = 'null' OR extras IS NULL) THEN 0 ELSE 1 END) AS at_least_one_change
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders USING(order_id)
WHERE duration <> 'null'
GROUP BY 1
ORDER BY 1;

-- 8. How many pizzas were delivered that had both exclusions and extras?


-- 9. What was the total volume of pizzas ordered for each hour of the day?


-- 10. What was the volume of orders for each day of the week?


-- 10. What was the volume of orders for each day of the week?
