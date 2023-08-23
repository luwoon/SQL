-- Schema SQL at https://8weeksqlchallenge.com/case-study-6/

-- Entity relationship diagram is created at https://www.mavenanalytics.io/project/8331

-- DIGITAL ANALYSIS

-- How many users are there?

select count(distinct user_id) as n_users
from clique_bait.users;

-- How many cookies does each user have on average?

select count(distinct cookie_id)/count(distinct user_id) as avg_cookies
from clique_bait.users;

-- What is the unique number of visits by all users per month?

select count(distinct cookie_id) 
from clique_bait.users;

-- What is the number of events for each event type?

select event_type
,count(event_type)
from clique_bait.events
group by event_type;

-- What is the percentage of visits which have a purchase event?

select round((cast(count(case when event_type = 3 then visit_id end) as decimal)/count(event_type)*100),2)
from clique_bait.events;

-- What is the percentage of visits which view the checkout page but do not have a purchase event?
-- What are the top 3 pages by number of views?
-- What is the number of views and cart adds for each product category?
-- What are the top 3 products by purchases?
