-- Schema SQL at https://8weeksqlchallenge.com/case-study-8/

-- DATA EXPLORATION AND CLEANING

-- Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month.

alter table fresh_segments.interest_metrics
alter column month_year type varchar(20);
update fresh_segments.interest_metrics 
set month_year =
case
when month_year is null then null
else to_date(concat('01-', month_year), 'DD-MM-YYYY')
end;
select * from fresh_segments.interest_metrics;

-- What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

select month_year
,case 
when month_year is not null then count(month_year) 
when month_year is null then count(ranking)
end as count_month_year
from fresh_segments.interest_metrics
group by month_year
order by month_year asc nulls first;

-- What do you think we should do with these null values in the fresh_segments.interest_metrics?
-- Remove these records.

delete from fresh_segments.interest_metrics
where month_year is null;

-- How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

with cte1 as (
select e.interest_id
,a.id
from fresh_segments.interest_metrics e
left join fresh_segments.interest_map a 
on e.interest_id::integer = a.id
)
select count(distinct interest_id) 
from cte1 
where id is null;
with cte2 as (
select e.interest_id
,a.id
from fresh_segments.interest_map a
left join fresh_segments.interest_metrics e
on e.interest_id::integer = a.id
)
select count(distinct id) 
from cte2 
where interest_id is null;
-- All interest_id values exist in the interest_map table but 7 id values do not exist in the interest_metrics table.

-- Summarise the id values in the fresh_segments.interest_map by its total record count in this table.

select id
,count(id)
from fresh_segments.interest_map
group by id;

-- What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
-- Left join with interest_metrics as the left table and interest_map as the right table. id in interest_map is unique while interest_id in interest_metric is not unique.

select * 
from fresh_segments.interest_metrics e
left join fresh_segments.interest_map a
on e.interest_id::integer = a.id;

-- INTEREST ANALYSIS

-- Which interests have been present in all month_year dates in our dataset?

select count(distinct month_year)
from fresh_segments.interest_metrics;
select interest_id
from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) = 14;

-- Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

with total_months_cte as (
select interest_id
,count(distinct month_year) as total_months
from fresh_segments.interest_metrics
group by interest_id
)
,count_cte as (
select total_months
,count(distinct interest_id) as interest_count
from total_months_cte
group by total_months
)
select total_months
,interest_count
,sum(interest_count) over (order by total_months desc) as cumulative_sum
,100 * sum(interest_count) over (order by total_months desc)/sum(interest_count) over () as cumulative_percentage
from count_cte;

-- If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
-- Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
--After removing these interests - how many unique interests are there for each month?

-- SEGMENT ANALYSIS

-- Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year

with filtered_cte as (
select interest_id
,count(distinct month_year) as total_months
from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) > 5
)
select f.interest_id
,i.month_year
,i.composition
from filtered_cte f
join fresh_segments.interest_metrics i 
on f.interest_id = i.interest_id
order by i.composition desc
limit 10;

with filtered_cte as (
select interest_id
,count(distinct month_year) as total_months
from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) > 5
)
select f.interest_id
,i.month_year
,i.composition
from filtered_cte f
join fresh_segments.interest_metrics i 
on f.interest_id = i.interest_id
order by i.composition
limit 10;

-- Which 5 interests had the lowest average ranking value?

select interest_id
,round(avg(ranking),2)
from fresh_segments.interest_metrics
group by interest_id
order by avg(ranking)
limit 5;

-- Which 5 interests had the largest standard deviation in their percentile_ranking value?

select interest_id
,round(cast(stddev(percentile_ranking) as numeric),2) as std_percentile
from fresh_segments.interest_metrics
group by interest_id
having round(cast(stddev(percentile_ranking) as numeric),2) is not null
order by round(cast(stddev(percentile_ranking) as numeric),2) desc
limit 5;

-- For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
-- How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

-- INDEX ANALYSIS

-- The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients. Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
-- What is the top 10 interests by the average composition for each month?
-- For all of these top 10 interests - which interest appears the most often?
-- What is the average of the average composition for the top 10 interests for each month?
-- What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
-- Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
