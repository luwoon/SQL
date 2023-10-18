-- Schema SQL at https://8weeksqlchallenge.com/case-study-5/

-- DATA CLEANING
-- Convert the week_date to a DATE format
-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

create table clean_weekly_sales as (
select to_date(week_date,'DD-MM-YY') as week_date
,extract(week from to_date(week_date,'DD-MM-YY')) as week_number     
,extract(month from to_date(week_date,'DD-MM-YY')) as month_number
,extract(year from to_date(week_date,'DD-MM-YY')) as calendar_year
,region
,platform
,case
when segment='null' then 'unknown'
else segment
end as segment
,case
when segment like '_1' then 'Young Adults'
when segment like '_2' then 'Middle Aged'
when segment like '_3' or segment like '_4' then 'Retirees'
else 'unknown'
end as age_band
,case
when segment like 'C_' then 'Couples'
when segment like 'F_' then 'Families'
else 'unknown'
end as demographic
,customer_type
,transactions
,sales
,round(sales::numeric/transactions::numeric,2) as avg_transaction
from data_mart.weekly_sales);

-- DATA EXPLORATION

-- What day of the week is used for each week_date value?

select to_char(week_date, 'Day') from clean_weekly_sales;
-- Monday

-- What range of week numbers are missing from the dataset?

select week_number from clean_weekly_sales;
-- Before 13 and after 36

-- How many total transactions were there for each year in the dataset?

select calendar_year
,sum(transactions) as total_transactions
from clean_weekly_sales
group by calendar_year;

-- What is the total sales for each region for each month?

select region
,month_number
,sum(sales) as total_sales
from clean_weekly_sales
group by region
,month_number
order by region
,month_number;

-- What is the total count of transactions for each platform?

select platform
,count(transactions) as transaction_count
from clean_weekly_sales
group by platform;

-- What is the percentage of sales for Retail vs Shopify for each month?

select month_number
,sum(case
when platform='Retail' then sales::numeric
else 0
end) as retail_sales
,sum(case
when platform='Shopify' then sales::numeric
else 0
end) as shopify_sales
,round((sum(case
when platform='Retail' then sales::numeric
else 0
end)/sum(sales::numeric)*100),2) as retail_sales_percentage
,round((sum(case
when platform='Shopify' then sales::numeric
else 0
end)/sum(sales::numeric)),2) as shopify_sales_percentage
from clean_weekly_sales
group by month_number;

-- What is the percentage of sales by demographic for each year in the dataset?

select calendar_year
,sum(case
when demographic='Couples' then sales::numeric
else 0
end) as couples_sales
,sum(case
when demographic='Families' then sales::numeric
else 0
end) as families_sales
,round((sum(case
when demographic='Couples' then sales::numeric
else 0
end)/sum(sales::numeric)*100),2) as couples_sales_percentage
,round((sum(case
when demographic='Families' then sales::numeric
else 0
end)/sum(sales::numeric)),2) as families_sales_percentage
from clean_weekly_sales
group by calendar_year;

-- Which age_band and demographic values contribute the most to Retail sales?

select 
age_band
,demographic
,sum(sales)
from clean_weekly_sales
group by age_band
,demographic
order by sum(sales) desc;
-- Retirees and families

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

select calendar_year
,avg(case
when platform='Retail' then transactions::numeric
else 0
end) as avg_retail_transactions
,avg(case
when platform='Shopify' then transactions::numeric
else 0
end) as avg_shopify_transactions
from clean_weekly_sales
group by calendar_year;
