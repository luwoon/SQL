-- Pizza Metrics
-- How many pizzas were ordered?

SELECT COUNT(*) 
FROM pizza_runner.customer_orders;

-- How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders;

-- How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS delivered
FROM pizza_runner.runner_orders
WHERE duration <> 'null'
GROUP BY 1
ORDER BY 1;

-- How many of each type of pizza was delivered?

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
  
-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_names, COUNT(pizza_names)
FROM pizza_runner.customer_orders
JOIN pizza_runner.pizza_names USING(pizza_id)
GROUP BY 1, 2
ORDER BY 1;

-- What was the maximum number of pizzas delivered in a single order?

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

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id, SUM(CASE WHEN (exclusions = '' OR exclusions = 'null' OR exclusions IS NULL) AND (extras = '' OR extras = 'null' OR extras IS NULL) THEN 1 ELSE 0 END) AS no_change, SUM(CASE WHEN (exclusions = '' OR exclusions = 'null' OR exclusions IS NULL) AND (extras = '' OR extras = 'null' OR extras IS NULL) THEN 0 ELSE 1 END) AS at_least_one_change
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders USING(order_id)
WHERE duration <> 'null'
GROUP BY 1
ORDER BY 1;

-- How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*) AS both_exclusions_and_extras
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders USING(order_id)
WHERE duration <> 'null' AND exclusions <> '' AND exclusions <> 'null' AND extras <> '';

-- What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOUR FROM order_time) AS hour, COUNT(*) AS order_volume
FROM pizza_runner.customer_orders
GROUP BY 1
ORDER BY 1;

-- What was the volume of orders for each day of the week?

SELECT TO_CHAR(order_time, 'day') AS day_of_week, COUNT(*) AS order_volume

-- Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT CEILING(EXTRACT(DAY FROM registration_date) / 7) AS week_number, COUNT(*) AS runners_signed_up
FROM pizza_runner.runners
GROUP BY 1
ORDER BY 1;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, ROUND((AVG(EXTRACT(EPOCH FROM (pickup_time::timestamp - order_time::timestamp)) / 60)::numeric), 2) AS avg_time
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders USING(order_id)
WHERE pickup_time <> 'null'
GROUP BY 1
ORDER BY 1;

-- What was the average distance travelled for each customer?

WITH distinct_cte AS (
  SELECT DISTINCT order_id, customer_id, distance
  FROM pizza_runner.customer_orders
  JOIN pizza_runner.runner_orders USING(order_id)
  WHERE distance <> 'null'
)
SELECT customer_id, ROUND((AVG((REGEXP_REPLACE(distance, '[^0-9.]', '', 'g'))::numeric)), 2) AS avg_distance
FROM distinct_cte
GROUP BY 1
ORDER BY 1;

-- What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(REGEXP_REPLACE(duration, '[^0-9]', '', 'g')::int) - MIN(REGEXP_REPLACE(duration, '[^0-9]', '', 'g')::int) AS difference
FROM pizza_runner.runner_orders
WHERE duration <> 'null';

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, order_id, ROUND((((REGEXP_REPLACE(distance, '[^0-9.]', '', 'g')::numeric) / (REGEXP_REPLACE(duration, '[^0-9]', '', 'g')::numeric))), 2) AS speed
FROM pizza_runner.runner_orders
WHERE distance <> 'null'
ORDER BY 1;

-- What is the successful delivery percentage for each runner?

SELECT runner_id, ROUND((SUM(CASE WHEN distance <> 'null' THEN 1 END) * 100.00 / COUNT(*)), 2) AS successful_delivery_percentage
FROM pizza_runner.runner_orders














-- Ingredient Optimisation
-- What was the most commonly added extra?

WITH frequency_cte AS (
  SELECT unnest(string_to_array(extras, ', ')) AS extra, COUNT(*) AS frequency
  FROM pizza_runner.customer_orders
  GROUP BY 1
)
SELECT topping_name, frequency
FROM frequency_cte
JOIN pizza_runner.pizza_toppings ON topping_id::text = extra
ORDER BY 2 DESC;

-- What was the most common exclusion?

WITH frequency_cte AS (
  SELECT unnest(string_to_array(exclusions, ', ')) AS exclusion, COUNT(*) AS frequency
  FROM pizza_runner.customer_orders
  GROUP BY 1
)
SELECT topping_name, frequency
FROM frequency_cte
JOIN pizza_runner.pizza_toppings ON topping_id::text = exclusion
ORDER BY 2 DESC;

-- Generate an order item for each record in the customer_orders table.

WITH order_cte AS (
  SELECT order_id, customer_id, c.pizza_id, pizza_name, SPLIT_PART(exclusions, ', ', 1) AS exclusion_id_one, SPLIT_PART(exclusions, ', ', 2) AS exclusion_id_two, SPLIT_PART(extras, ', ', 1) AS extra_id_one, SPLIT_PART(extras, ', ', 2) AS extra_id_two
  FROM pizza_runner.customer_orders c
  JOIN pizza_runner.pizza_names p USING(pizza_id)
)
SELECT *, p1.topping_id AS exclusion_one_id, p1.topping_name AS exclusion_one_name,    p2.topping_id AS exclusion_two_id, 
    p2.topping_name AS exclusion_two_name,
    
    p3.topping_id AS extra_one_id, 
    p3.topping_name AS extra_one_name, 
    
    p4.topping_id AS extra_two_id, 
    p4.topping_name AS extra_two_name
FROM order_cte o
LEFT JOIN pizza_runner.pizza_toppings p1 ON o.exclusion_id_one = p1.topping_id::text
LEFT JOIN pizza_runner.pizza_toppings p2 ON o.exclusion_id_two = p2.topping_id::text
LEFT JOIN pizza_runner.pizza_toppings p3 ON o.extra_id_one = p3.topping_id::text
LEFT JOIN pizza_runner.pizza_toppings p4 ON o.extra_id_two = p4.topping_id::text;


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.


-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
