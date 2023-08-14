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
