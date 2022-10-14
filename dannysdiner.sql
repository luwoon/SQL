--SCHEMA SQL

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


--QUERY SQL

-- 1. What is the total amount each customer spent at the restaurant?

select customer_id
,sum(price) as total_spent
from dannys_diner.sales s
join dannys_diner.menu m on s.product_id=m.product_id
group by customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id
,count(distinct order_date) as n_days_visited
from dannys_diner.sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

select *
,rank() over(partition by customer_id order by order_date) as item_number
from dannys_diner.sales
)
select customer_id
,product_id
from first_item_cte
where item_number = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_id
,count(product_id) as times_purchased
from dannys_diner.sales
group by product_id
order by times_purchased desc
limit 1;

-- 5. Which item was the most popular for each customer?

-- 6. Which item was purchased first by the customer after they became a member?

with after_member_cte as (
select *
,row_number() over(partition by customer_id order by order_date) as purchased
from dannys_diner.sales
join dannys_diner.members using(customer_id)
where order_date > join_date
)
select customer_id
,product_id
from after_member_cte
where purchased = 1;

-- 7. Which item was purchased just before the customer became a member?

with before_member_cte as (
select *
,rank() over(partition by customer_id order by order_date desc) as purchased
from dannys_diner.sales
join dannys_diner.members using(customer_id)
where order_date < join_date
)
select customer_id
,product_id
from before_member_cte
where purchased = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?